# UI theme update — branch `ui-theme-update`

Written by an automated pass, done overnight without a live review — read this
before merging or building on top of it.

## Why a separate branch

`main` had uncommitted local changes (network/auth/service files, both
`pubspec.yaml`s) sitting in the working tree when this started — clearly
someone's in-progress work. Rather than touch that working tree, this was
done in a separate `git worktree` checked out fresh from `main` at commit
`827779a`, on branch `ui-theme-update`. Nothing on `main` — committed or
uncommitted — was touched. Nothing has been pushed.

## What changed (4 files, all in the shared `style`/`khelo` chrome — no
per-screen edits)

1. **`style/lib/button/back_button.dart`** and
   **`khelo/lib/components/app_page.dart`** — back buttons now render the
   iOS-style chevron (`CupertinoIcons.back`) on Android too, not just iOS.
   Previously `AppPage`'s Material branch fell through to Flutter's default
   `Icons.arrow_back` on Android whenever a screen didn't pass an explicit
   `leading` widget; `backButton()` (used directly by 4 screens) also forced
   the Android arrow. Both now match the chevron the Cupertino branch
   already used. This is additive — screens that already hand-roll their own
   `CupertinoIcons.chevron_back` (search_screen, user_detail_screen,
   team_detail_screen) are untouched and were already consistent.

2. **`style/lib/text/app_text_style.dart`** — added negative letter-spacing
   to `subtitle1`, `body1`, `body2`, `button`, `caption`. `header1–4` and
   `subtitle2/3` already had it (from the brand-theme commit); this just
   finishes the pattern across the rest of the type scale instead of leaving
   half the styles untracked.

3. **`style/lib/theme/colors.dart`**:
   - Added a `CardThemeData` to both light and dark `ThemeData` (flat,
     `elevation: 0`, `surfaceLightColor`/`surfaceDarkColor` fill, 16px
     radius). There was no `CardTheme` before, so every `Card` was falling
     back to Material3's default elevation/shadow — this flattens it to
     match the rest of the app's already-flat surface language.
   - **Left the brand red AppBar as-is** (commit 827779a's choice) — did
     not flatten/transparent it. That's a bigger, more opinionated call
     than "add polish," and it directly contradicts a very recent
     deliberate branding commit — not something to silently override
     unsupervised. If you want that look too (matching a flatter,
     no-color-block header), it's a one-line `appBarTheme.backgroundColor`
     change in this file (both light/dark blocks) — happy to do it, just
     flagging it as a call worth someone actually looking at.
   - Fixed 4 **pre-existing** compile errors in the date/time picker
     `inputDecorationTheme` blocks (`InputDecorationThemeData` vs
     `InputDecorationTheme` type mismatch) — unrelated to the UI work,
     just needed to get `style` analyzing clean on Flutter 3.44.9. Marked
     inline with `NOTE(pre-existing, not part of this UI pass)`.

## Update: the app now builds and runs — see the second commit

The section below is what I originally wrote when I'd only gotten `style`
to analyze clean and hadn't managed to build `khelo` at all. I was asked to
keep going and actually get it running, so there's a second commit
(`fix: get khelo building and launching on current Flutter stable`) on top
of the UI-theme one. Leaving the original writeup below since the specific
conflicts are still useful context, but the bottom line changed:
**`flutter run` now launches the app on a real device, sign-in screen
renders, no crash.**

The second commit fixes, all pre-existing and unrelated to the UI-theme
changes:

- **A real, currently-live crash bug**: `MainActivity.kt` was still under
  the pre-rebrand `com.canopas.khelo` package while `build.gradle`'s
  `applicationId`/`namespace` were already `com.cricheros.app`. Every build
  since the rebrand commit crashed on launch with `ClassNotFoundException`
  — this wasn't specific to my environment. Moved the file, fixed the
  package declaration.
- `fluttertoast` bumped 8.2.8 → 8.2.14 (latest within the existing `^8.2.8`
  constraint) — 8.2.8 references removed Flutter v1-embedding classes and
  fails native Kotlin compilation on current Flutter.
- `intl` widened to `^0.20.0` (see below).
- `riverpod_lint` and `build_verify` **removed** rather than upgraded —
  every version compatible with the analyzer this Flutter SDK bundles also
  needs either `riverpod` 3.x (real breaking upgrade, app is on
  `hooks_riverpod ^2.6.1`) or `freezed_annotation ^3.0.0` (cascades into
  regenerating 47+ `.freezed.dart` files). Neither package was actually
  wired up — no `custom_lint` entry in `analysis_options.yaml`, and nothing
  in CI/scripts references `build_verify` — so removing them has zero
  functional effect today. Re-add once riverpod/freezed are deliberately
  upgraded as their own piece of work.
- Fixed the `l10n.yaml` / `flutter_gen` synthetic-package breakage (see
  original section below) by pointing output at a real `lib/l10n/` path.
- Hand-reconstructed `lib/firebase_options.dart` (Android-only) from the
  already-committed `google-services.json`, since FlutterFire CLI needs an
  interactive `firebase login` I don't have. Not committed — already
  covered by `.gitignore`, stays local only.

## Original section (kept for context — the conflicts described below are
still real, I just resolved them instead of stopping)

`style` analyzes clean (`flutter analyze` → 1 unrelated pre-existing
deprecation info, nothing else).

`khelo` (the actual app) **could not be built** in this environment —
`flutter pub get` fails with a real dependency-resolution conflict, nothing
to do with this branch's changes:

- `khelo/pubspec.yaml` pins `intl: ^0.19.0`, but `flutter_localizations`
  on current Flutter stable (3.44.9, what's installed here) requires
  `intl 0.20.2`. Widening that constraint alone doesn't fix it, though —
- doing so exposes a much deeper transitive conflict between
  `riverpod_lint`, `build_verify`, `analyzer`, and Dart's `macros`/`_macros`
  packages, that current Flutter's bundled toolchain can't resolve.

This project doesn't pin a Flutter version anywhere (CI's
`.github/workflows/analyze.yml` uses `subosito/flutter-action` on the
`stable` channel, unpinned) — so this isn't specific to this machine, it'll
hit CI and anyone else on current stable too.

Given `main`'s uncommitted changes already touch `khelo/pubspec.yaml`,
`data/pubspec.yaml`, and several network/auth/service files, this looked
like it might already be what that in-progress work was untangling — I
initially left it alone for that reason, then was asked to push through and
fix it anyway (see above). Worth flagging to whoever owns that uncommitted
work: check whether it duplicates or conflicts with what's in the second
commit here.

## Scope note

This only touches the shared `style`/`AppPage` chrome — it does **not**
attempt a full per-screen UI pass (there are ~182 files under `khelo/lib/ui/`,
which is a much bigger undertaking that deserves a real design review, not
something to do blind overnight on a shared repo). If a fuller re-theme
pass is wanted, that's a separate, larger piece of work.
