#!/bin/zsh
set -euo pipefail

project_dir="${0:A:h:h}"
release_dir="${RELEASE_DIR:-${project_dir}/.release}"
app_output_dir="${release_dir}/app"
updates_dir="${release_dir}/updates"
version="${APP_VERSION:-$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "${project_dir}/Info.plist")}"
channel="${RELEASE_CHANNEL:-local}"
suffix="${version}-${channel}"

mkdir -p "${release_dir}" "${updates_dir}"
OUTPUT_DIR="${app_output_dir}" "${project_dir}/scripts/build_app.sh" >/dev/null
app_path="${app_output_dir}/QuotaGlow.app"
zip_path="${updates_dir}/QuotaGlow-${suffix}.zip"
dmg_path="${release_dir}/QuotaGlow-${suffix}.dmg"

rm -f "${zip_path}" "${dmg_path}"
ditto -c -k --sequesterRsrc --keepParent "${app_path}" "${zip_path}"

staging_dir="$(mktemp -d "${TMPDIR:-/tmp}/quotaglow-dmg.XXXXXX")"
trap 'rm -rf "${staging_dir}"' EXIT
ditto "${app_path}" "${staging_dir}/QuotaGlow.app"
ln -s /Applications "${staging_dir}/Applications"
hdiutil create -volname "QuotaGlow" -srcfolder "${staging_dir}" -ov -format UDZO "${dmg_path}" >/dev/null

if [[ -n "${CODESIGN_IDENTITY:-}" ]]; then
  codesign --force --timestamp --sign "${CODESIGN_IDENTITY}" "${dmg_path}"
fi

shasum -a 256 "${zip_path}" "${dmg_path}" | tee "${release_dir}/SHA256SUMS"
echo "${release_dir}"
