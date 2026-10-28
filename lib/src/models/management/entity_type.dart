// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import 'agent.dart';
import 'json_reader.dart';
import 'managed_user.dart';

/// The attributes of a user type or an agent type, keyed by attribute name, exactly as the
/// server returns them. Each value is a property definition such as
/// `{'type': 'string', 'required': true, 'unique': true}`; `string`, `email`, `mobile` and
/// `number` attributes may set `credential`, `enum` and `regex`, an `object` attribute nests
/// `properties`, and an `array` attribute describes its `items`.
typedef EntityTypeSchema = Map<String, dynamic>;

/// The attributes a type maps to the identity's display name and primary contacts. An agent type
/// uses [display] only.
class EntityTypeSystemAttributes {
  final String? display;
  final String? primaryEmail;
  final String? primaryMobile;

  const EntityTypeSystemAttributes({this.display, this.primaryEmail, this.primaryMobile});

  factory EntityTypeSystemAttributes.fromJson(Map<String, dynamic> json) => EntityTypeSystemAttributes(
        display: readOptionalString(json, 'display'),
        primaryEmail: readOptionalString(json, 'primaryEmail'),
        primaryMobile: readOptionalString(json, 'primaryMobile'),
      );

  static EntityTypeSystemAttributes? _tryFromJson(Object? value) =>
      value is Map ? EntityTypeSystemAttributes.fromJson(readMap(value)) : null;

  Map<String, dynamic> toJson() => {
        if (display != null) 'display': display,
        if (primaryEmail != null) 'primaryEmail': primaryEmail,
        if (primaryMobile != null) 'primaryMobile': primaryMobile,
      };
}

/// A user type with its attribute schema.
class ManagedUserTypeDetails extends ManagedUserType {
  final EntityTypeSchema schema;
  final EntityTypeSystemAttributes? systemAttributes;

  const ManagedUserTypeDetails({
    required super.id,
    required super.handle,
    super.displayName,
    super.ouId,
    super.ouHandle,
    super.allowSelfRegistration,
    super.isReadOnly,
    this.schema = const {},
    this.systemAttributes,
  });

  factory ManagedUserTypeDetails.fromJson(Map<String, dynamic> json) {
    final base = ManagedUserType.fromJson(json);
    return ManagedUserTypeDetails(
      id: base.id,
      handle: base.handle,
      displayName: base.displayName,
      ouId: base.ouId,
      ouHandle: base.ouHandle,
      allowSelfRegistration: base.allowSelfRegistration,
      isReadOnly: base.isReadOnly,
      schema: readMap(json['schema']),
      systemAttributes: EntityTypeSystemAttributes._tryFromJson(json['systemAttributes']),
    );
  }
}

/// Payload for creating a user type.
class CreateUserTypeRequest {
  final String handle;
  final String displayName;
  final String ouId;
  final EntityTypeSchema schema;
  final bool? allowSelfRegistration;
  final EntityTypeSystemAttributes? systemAttributes;

  const CreateUserTypeRequest({
    required this.handle,
    required this.displayName,
    required this.ouId,
    required this.schema,
    this.allowSelfRegistration,
    this.systemAttributes,
  });

  Map<String, dynamic> toJson() => {
        if (allowSelfRegistration != null) 'allowSelfRegistration': allowSelfRegistration,
        'displayName': displayName,
        'handle': handle,
        'ouId': ouId,
        'schema': schema,
        if (systemAttributes != null) 'systemAttributes': systemAttributes!.toJson(),
      };
}

/// Payload for updating a user type. The handle is immutable.
class UpdateUserTypeRequest {
  final String displayName;
  final String ouId;
  final EntityTypeSchema schema;
  final bool? allowSelfRegistration;
  final EntityTypeSystemAttributes? systemAttributes;

  const UpdateUserTypeRequest({
    required this.displayName,
    required this.ouId,
    required this.schema,
    this.allowSelfRegistration,
    this.systemAttributes,
  });

  Map<String, dynamic> toJson() => {
        if (allowSelfRegistration != null) 'allowSelfRegistration': allowSelfRegistration,
        'displayName': displayName,
        'ouId': ouId,
        'schema': schema,
        if (systemAttributes != null) 'systemAttributes': systemAttributes!.toJson(),
      };
}

/// An agent type with its attribute schema.
class AgentTypeDetails extends AgentType {
  final EntityTypeSchema schema;

  /// Only [EntityTypeSystemAttributes.display] applies to an agent type.
  final EntityTypeSystemAttributes? systemAttributes;

  const AgentTypeDetails({
    required super.id,
    required super.handle,
    required super.displayName,
    required super.ouId,
    super.ouHandle,
    super.allowSelfRegistration,
    this.schema = const {},
    this.systemAttributes,
  });

  factory AgentTypeDetails.fromJson(Map<String, dynamic> json) {
    final base = AgentType.fromJson(json);
    return AgentTypeDetails(
      id: base.id,
      handle: base.handle,
      displayName: base.displayName,
      ouId: base.ouId,
      ouHandle: base.ouHandle,
      allowSelfRegistration: base.allowSelfRegistration,
      schema: readMap(json['schema']),
      systemAttributes: EntityTypeSystemAttributes._tryFromJson(json['systemAttributes']),
    );
  }
}

/// Payload for creating an agent type.
class CreateAgentTypeRequest {
  final String handle;
  final String displayName;
  final String ouId;
  final EntityTypeSchema schema;
  final bool? allowSelfRegistration;

  /// Only [EntityTypeSystemAttributes.display] is sent.
  final EntityTypeSystemAttributes? systemAttributes;

  const CreateAgentTypeRequest({
    required this.handle,
    required this.displayName,
    required this.ouId,
    required this.schema,
    this.allowSelfRegistration,
    this.systemAttributes,
  });

  Map<String, dynamic> toJson() => {
        if (allowSelfRegistration != null) 'allowSelfRegistration': allowSelfRegistration,
        'displayName': displayName,
        'handle': handle,
        'ouId': ouId,
        'schema': schema,
        if (systemAttributes?.display case final display?) 'systemAttributes': {'display': display},
      };
}

/// Payload for updating an agent type.
class UpdateAgentTypeRequest {
  final String displayName;
  final String ouId;
  final EntityTypeSchema schema;

  /// Only [EntityTypeSystemAttributes.display] is sent.
  final EntityTypeSystemAttributes? systemAttributes;

  const UpdateAgentTypeRequest({
    required this.displayName,
    required this.ouId,
    required this.schema,
    this.systemAttributes,
  });

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'ouId': ouId,
        'schema': schema,
        if (systemAttributes?.display case final display?) 'systemAttributes': {'display': display},
      };
}
