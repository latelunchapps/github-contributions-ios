# CLAUDE.md

Guidance for Claude Code when working in this repository.

Contribution Graphs for GitHub (`github-contributions-ios`) is a public iOS app (iOS 17+, Xcode 26+, Swift 6) that shows GitHub contribution graphs in the app and on the Home Screen.

There is no workspace and no CocoaPods: open `Contributions.xcodeproj`. Dependencies are Swift packages, including two local packages in the repo root: `NetworkKit` (GitHub data, SwiftSoup) and `InterfaceKit` (shared UI).

## Build

This repo has no unit or UI test targets, and neither local package declares tests. Before opening a PR, build on an available iOS Simulator. These paths sit outside the git work tree so they survive `actions/checkout` (`clean: true` runs `git clean -ffdx`, which would delete any DerivedData or SourcePackages inside the repo). They are also separate from Ander's personal `~/Library/Developer/Xcode/DerivedData`, so CI builds do not collide with local Xcode. On the self-hosted Mac runner, always use these flags so incremental compiles, SPM checkouts, and the compilation cache reuse work across jobs.

```bash
DD="$HOME/Library/Developer/Xcode/DerivedData-ci/github-contributions-ios"
# List simulators with `xcrun simctl list devices available` and prefer an id
# if two devices share a name (this happened with "iPhone 16" on the runner).
DEST="platform=iOS Simulator,id=<id>"
CACHE_FLAGS=(
  -derivedDataPath "$DD"
  -clonedSourcePackagesDirPath "$DD/SourcePackages"
  COMPILATION_CACHE_ENABLE_CACHING=YES
  COMPILATION_CACHE_CAS_PATH="$DD/CompilationCache.noindex"
)

# App (scheme name is App; target name is Contributions)
xcodebuild -project Contributions.xcodeproj -scheme App -destination "$DEST" "${CACHE_FLAGS[@]}" build

# Widget extension (when you change widget or shared kit code)
xcodebuild -project Contributions.xcodeproj -scheme Widget -destination "$DEST" "${CACHE_FLAGS[@]}" build
```

`NetworkKit` and `InterfaceKit` are iOS-only, so `swift test` / `swift build` on macOS will not work for them. Report the build commands and results in the PR description, and say that there is no test target.

## Layout

- `Contributions/` — app target
- `ContributionsWidget/` — widget extension
- `NetworkKit/` — local SPM package
- `InterfaceKit/` — local SPM package
- `ci_scripts/` — the Xcode Cloud build script (tag → version, `CI_BUILD_NUMBER` → build)

Schemes: `App`, `Widget`. Do not confuse the `App` scheme with the `Contributions` target name.

## Releases and versioning

Releasing is one step: an annotated `vX.Y.Z` tag on the default branch, pushed with `git push origin --follow-tags`. A lightweight tag isn't pushed by `--follow-tags`, so no build starts. Legacy tags (`1.6.2` and earlier) are bare versions. They never start a build.

Release builds run on **Xcode Cloud**. The workflow is configured in App Store Connect and Xcode, not in the repo:
- start condition: Tag Changes, tags beginning with `v` (never a branch trigger, and no pull-request workflows);
- one archive action for TestFlight and App Store;
- Clean environment and restricted editing.

`ci_scripts/ci_pre_xcodebuild.sh` (next to `Contributions.xcodeproj`, mode `100755`, in no target) sets both numbers:
- the **marketing version** from `CI_TAG`, which must be `vX.Y.Z`;
- the **build number** from `CI_BUILD_NUMBER`, Xcode Cloud's own counter. Its Next Build Number (App Store Connect → Xcode Cloud → Settings → Build Number) must be above 21, the last build shipped before Xcode Cloud. Never set it back below a shipped number.

It writes both over the project-level `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` placeholders (`0.0.0` / `1`) in the throwaway clone, checks that every one changed, and refuses to run unless `CI_XCODE_CLOUD` is `TRUE`. This repo is public, so the script must never hold a secret. It needs none: signing is automatic in App Store Connect.

Both `Info.plist` files read `$(MARKETING_VERSION)` / `$(CURRENT_PROJECT_VERSION)`. The app and the widget inherit the same project-level values, so their versions always match, and local builds report 0.0.0 (1). Never commit a version or build number, and never set either at target level. Don't run `agvtool`: it would rewrite the placeholders.

## Rules

- Keep PRs small and focused on the requested issue.
- Never push to the default branch. Always work on a new branch and open a PR.
- Never read, print, commit, or change secrets, tokens, or private keys.
- Never change pricing or store configuration unless the issue explicitly asks for it, and if you do, call that out clearly in the PR description.
- When implementing an issue, open the PR with `Closes #N` in the body, and report build results there. Do not merge.
