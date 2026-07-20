.PHONY: build test package release-status clean

build:
	./build.sh

test: build
	./.artifacts/Codex\ Usage\ Strip.app/Contents/MacOS/CodexUsageStrip --self-test

package:
	./scripts/package_release.sh

release-status:
	-./scripts/check_release_prerequisites.sh

clean:
	swift package clean
	rm -rf .artifacts .release
