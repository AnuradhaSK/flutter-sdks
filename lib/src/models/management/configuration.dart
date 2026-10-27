// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import 'json_reader.dart';

List<Map<String, dynamic>> _readMaps(Map<String, dynamic> json, String key) =>
    readList(json, key).whereType<Map<Object?, Object?>>().map(readMap).toList(growable: false);

/// Who made a change.
class ConfigurationActor {
  final String id;
  final String name;

  const ConfigurationActor({required this.id, required this.name});

  static ConfigurationActor? tryFromJson(Object? json) => json is Map
      ? ConfigurationActor(id: readString(readMap(json), 'id'), name: readString(readMap(json), 'name'))
      : null;
}

/// A place in the configuration that references a variable or a secret.
class ConfigurationValueReference {
  final String? name;

  /// `variable` or `secret`.
  final String? kind;
  final String? resourceType;
  final String? resourceId;
  final String? resourceName;
  final String? field;

  /// Whether the field holds a list of references.
  final bool? list;

  const ConfigurationValueReference({
    this.name,
    this.kind,
    this.resourceType,
    this.resourceId,
    this.resourceName,
    this.field,
    this.list,
  });

  factory ConfigurationValueReference.fromJson(Map<String, dynamic> json) => ConfigurationValueReference(
        name: readOptionalString(json, 'name'),
        kind: readOptionalString(json, 'kind'),
        resourceType: readOptionalString(json, 'resourceType'),
        resourceId: readOptionalString(json, 'resourceId'),
        resourceName: readOptionalString(json, 'resourceName'),
        field: readOptionalString(json, 'field'),
        list: readOptionalBool(json, 'list'),
      );

  static List<ConfigurationValueReference> listFromJson(Map<String, dynamic> json, String key) =>
      readList(json, key).map((item) => ConfigurationValueReference.fromJson(readMap(item))).toList(growable: false);
}

/// A captured version of the server's configuration.
class ConfigurationVersion {
  /// The version's sequence number.
  final int? number;

  /// The version's hash.
  final String? version;
  final String? name;
  final String? note;

  /// Whether nothing changed since the previous version, so capturing returned that one.
  final bool? unchanged;

  /// Whether this is the version gateways should hold.
  final bool? current;
  final String? createdAt;
  final ConfigurationActor? createdBy;

  /// The captured resources, as the server serializes them.
  final String? resources;
  final List<ConfigurationValueReference> references;

  /// The resources that could not be captured, as the server describes them.
  final List<Map<String, dynamic>> skipped;

  const ConfigurationVersion({
    this.number,
    this.version,
    this.name,
    this.note,
    this.unchanged,
    this.current,
    this.createdAt,
    this.createdBy,
    this.resources,
    this.references = const [],
    this.skipped = const [],
  });

  factory ConfigurationVersion.fromJson(Map<String, dynamic> json) => ConfigurationVersion(
        number: readOptionalInt(json, 'number'),
        version: readOptionalString(json, 'version'),
        name: readOptionalString(json, 'name'),
        note: readOptionalString(json, 'note'),
        unchanged: readOptionalBool(json, 'unchanged'),
        current: readOptionalBool(json, 'current'),
        createdAt: readOptionalString(json, 'createdAt'),
        createdBy: ConfigurationActor.tryFromJson(json['createdBy']),
        resources: readOptionalString(json, 'resources'),
        references: ConfigurationValueReference.listFromJson(json, 'references'),
        skipped: _readMaps(json, 'skipped'),
      );
}

/// Payload for capturing the server's configuration as a new version.
class CreateConfigurationVersionRequest {
  final String? name;
  final String? note;

  /// Whether the new version becomes the current one.
  final bool? current;

  const CreateConfigurationVersionRequest({this.name, this.note, this.current});

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (note != null) 'note': note,
        if (current != null) 'current': current,
      };
}

/// How an export is shaped.
class ExportOptions {
  final bool? includeMetadata;
  final bool? includeDependencies;

  /// Only `yaml`.
  final String? format;

