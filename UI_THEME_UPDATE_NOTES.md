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

## What I could NOT do: build or launch the app

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
`data/pubspec.yaml`, and several network/auth/service files, this looks
like it's already what that in-progress work is untangling — so I
deliberately did not start guessing at dependency version bumps across
`riverpod_lint`/`build_verify`/`analyzer` blind. That's real surgery, not a
UI pass, and duplicating or fighting an in-flight fix seemed like the wrong
call to make unsupervised overnight.

**Net result: I could not actually run the app to screenshot/visually
verify these changes tonight.** They're theme-level and narrowly scoped
(4 files, no logic changes, each one individually easy to review), and
`style` compiles clean — but nobody has looked at them rendered on a real
screen yet. Please build (once the dependency issue above is sorted) and
sanity-check before merging.

## Scope note

This only touches the shared `style`/`AppPage` chrome — it does **not**
attempt a full per-screen UI pass (there are ~182 files under `khelo/lib/ui/`,
which is a much bigger undertaking that deserves a real design review, not
something to do blind overnight on a shared repo). If a fuller re-theme
pass is wanted, that's a separate, larger piece of work.
