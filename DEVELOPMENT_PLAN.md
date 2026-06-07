# CricHeros — Development Plan

This document outlines the phased roadmap for building **CricHeros**, a CricHeroes-style cricket scoring and tournament management platform built on Flutter + Firebase. The codebase is forked from the open-source [Khelo](https://github.com/canopas/khelo) project.

---

## Phase 1 — Foundation (Weeks 1–4)

The foundation sprint: rebrand, stabilize the codebase, and get a shippable build into the Play Store pipeline.

- **Rebrand** — rename app from "Khelo" to "CricHeros" across packages, manifests, application id (`com.cricheros.app`), and all imports.
- **Firebase setup** — provision the CricHeros Firebase project (Auth, Firestore, Storage, Cloud Functions, Crashlytics, Messaging) and wire up `firebase_options`.
- **Dependency upgrades** — upgrade Flutter, plugins, and the toolchain; resolve breaking changes; raise compile/target SDK to 34.
- **Shareable scorecards** — deep-linkable live and completed match scorecards that can be shared externally.
- **Public match feed** — a discoverable feed of ongoing public matches.
- **Play Store prep** — signing config, app bundle build, store listing assets, privacy policy, and internal testing track.

**Exit criteria:** branded app builds and runs on Android & iOS, connects to the CricHeros Firebase backend, and an internal-testing build is live on the Play Store.

---

## Phase 2 — Social & Discovery (Weeks 5–10)

Turn the scoring app into a social cricket network.

- **Social features** — follow players/teams, activity feed, reactions and comments on matches.
- **Player discovery** — search and discover players by name, location, and role.
- **Advanced stats** — career and season aggregates, leaderboards, batting/bowling/fielding deep stats, and match-up analytics.
- **Association management** — clubs, leagues and associations with member management and branded pages.

**Exit criteria:** users can find and follow each other, view rich statistics, and associations can manage their members and tournaments.

---

## Phase 3 — Monetization & Premium (Weeks 11–16)

Introduce revenue streams and premium experiences.

- **PRO subscription** — tiered subscriptions unlocking advanced analytics, branding, and higher limits (in-app purchases / billing).
- **Live streaming** — stream matches with an integrated scorecard overlay.
- **Sponsorship system** — sponsor placements on teams, tournaments and streams, with reporting for sponsors.

**Exit criteria:** PRO subscriptions are purchasable, matches can be streamed live, and sponsorship inventory can be sold and tracked.

---

## Tracking

- Phase progress is tracked via GitHub issues using the [bug report](.github/ISSUE_TEMPLATE/bug_report.md) and [feature request](.github/ISSUE_TEMPLATE/feature_request.md) templates.
- This plan is a living document and will be revised as phases complete.
