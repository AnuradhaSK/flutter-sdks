// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import 'json_reader.dart';

/// Translations keyed by namespace, then by key.
typedef TranslationBundle = Map<String, Map<String, String>>;

TranslationBundle _readBundle(Object? value) => {
      for (final namespace in readMap(value).entries)
        if (namespace.value is Map)
          namespace.key: {
            for (final entry in readMap(namespace.value).entries)
              if (entry.value is String) entry.key: entry.value as String,
          },
    };

/// The translations of one language, after the server's overrides are applied to its defaults.
class LanguageTranslations {
  final String language;
  final int? totalResults;
  final TranslationBundle translations;

  const LanguageTranslations({required this.language, required this.translations, this.totalResults});

  factory LanguageTranslations.fromJson(Map<String, dynamic> json) => LanguageTranslations(
        language: readString(json, 'language'),
        totalResults: readOptionalInt(json, 'totalResults'),
        translations: _readBundle(json['translations']),
      );
}

/// One translation.
class Translation {
  final String language;
  final String namespace;
  final String key;
  final String value;

  const Translation({required this.language, required this.namespace, required this.key, required this.value});

  factory Translation.fromJson(Map<String, dynamic> json) => Translation(
        language: readString(json, 'language'),
        namespace: readString(json, 'namespace'),
        key: readString(json, 'key'),
        value: readString(json, 'value'),
      );
}

/// Payload for setting many translations of a language at once.
class SetTranslationsRequest {
  final TranslationBundle translations;

  const SetTranslationsRequest({required this.translations});

  Map<String, dynamic> toJson() => {'translations': translations};
}

/// Payload for setting one translation.
class SetTranslationRequest {
  final String value;

  const SetTranslationRequest({required this.value});

  Map<String, dynamic> toJson() => {'value': value};
}
