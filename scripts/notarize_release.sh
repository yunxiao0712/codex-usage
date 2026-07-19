#!/bin/zsh
set -euo pipefail

project_dir="${0:A:h:h}"
release_dir="${RELEASE_DIR:-${project_dir}/.release}"
profile="${NOTARY_PROFILE:-}"

if [[ -z "${profile}" ]]; then
  echo "请先设置 NOTARY_PROFILE。" >&2
  exit 1
fi

app_path="${release_dir}/app/QuotaGlow.app"
zip_path="$(find "${release_dir}/updates" -maxdepth 1 -type f -name 'QuotaGlow-*.zip' -print -quit 2>/dev/null || true)"
dmg_path="$(find "${release_dir}" -maxdepth 1 -type f -name 'QuotaGlow-*.dmg' -print -quit 2>/dev/null || true)"
if [[ ! -d "${app_path}" || -z "${zip_path}" || -z "${dmg_path}" ]]; then
  echo "发布候选不完整，请先运行 scripts/package_release.sh。" >&2
  exit 1
fi

notary_zip="${release_dir}/.QuotaGlow-notary-upload.zip"
rm -f "${notary_zip}"
ditto -c -k --sequesterRsrc --keepParent "${app_path}" "${notary_zip}"
xcrun notarytool submit "${notary_zip}" --keychain-profile "${profile}" --wait
xcrun stapler staple "${app_path}"
xcrun stapler validate "${app_path}"

rm -f "${zip_path}" "${dmg_path}" "${notary_zip}"
ditto -c -k --sequesterRsrc --keepParent "${app_path}" "${zip_path}"
staging_dir="$(mktemp -d "${TMPDIR:-/tmp}/quotaglow-notary-dmg.XXXXXX")"
trap 'rm -rf "${staging_dir}"' EXIT
ditto "${app_path}" "${staging_dir}/QuotaGlow.app"
ln -s /Applications "${staging_dir}/Applications"
hdiutil create -volname "QuotaGlow" -srcfolder "${staging_dir}" -ov -format UDZO "${dmg_path}" >/dev/null
if [[ -n "${CODESIGN_IDENTITY:-}" ]]; then
  codesign --force --timestamp --sign "${CODESIGN_IDENTITY}" "${dmg_path}"
fi
xcrun notarytool submit "${dmg_path}" --keychain-profile "${profile}" --wait
xcrun stapler staple "${dmg_path}"
xcrun stapler validate "${dmg_path}"
shasum -a 256 "${zip_path}" "${dmg_path}" | tee "${release_dir}/SHA256SUMS"
echo "${dmg_path}"
