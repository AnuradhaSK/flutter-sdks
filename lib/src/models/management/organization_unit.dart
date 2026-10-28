// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import 'json_reader.dart';

/// An organization unit as listed by the management API.
class BasicOrganizationUnit {
  final String id;

  /// The unit's handle, unique among its siblings; a path of handles (`engineering/platform`)
  /// addresses a unit in the tree.
  final String handle;
  final String name;
  final String? description;
  final String? logoUrl;
  final bool isReadOnly;
  final String? createdAt;
  final String? updatedAt;

  const BasicOrganizationUnit({
    required this.id,
    required this.handle,
    required this.name,
    this.description,
    this.logoUrl,
    this.isReadOnly = false,
    this.createdAt,
    this.updatedAt,
  });

  factory BasicOrganizationUnit.fromJson(Map<String, dynamic> json) => BasicOrganizationUnit(
        id: readString(json, 'id'),
        handle: readString(json, 'handle'),
        name: readString(json, 'name'),
        description: readOptionalString(json, 'description'),
        logoUrl: readOptionalString(json, 'logoUrl'),
        isReadOnly: readOptionalBool(json, 'isReadOnly') ?? false,
        createdAt: readOptionalString(json, 'createdAt'),
        updatedAt: readOptionalString(json, 'updatedAt'),
      );
}

/// The settable fields shared by every organization unit write.
abstract class _OrganizationUnitFields {
  final String handle;
  final String name;
  final String? description;
  final String? themeId;
  final String? layoutId;
  final String? authFlowId;
  final String? registrationFlowId;
  final bool? isRegistrationFlowEnabled;
  final String? recoveryFlowId;
  final bool? isRecoveryFlowEnabled;
  final String? signOutFlowId;
  final String? logoUrl;
  final String? tosUri;
  final String? policyUri;
  final String? cookiePolicyUri;

  const _OrganizationUnitFields({
    required this.handle,
    required this.name,
    this.description,
    this.themeId,
    this.layoutId,
    this.authFlowId,
    this.registrationFlowId,
    this.isRegistrationFlowEnabled,
    this.recoveryFlowId,
    this.isRecoveryFlowEnabled,
    this.signOutFlowId,
    this.logoUrl,
    this.tosUri,
    this.policyUri,
    this.cookiePolicyUri,
  });

  Map<String, dynamic> _fieldsJson() => {
        'handle': handle,
        'name': name,
        if (description != null) 'description': description,
        if (themeId != null) 'themeId': themeId,
        if (layoutId != null) 'layoutId': layoutId,
        if (authFlowId != null) 'authFlowId': authFlowId,
        if (registrationFlowId != null) 'registrationFlowId': registrationFlowId,
        if (isRegistrationFlowEnabled != null) 'isRegistrationFlowEnabled': isRegistrationFlowEnabled,
        if (recoveryFlowId != null) 'recoveryFlowId': recoveryFlowId,
        if (isRecoveryFlowEnabled != null) 'isRecoveryFlowEnabled': isRecoveryFlowEnabled,
        if (signOutFlowId != null) 'signOutFlowId': signOutFlowId,
        if (logoUrl != null) 'logoUrl': logoUrl,
        if (tosUri != null) 'tosUri': tosUri,
        if (policyUri != null) 'policyUri': policyUri,
        if (cookiePolicyUri != null) 'cookiePolicyUri': cookiePolicyUri,
      };
}

/// Payload for creating an organization unit, and for updating one by its identifier.
///
/// [parent] is always sent: `null` makes the unit a root of the tree.
class OrganizationUnitRequest extends _OrganizationUnitFields {
  final String? parent;

  const OrganizationUnitRequest({
    required super.handle,
    required super.name,
    this.parent,
    super.description,
    super.themeId,
    super.layoutId,
    super.authFlowId,
    super.registrationFlowId,
    super.isRegistrationFlowEnabled,
    super.recoveryFlowId,
    super.isRecoveryFlowEnabled,
    super.signOutFlowId,
    super.logoUrl,
    super.tosUri,
    super.policyUri,
    super.cookiePolicyUri,
  });

  Map<String, dynamic> toJson() => {..._fieldsJson(), 'parent': parent};
}

/// The payload used to create an organization unit.
typedef CreateOrganizationUnitRequest = OrganizationUnitRequest;

/// The payload used to update an organization unit by its identifier.
typedef UpdateOrganizationUnitRequest = OrganizationUnitRequest;

