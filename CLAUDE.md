# CLAUDE.md

Guidance for Claude Code when working in this repository.

Contribution Graphs for GitHub (`github-contributions-ios`) is a public iOS app (iOS 16.6+, Xcode 26+, Swift 6) that shows GitHub contribution graphs in the app and on the Home Screen.

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

Schemes: `App`, `Widget`. Do not confuse the `App` scheme with the `Contributions` target name.

Do not bump version or build numbers by hand. Release versioning is handled by `bundle exec fastlane ios prepare_release` on a `release/X.Y.Z` branch.

## Rules

- Keep PRs small and focused on the requested issue.
- Never push to `master`. Always work on a new branch and open a PR.
- Never read, print, commit, or change secrets, tokens, or private keys.
- Never change pricing or store configuration unless the issue explicitly asks for it, and if you do, call that out clearly in the PR description.
- When implementing an issue, open the PR with `Closes #N` in the body, and report build results there. Do not merge.
