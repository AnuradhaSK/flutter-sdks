// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import 'json_reader.dart';

/// A named configuration value that resources reference instead of holding it themselves.
class Variable {
  final String name;
  final String value;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  const Variable({required this.name, required this.value, this.description, this.createdAt, this.updatedAt});

  factory Variable.fromJson(Map<String, dynamic> json) => Variable(
        name: readString(json, 'name'),
        value: readString(json, 'value'),
        description: readOptionalString(json, 'description'),
        createdAt: readOptionalString(json, 'createdAt'),
        updatedAt: readOptionalString(json, 'updatedAt'),
      );
}

/// Payload for creating a variable.
class CreateVariableRequest {
  final String name;
  final String value;
  final String? description;

  const CreateVariableRequest({required this.name, required this.value, this.description});

  Map<String, dynamic> toJson() => {'name': name, 'value': value, if (description != null) 'description': description};
}

/// Payload for updating a variable; the name is fixed. An update to a missing variable creates it.
class UpdateVariableRequest {
  final String value;
  final String? description;

  const UpdateVariableRequest({required this.value, this.description});

  Map<String, dynamic> toJson() => {'value': value, if (description != null) 'description': description};
}

/// A named secret. Its value is write-only: the server only says whether it [exists].
class Secret {
  final String name;
  final bool exists;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  const Secret({required this.name, required this.exists, this.description, this.createdAt, this.updatedAt});

  factory Secret.fromJson(Map<String, dynamic> json) => Secret(
        name: readString(json, 'name'),
        exists: readOptionalBool(json, 'exists') ?? false,
        description: readOptionalString(json, 'description'),
        createdAt: readOptionalString(json, 'createdAt'),
        updatedAt: readOptionalString(json, 'updatedAt'),
      );
}

/// Payload for creating a secret. [toString] never includes the value.
class CreateSecretRequest {
  final String name;
  final String value;
  final String? description;

  const CreateSecretRequest({required this.name, required this.value, this.description});

  Map<String, dynamic> toJson() => {'name': name, 'value': value, if (description != null) 'description': description};

  @override
  String toString() => 'CreateSecretRequest(name: $name)';
}

/// Payload for updating a secret; the name is fixed. [toString] never includes the value.
class UpdateSecretRequest {
  final String value;
  final String? description;

  const UpdateSecretRequest({required this.value, this.description});

  Map<String, dynamic> toJson() => {'value': value, if (description != null) 'description': description};

  @override
  String toString() => 'UpdateSecretRequest()';
}
