// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import 'json_reader.dart';

/// One server configuration section, as its three layers: the values fixed in the deployment
/// ([readOnly]), the values set through the API ([writable]), and the two combined ([merged]),
/// which is what the server uses. Each is kept as the server describes the section.
class ServerConfigLayers {
  final Map<String, dynamic> readOnly;
  final Map<String, dynamic> writable;
  final Map<String, dynamic> merged;

  const ServerConfigLayers({this.readOnly = const {}, this.writable = const {}, this.merged = const {}});

  factory ServerConfigLayers.fromJson(Map<String, dynamic> json) => ServerConfigLayers(
        readOnly: readMap(json['readOnly']),
        writable: readMap(json['writable']),
        merged: readMap(json['merged']),
      );
}
