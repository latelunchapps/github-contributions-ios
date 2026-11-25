#!/usr/bin/env bash
# Xcode Cloud runs this before each xcodebuild action. The release workflow
# only archives, and only for tags that begin with `v`.
#
# The marketing version comes from the tag, and the build number is Xcode
# Cloud's own counter (CI_BUILD_NUMBER, whose Next Build Number in App Store
# Connect is above 21, the last number used before Xcode Cloud). Both land
# in the MARKETING_VERSION / CURRENT_PROJECT_VERSION build settings that the
# app's and the widget's Info.plists read, so the binary carries the same
# build number App Store Connect shows. Xcode Cloud does not take extra
# xcodebuild arguments, so this script rewrites the project-level
# placeholders (0.0.0 / 1) in this throwaway clone. Nothing is committed.
#
# This repository is public. Never put a secret in this script.
set -euo pipefail

if [ "${CI_XCODE_CLOUD:-}" != "TRUE" ]; then
  echo "This script rewrites project.pbxproj, so it only runs on Xcode Cloud." >&2
  exit 1
fi

cd "${CI_PRIMARY_REPOSITORY_PATH:?CI_PRIMARY_REPOSITORY_PATH is not set.}"

tag="${CI_TAG:-}"
if [ -z "$tag" ]; then
  echo "CI_TAG is not set. Start this workflow from a vX.Y.Z tag." >&2
  exit 1
fi

# Require the leading `v`: the legacy tags (`1.6.1` and earlier) are bare
# versions, and must never start a release build.
version="${tag#v}"
if [ "$version" = "$tag" ] || ! printf '%s' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "Tag '${tag}' is not a vX.Y.Z release tag." >&2
  exit 1
fi

build="${CI_BUILD_NUMBER:-}"
if ! printf '%s' "$build" | grep -Eq '^[0-9]+$'; then
  echo "CI_BUILD_NUMBER '${build}' is not a build number." >&2
  exit 1
fi

pbxproj="Contributions.xcodeproj/project.pbxproj"

# Sets every `KEY = …;` line in the project file to `KEY = VALUE;`, then
# checks that the rewrite happened. sed exits 0 even when nothing matches.
set_build_setting() {
  local key="$1" value="$2" total updated

  total="$(grep -cE "^[[:space:]]*${key} = [^;]*;$" "$pbxproj" || true)"
  if [ "$total" -eq 0 ]; then
    echo "No ${key} setting found in ${pbxproj}." >&2
    exit 1
  fi

  sed -i '' -E "s/^([[:space:]]*${key} = )[^;]*;$/\1${value};/" "$pbxproj"

  updated="$(grep -cE "^[[:space:]]*${key} = ${value//./\\.};$" "$pbxproj" || true)"
  if [ "$updated" -ne "$total" ]; then
    echo "Set ${updated} of ${total} ${key} settings in ${pbxproj}." >&2
    exit 1
  fi
}

set_build_setting MARKETING_VERSION "$version"
set_build_setting CURRENT_PROJECT_VERSION "$build"

echo "Building ${version} (${build})"
