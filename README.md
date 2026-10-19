# Kick It — selected code sample

Kick It is a Flutter/Supabase project for discovering activities and helping people make plans and maintain social connections. This folder contains a small, offline-reviewable selection of its Dart logic. It is not the complete mobile app, a runnable UI, or evidence of deployment or user outcomes.

## Verified scope

| Included code | What the checks establish |
| --- | --- |
| `lib/utils/content_format.dart` | Description cleanup, internal-tag filtering, distance formatting, map-link construction, and basic city/state formatting |
| `lib/services/recent_image_cache.dart` | A ten-entry, process-local recent-image window, repeat refresh, eviction, and filtering |
| `lib/models/tribe_connection.dart` | Parsing a synthetic connection record and producing connection-status and health labels |

The 26 checks in `test/offline_checks.dart` pass with Dart 3.11.5. These are characterization checks created for this portfolio preparation, not a claim that the original app had this test coverage. Map links are constructed as strings; no URL is opened.

## Architecture

The larger source uses Flutter and FlutterFlow-generated structure, UI screens, service classes, and Supabase client integration. Its inspected manifest lists Supabase 2.7.0 and supabase_flutter 2.9.0. None of those services or packages is needed by this sample. The included code is pure Dart: presentation helpers, an in-memory ordered set, and a data model extracted from the connection service.

The full authentication, backend schema and policies, activity ingestion, planning, messaging, payments, and mobile UI are outside this sample and were not validated here.

## Kyle's role and AI assistance

Kyle is the project owner identified for this portfolio. The source includes FlutterFlow-generated structure. This review does not establish per-file authorship or the exact division of the original implementation between Kyle and AI tools; those details need Kyle's confirmation before submission. Do not describe this sample as entirely hand-written or solely authored on the basis of this review.

Codex selected the files, extracted the model, replaced identifying comment examples, wrote this README and the synthetic checks, and ran those checks during portfolio preparation. It did not add product features. See `SCOPE.md` for the exact edits.

## Setup and reproducible checks

Use a Dart SDK compatible with Dart 3.11.5 (also bundled with the reviewed Flutter installation). From this folder:

```sh
dart --disable-dart-dev test/offline_checks.dart
```

Expected output: `PASS: 26 offline characterization checks.` No package install, backend, environment file, credential, or network connection is needed. Only `dart:collection` and core Dart are used. The original Flutter dependency manifest and lockfile are intentionally not included because they describe the omitted application.

## Honest limitations

- This is a narrow code-reading sample; it does not demonstrate the complete Flutter UI or Supabase behavior.
- The location formatter retains a source defect: several regex end anchors are escaped, so a state abbreviation with a ZIP code is not normalized as intended. The tests explicitly record this behavior; it was not silently fixed for the application.
- Description cleanup is display formatting, not a security-grade HTML sanitizer. Map URLs are not validated for all geographic edge cases.
- Connection timestamps are trusted, and missing activity timestamps fall back to the current time. Health values are not clamped by this model; its labels are product rules, not validated measures of social well-being.
- No claims are made about adoption, health outcomes, accessibility, production readiness, or performance at scale.

No open-source license has been selected. This repository is a selected portfolio code sample; public availability does not grant an open-source license.