/// Payload for updating an organization unit addressed by its handle path. The unit keeps its
/// place in the tree.
class UpdateOrganizationUnitByPathRequest extends _OrganizationUnitFields {
  const UpdateOrganizationUnitByPathRequest({
    required super.handle,
    required super.name,
    super.description,
    super.themeId,
    super.layoutId,
    super.authFlowId,
    super.registrationFlowId,
    super.isRegistrationFlowEnabled,
    super.recoveryFlowId,
    super.isRecoveryFlowEnabled,
    super.signOutFlowId,
    super.logoUrl,
    super.tosUri,
    super.policyUri,
    super.cookiePolicyUri,
  });

  Map<String, dynamic> toJson() => _fieldsJson();
}

/// An organization unit with its settings.
class OrganizationUnit extends OrganizationUnitRequest {
  final String id;
  final String? createdAt;
  final String? updatedAt;

  const OrganizationUnit({
    required this.id,
    required super.handle,
    required super.name,
    super.parent,
    super.description,
    super.themeId,
    super.layoutId,
    super.authFlowId,
    super.registrationFlowId,
    super.isRegistrationFlowEnabled,
    super.recoveryFlowId,
    super.isRecoveryFlowEnabled,
    super.signOutFlowId,
    super.logoUrl,
    super.tosUri,
    super.policyUri,
    super.cookiePolicyUri,
    this.createdAt,
    this.updatedAt,
  });

  factory OrganizationUnit.fromJson(Map<String, dynamic> json) => OrganizationUnit(
        id: readString(json, 'id'),
        handle: readString(json, 'handle'),
        name: readString(json, 'name'),
        parent: readOptionalString(json, 'parent'),
        description: readOptionalString(json, 'description'),
        themeId: readOptionalString(json, 'themeId'),
        layoutId: readOptionalString(json, 'layoutId'),
        authFlowId: readOptionalString(json, 'authFlowId'),
        registrationFlowId: readOptionalString(json, 'registrationFlowId'),
        isRegistrationFlowEnabled: readOptionalBool(json, 'isRegistrationFlowEnabled'),
        recoveryFlowId: readOptionalString(json, 'recoveryFlowId'),
        isRecoveryFlowEnabled: readOptionalBool(json, 'isRecoveryFlowEnabled'),
        signOutFlowId: readOptionalString(json, 'signOutFlowId'),
        logoUrl: readOptionalString(json, 'logoUrl'),
        tosUri: readOptionalString(json, 'tosUri'),
        policyUri: readOptionalString(json, 'policyUri'),
        cookiePolicyUri: readOptionalString(json, 'cookiePolicyUri'),
        createdAt: readOptionalString(json, 'createdAt'),
        updatedAt: readOptionalString(json, 'updatedAt'),
      );
}

/// A user in an organization unit.
class OrganizationUnitUser {
  final String id;
  final String? type;

  /// A label the server resolved for the user, when requested with `include=display`.
  final String? display;

  /// Whether the unit owns the user, rather than the user being shared into it.
  final bool? isOwned;

  const OrganizationUnitUser({required this.id, this.type, this.display, this.isOwned});

  factory OrganizationUnitUser.fromJson(Map<String, dynamic> json) => OrganizationUnitUser(
        id: readString(json, 'id'),
        type: readOptionalString(json, 'type'),
        display: readOptionalString(json, 'display'),
        isOwned: readOptionalBool(json, 'isOwned'),
      );
}

/// A group in an organization unit.
class OrganizationUnitGroup {
  final String id;
  final String name;

  const OrganizationUnitGroup({required this.id, required this.name});

  factory OrganizationUnitGroup.fromJson(Map<String, dynamic> json) =>
      OrganizationUnitGroup(id: readString(json, 'id'), name: readString(json, 'name'));
}

/// A role in an organization unit.
class OrganizationUnitRole {
  final String id;
  final String name;
  final String? description;
  final bool isReadOnly;

  const OrganizationUnitRole({required this.id, required this.name, this.description, this.isReadOnly = false});

  factory OrganizationUnitRole.fromJson(Map<String, dynamic> json) => OrganizationUnitRole(
        id: readString(json, 'id'),
        name: readString(json, 'name'),
        description: readOptionalString(json, 'description'),
        isReadOnly: readOptionalBool(json, 'isReadOnly') ?? false,
      );
}
