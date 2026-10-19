# Selection and sanitization

Included: three Dart source files and one synthetic test entrypoint, plus review documentation and an ignore file.

- `content_format.dart`: original logic retained. Concrete addresses and venue examples were removed from comments; machine-tag examples were replaced with synthetic identifiers.
- `recent_image_cache.dart`: source retained with line endings normalized.
- `tribe_connection.dart`: the `TribeConnection` class was extracted from `lib/services/tribe_health_service.dart`. Backend imports, network methods and action enum are omitted. A selection comment was added.
- `offline_checks.dart`: new synthetic characterization checks authored during portfolio preparation.

Excluded: app entrypoints, generated FlutterFlow UI, platform projects, original manifests, all credential/configuration files including every `.env` variant, Supabase/Firebase deployments and migrations, provider/payment/email integrations, signing material, user data, photos and other binary assets, personal and business documents, grants and correspondence, caches, generated output, original Git metadata and history.

Only these allowlisted files form this sample. No production exports or original test fixtures were copied. Private source locations and hashes are retained separately in the parent review manifest, not in this folder.