  /// Folder layout options (`groupByType`, `customStructure`, `fileNamingPattern`).
  final Map<String, dynamic>? folderStructure;

  /// Paging options (`page`, `limit`).
  final Map<String, dynamic>? pagination;

  const ExportOptions({
    this.includeMetadata,
    this.includeDependencies,
    this.format,
    this.folderStructure,
    this.pagination,
  });

  Map<String, dynamic> toJson() => {
        if (includeMetadata != null) 'includeMetadata': includeMetadata,
        if (includeDependencies != null) 'includeDependencies': includeDependencies,
        if (format != null) 'format': format,
        if (folderStructure != null) 'folderStructure': folderStructure,
        if (pagination != null) 'pagination': pagination,
      };
}

/// Payload for exporting configuration: the identifiers of the resources of each kind to export
/// (`*` for every one), and the [options].
class ExportConfigurationRequest {
  final List<String>? applications;
  final List<String>? connections;
  final List<String>? userTypes;
  final List<String>? agentTypes;
  final List<String>? organizationUnits;
  final List<String>? users;
  final List<String>? groups;
  final List<String>? resourceServers;
  final List<String>? authorizationDetailTypes;
  final List<String>? roles;
  final List<String>? flows;
  final List<String>? translations;
  final List<String>? layouts;
  final List<String>? themes;
  final List<String>? credentialConfigurations;
  final List<String>? presentationDefinitions;
  final List<String>? notificationTemplates;
  final ExportOptions? options;

  const ExportConfigurationRequest({
    this.applications,
    this.connections,
    this.userTypes,
    this.agentTypes,
    this.organizationUnits,
    this.users,
    this.groups,
    this.resourceServers,
    this.authorizationDetailTypes,
    this.roles,
    this.flows,
    this.translations,
    this.layouts,
    this.themes,
    this.credentialConfigurations,
    this.presentationDefinitions,
    this.notificationTemplates,
    this.options,
  });

  Map<String, dynamic> toJson() => {
        if (applications != null) 'applications': applications,
        if (connections != null) 'connections': connections,
        if (userTypes != null) 'userTypes': userTypes,
        if (agentTypes != null) 'agentTypes': agentTypes,
        if (organizationUnits != null) 'organizationUnits': organizationUnits,
        if (users != null) 'users': users,
        if (groups != null) 'groups': groups,
        if (resourceServers != null) 'resourceServers': resourceServers,
        if (authorizationDetailTypes != null) 'authorizationDetailTypes': authorizationDetailTypes,
        if (roles != null) 'roles': roles,
        if (flows != null) 'flows': flows,
        if (translations != null) 'translations': translations,
        if (layouts != null) 'layouts': layouts,
        if (themes != null) 'themes': themes,
        if (credentialConfigurations != null) 'credentialConfigurations': credentialConfigurations,
        if (presentationDefinitions != null) 'presentationDefinitions': presentationDefinitions,
        if (notificationTemplates != null) 'notificationTemplates': notificationTemplates,
        if (options != null) 'options': options!.toJson(),
      };
}

/// Exported configuration: the resources as a YAML document, and the environment variables
/// they reference. Either can carry sensitive values; do not log them.
class ConfigurationExport {
  final String resources;
  final String environmentVariables;

  const ConfigurationExport({required this.resources, required this.environmentVariables});

  factory ConfigurationExport.fromJson(Map<String, dynamic> json) => ConfigurationExport(
        resources: readString(json, 'resources'),
        environmentVariables: readString(json, 'environment_variables'),
      );
}

/// A resource an import deletes.
class ImportResourceDeletion {
  final String resourceType;
  final String id;

  const ImportResourceDeletion({required this.resourceType, required this.id});

  Map<String, dynamic> toJson() => {'resourceType': resourceType, 'id': id};
}

/// How an import applies its documents.
class ImportOptions {
  /// Whether an existing resource is updated rather than reported as a conflict.
  final bool? upsert;
  final bool? continueOnError;

  /// Only `runtime`.
  final String? target;

  const ImportOptions({this.upsert, this.continueOnError, this.target});

