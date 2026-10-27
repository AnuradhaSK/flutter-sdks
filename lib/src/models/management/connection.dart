// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import 'json_reader.dart';

/// The kinds of connection the server manages, each under `/connections/{type}`.
enum ConnectionType {
  authzenPdp('authzen-pdp'),
  emailSmtp('email-smtp'),
  github('github'),
  google('google'),
  http('http'),
  oauth('oauth'),
  oidc('oidc'),
  smsGateway('sms-gateway'),
  twilio('twilio'),
  vonage('vonage');

  /// The wire value, also the URL segment.
  final String value;

  const ConnectionType(this.value);

  /// The type with wire value [value], or `null` for one this SDK does not know.
  static ConnectionType? fromValue(String? value) {
    for (final type in values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

/// A connection as listed. When listed by type the server returns no type or categories, so
/// [type] is the type that was listed and [categories] is empty.
class ConnectionInstance {
  final String id;
  final String name;
  final String? description;

  /// `null` for a type this SDK does not know.
  final ConnectionType? type;

  /// What the connection is used for, such as `identity-provider` or `email-provider`.
  final List<String> categories;

  const ConnectionInstance({
    required this.id,
    required this.name,
    this.description,
    this.type,
    this.categories = const [],
  });

  factory ConnectionInstance.fromJson(Map<String, dynamic> json, {ConnectionType? type}) => ConnectionInstance(
        id: readString(json, 'id'),
        name: readString(json, 'name'),
        description: readOptionalString(json, 'description'),
        type: ConnectionType.fromValue(readOptionalString(json, 'type')) ?? type,
        categories: readStringList(json, 'categories'),
      );
}

/// One connection with its settings.
///
/// The settings differ by [type] (an OIDC connection has endpoints and a client, an SMTP one a
/// host and a sender), so they are kept as the server returned them in [settings], keyed by the
/// server's field names. Credential fields such as `clientSecret`, `authToken` or `apiSecret`
/// are write-only and may come back empty.
class Connection {
  final String id;
  final String name;
  final String? description;

  /// `null` for a type this SDK does not know.
  final ConnectionType? type;

  /// Every other field, as the server returned it.
  final Map<String, dynamic> settings;

  const Connection({
    required this.id,
    required this.name,
    this.description,
    this.type,
    this.settings = const {},
  });

  static const Set<String> _known = {'id', 'name', 'description', 'type'};

  factory Connection.fromJson(Map<String, dynamic> json, {ConnectionType? type}) => Connection(
        id: readString(json, 'id'),
        name: readString(json, 'name'),
        description: readOptionalString(json, 'description'),
        type: ConnectionType.fromValue(readOptionalString(json, 'type')) ?? type,
        settings: readUnmodeled(json, _known),
      );
}

/// Payload for creating or updating a connection: its name and description, and the settings of
/// its type keyed by the server's field names (for example `clientId`, `clientSecret`,
/// `redirectUri` and `scopes` for `google`). A credential left out of an update keeps its value.
class ConnectionRequest {
  final String name;
  final String? description;
  final Map<String, dynamic> settings;

  const ConnectionRequest({required this.name, this.description, this.settings = const {}});

  Map<String, dynamic> toJson() => {
        ...settings,
        'name': name,
        if (description != null) 'description': description,
      };

  /// Never includes the settings, which can hold credentials.
  @override
  String toString() => 'ConnectionRequest(name: $name)';
}

/// The payload used to create a connection.
typedef CreateConnectionRequest = ConnectionRequest;

/// The payload used to update a connection.
typedef UpdateConnectionRequest = ConnectionRequest;

/// A field an outbound authentication method needs.
class OutboundAuthField {
  final String key;
  final String? type;
  final bool required;

  /// Whether the value is a credential, write-only on the server.
  final bool credential;
  final String? displayName;

  const OutboundAuthField({
    required this.key,
    this.type,
    this.required = false,
    this.credential = false,
    this.displayName,
  });

  factory OutboundAuthField.fromJson(Map<String, dynamic> json) => OutboundAuthField(
        key: readString(json, 'key'),
        type: readOptionalString(json, 'type'),
        required: readOptionalBool(json, 'required') ?? false,
        credential: readOptionalBool(json, 'credential') ?? false,
        displayName: readOptionalString(json, 'displayName'),
      );
}

/// A way a connection can authenticate to the service it calls.
class OutboundAuthMethod {
  final String type;
  final String? displayName;
  final List<OutboundAuthField> fields;

  const OutboundAuthMethod({required this.type, this.displayName, this.fields = const []});

  factory OutboundAuthMethod.fromJson(Map<String, dynamic> json) => OutboundAuthMethod(
        type: readString(json, 'type'),
        displayName: readOptionalString(json, 'displayName'),
        fields: readList(json, 'fields').map((item) => OutboundAuthField.fromJson(readMap(item))).toList(growable: false),
      );
}

/// What one connection vendor supports.
class ConnectionVendorMeta {
  final String vendor;
  final List<OutboundAuthMethod> authenticationMethods;

  const ConnectionVendorMeta({required this.vendor, this.authenticationMethods = const []});

  factory ConnectionVendorMeta.fromJson(Map<String, dynamic> json) => ConnectionVendorMeta(
        vendor: readString(json, 'vendor'),
        authenticationMethods: readList(readMap(json['authentication']), 'methods')
            .map((item) => OutboundAuthMethod.fromJson(readMap(item)))
            .toList(growable: false),
      );
}

/// What the server supports for each connection vendor.
class ConnectionsMeta {
  final List<ConnectionVendorMeta> vendors;

  const ConnectionsMeta({this.vendors = const []});

  factory ConnectionsMeta.fromJson(Map<String, dynamic> json) => ConnectionsMeta(
        vendors:
            readList(json, 'vendors').map((item) => ConnectionVendorMeta.fromJson(readMap(item))).toList(growable: false),
      );
}
