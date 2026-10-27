// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import 'json_reader.dart';

/// The kinds of entity a design resolves for.
enum DesignEntityType {
  /// An application, by its identifier.
  application('APP'),

  /// An organization unit, by its identifier.
  organizationUnit('OU');

  /// The wire value.
  final String value;

  const DesignEntityType(this.value);
}

/// A theme as listed.
class DesignThemeSummary {
  final String id;
  final String handle;
  final String displayName;
  final String? description;
  final String? defaultColorScheme;
  final String? primaryColor;
  final bool isReadOnly;
  final String? createdAt;
  final String? updatedAt;

  const DesignThemeSummary({
    required this.id,
    required this.handle,
    required this.displayName,
    this.description,
    this.defaultColorScheme,
    this.primaryColor,
    this.isReadOnly = false,
    this.createdAt,
    this.updatedAt,
  });

  factory DesignThemeSummary.fromJson(Map<String, dynamic> json) => DesignThemeSummary(
        id: readString(json, 'id'),
        handle: readString(json, 'handle'),
        displayName: readString(json, 'displayName'),
        description: readOptionalString(json, 'description'),
        defaultColorScheme: readOptionalString(json, 'defaultColorScheme'),
        primaryColor: readOptionalString(json, 'primaryColor'),
        isReadOnly: readOptionalBool(json, 'isReadOnly') ?? false,
        createdAt: readOptionalString(json, 'createdAt'),
        updatedAt: readOptionalString(json, 'updatedAt'),
      );
}

/// A theme with its configuration. [theme] is kept as the server describes it (color schemes,
/// typography, shape, ...).
class DesignTheme {
  final String id;
  final String handle;
  final String displayName;
  final String? description;
  final Map<String, dynamic> theme;
  final bool isReadOnly;
  final String? createdAt;
  final String? updatedAt;

  const DesignTheme({
    required this.id,
    required this.handle,
    required this.displayName,
    this.description,
    this.theme = const {},
    this.isReadOnly = false,
    this.createdAt,
    this.updatedAt,
  });

  factory DesignTheme.fromJson(Map<String, dynamic> json) => DesignTheme(
        id: readString(json, 'id'),
        handle: readString(json, 'handle'),
        displayName: readString(json, 'displayName'),
        description: readOptionalString(json, 'description'),
        theme: readMap(json['theme']),
        isReadOnly: readOptionalBool(json, 'isReadOnly') ?? false,
        createdAt: readOptionalString(json, 'createdAt'),
        updatedAt: readOptionalString(json, 'updatedAt'),
      );
}

/// Payload for creating or updating a theme.
class DesignThemeRequest {
  final String handle;
  final String displayName;
  final String? description;
  final Map<String, dynamic> theme;

  const DesignThemeRequest({required this.handle, required this.displayName, required this.theme, this.description});

  Map<String, dynamic> toJson() => {
        'handle': handle,
        'displayName': displayName,
        if (description != null) 'description': description,
        'theme': theme,
      };
}

/// A layout as listed.
class DesignLayoutSummary {
  final String id;
  final String handle;
  final String displayName;
  final String? description;
  final bool isReadOnly;
  final String? createdAt;
  final String? updatedAt;

  const DesignLayoutSummary({
    required this.id,
    required this.handle,
    required this.displayName,
    this.description,
    this.isReadOnly = false,
    this.createdAt,
    this.updatedAt,
  });

  factory DesignLayoutSummary.fromJson(Map<String, dynamic> json) => DesignLayoutSummary(
        id: readString(json, 'id'),
        handle: readString(json, 'handle'),
        displayName: readString(json, 'displayName'),
        description: readOptionalString(json, 'description'),
        isReadOnly: readOptionalBool(json, 'isReadOnly') ?? false,
        createdAt: readOptionalString(json, 'createdAt'),
        updatedAt: readOptionalString(json, 'updatedAt'),
      );
}

/// A layout with its configuration, kept in [layout] as the server describes it.
class DesignLayout {
  final String id;
  final String handle;
  final String displayName;
  final String? description;
  final Map<String, dynamic> layout;
  final bool isReadOnly;
  final String? createdAt;
  final String? updatedAt;

  const DesignLayout({
    required this.id,
    required this.handle,
    required this.displayName,
    this.description,
    this.layout = const {},
    this.isReadOnly = false,
    this.createdAt,
    this.updatedAt,
  });

  factory DesignLayout.fromJson(Map<String, dynamic> json) => DesignLayout(
        id: readString(json, 'id'),
        handle: readString(json, 'handle'),
        displayName: readString(json, 'displayName'),
        description: readOptionalString(json, 'description'),
        layout: readMap(json['layout']),
        isReadOnly: readOptionalBool(json, 'isReadOnly') ?? false,
        createdAt: readOptionalString(json, 'createdAt'),
        updatedAt: readOptionalString(json, 'updatedAt'),
      );
}

/// Payload for creating or updating a layout.
class DesignLayoutRequest {
  final String handle;
  final String displayName;
  final String? description;
  final Map<String, dynamic> layout;

  const DesignLayoutRequest({
    required this.handle,
    required this.displayName,
    required this.layout,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'handle': handle,
        'displayName': displayName,
        if (description != null) 'description': description,
        'layout': layout,
      };
}

/// The theme and layout that apply to an application or organization unit, after inheritance.
/// Either is `null` when none applies.
class ResolvedDesign {
  final Map<String, dynamic>? theme;
  final Map<String, dynamic>? layout;

  const ResolvedDesign({this.theme, this.layout});

  factory ResolvedDesign.fromJson(Map<String, dynamic> json) =>
      ResolvedDesign(theme: readOptionalMap(json['theme']), layout: readOptionalMap(json['layout']));
}