  Map<String, dynamic> toJson() => {
        if (upsert != null) 'upsert': upsert,
        if (continueOnError != null) 'continueOnError': continueOnError,
        if (target != null) 'target': target,
      };
}

/// Payload for importing configuration. [variables] fill the placeholders in [content] and can
/// hold secrets; [toString] leaves them and the content out.
class ImportConfigurationRequest {
  /// The YAML document(s) to import.
  final String? content;
  final Map<String, dynamic>? variables;
  final bool? dryRun;
  final List<ImportResourceDeletion>? deletions;
  final ImportOptions? options;

  const ImportConfigurationRequest({this.content, this.variables, this.dryRun, this.deletions, this.options});

  Map<String, dynamic> toJson() => {
        if (content != null) 'content': content,
        if (variables != null) 'variables': variables,
        if (dryRun != null) 'dryRun': dryRun,
        if (deletions != null) 'deletions': deletions!.map((deletion) => deletion.toJson()).toList(),
        if (options != null) 'options': options!.toJson(),
      };

  @override
  String toString() => 'ImportConfigurationRequest(dryRun: $dryRun)';
}

/// The totals of an import.
class ImportSummary {
  final int totalDocuments;
  final int imported;
  final int failed;
  final int? deleted;
  final String? importedAt;

  const ImportSummary({
    required this.totalDocuments,
    required this.imported,
    required this.failed,
    this.deleted,
    this.importedAt,
  });

  factory ImportSummary.fromJson(Map<String, dynamic> json) => ImportSummary(
        totalDocuments: readInt(json, 'totalDocuments'),
        imported: readInt(json, 'imported'),
        failed: readInt(json, 'failed'),
        deleted: readOptionalInt(json, 'deleted'),
        importedAt: readOptionalString(json, 'importedAt'),
      );
}

/// What happened to one imported resource.
class ImportItemOutcome {
  final String resourceType;
  final String? resourceId;
  final String? resourceName;

  /// `create` or `update`.
  final String? operation;

  /// `success` or `failed`.
  final String status;
  final String? code;
  final String? message;

  const ImportItemOutcome({
    required this.resourceType,
    required this.status,
    this.resourceId,
    this.resourceName,
    this.operation,
    this.code,
    this.message,
  });

  factory ImportItemOutcome.fromJson(Map<String, dynamic> json) => ImportItemOutcome(
        resourceType: readString(json, 'resourceType'),
        status: readString(json, 'status'),
        resourceId: readOptionalString(json, 'resourceId'),
        resourceName: readOptionalString(json, 'resourceName'),
        operation: readOptionalString(json, 'operation'),
        code: readOptionalString(json, 'code'),
        message: readOptionalString(json, 'message'),
      );
}

/// The result of an import.
class ImportResult {
  final ImportSummary summary;
  final List<ImportItemOutcome> results;

  const ImportResult({required this.summary, this.results = const []});

  factory ImportResult.fromJson(Map<String, dynamic> json) => ImportResult(
        summary: ImportSummary.fromJson(readMap(json['summary'])),
        results: readList(json, 'results').map((item) => ImportItemOutcome.fromJson(readMap(item))).toList(growable: false),
      );
}

/// Payload for deleting a resource that came from an imported file.
class DeleteImportedConfigurationRequest {
  final String resourceType;
  final String resourceKey;

  const DeleteImportedConfigurationRequest({required this.resourceType, required this.resourceKey});

  Map<String, dynamic> toJson() => {'resourceType': resourceType, 'resourceKey': resourceKey};
}

/// The result of deleting an imported resource: the file it was removed from.
class DeletedImportedConfiguration {
  final String resourceType;
  final String resourceKey;
  final String deletedFile;

  const DeletedImportedConfiguration({required this.resourceType, required this.resourceKey, required this.deletedFile});

  factory DeletedImportedConfiguration.fromJson(Map<String, dynamic> json) => DeletedImportedConfiguration(
        resourceType: readString(json, 'resourceType'),
        resourceKey: readString(json, 'resourceKey'),
        deletedFile: readString(json, 'deletedFile'),
      );
}
