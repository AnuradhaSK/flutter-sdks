// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import 'json_reader.dart';

/// A resource that references another one, such as an application that signs in through a flow,
/// or a flow that uses a connection.
class ResourceUsage {
  final String id;
  final String displayName;

  /// The kind of resource, such as `application`, `agent` or `flow`.
  final String resourceType;

  /// What happens to the referencing resource when the referenced one is deleted: `fallback`,
  /// `cascade` or `restrict`. `null` when the server did not say.
  final String? behaviorOnDelete;

  const ResourceUsage({
    required this.id,
    required this.displayName,
    required this.resourceType,
    this.behaviorOnDelete,
  });

  factory ResourceUsage.fromJson(Map<String, dynamic> json) => ResourceUsage(
        id: readString(json, 'id'),
        displayName: readString(json, 'displayName'),
        resourceType: readString(json, 'resourceType'),
        behaviorOnDelete: readOptionalString(json, 'behaviorOnDelete'),
      );
}

/// The resources that reference a flow, theme, layout or connection. [totalResults] and
/// [summary] are `null` when the server did not report them.
class ResourceUsages {
  final List<ResourceUsage> usages;
  final int count;
  final int? totalResults;

  /// The number of usages of each resource type.
  final Map<String, int>? summary;

  const ResourceUsages({required this.usages, required this.count, this.totalResults, this.summary});

  factory ResourceUsages.fromJson(Map<String, dynamic> json) {
    final usages =
        readList(json, 'usages').map((item) => ResourceUsage.fromJson(readMap(item))).toList(growable: false);
    final summary = json['summary'];
    return ResourceUsages(
      usages: usages,
      count: readInt(json, 'count', usages.length),
      totalResults: readOptionalInt(json, 'totalResults'),
      summary: summary is Map
          ? {
              for (final entry in summary.entries)
                if (entry.value is num) entry.key.toString(): (entry.value as num).toInt(),
            }
          : null,
    );
  }
}

