// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import '../models/management/administration.dart';
import '../models/management/flow_definition.dart';
import '../models/management/json_reader.dart';
import '../models/management/management_page.dart';
import '../models/management/resource_usage.dart';
import 'management_collection.dart';
import 'management_transport.dart';
import 'thunderid_management_client.dart';

/// Flow definition operations: `/flows`, with each flow's versions and usages. These manage the
/// definitions; running a flow is not part of the management API.
///
/// URLs resolve like every other operation: the `url` passed to the call, the
/// [ManagementEndpointKeys.flows] override, then `{baseUrl}/flows`. The administration flow
/// lookups ([AdministrationFlowOperations]) always use `{baseUrl}/flows`.
extension FlowOperations on ThunderIDManagementClient {
  /// Lists the flow definitions, newest first; [flowType] (see [FlowTypes]) narrows the page.
  Future<ManagementPage<ManagedFlow>> getFlows({
    String? flowType,
    int? limit,
    int? offset,
    String? url,
    ManagementFetcher? fetcher,
  }) async =>
      ManagementPage.fromJson(
        await _send(
          'getFlows',
          'Failed to fetch flows',
          query: {'flowType': flowType, 'limit': limit, 'offset': offset},
          url: url,
          fetcher: fetcher,
        ),
        'flows',
        (item) => ManagedFlow.fromJson(readMap(item)),
      );

  Future<FlowDefinition> getFlow(String flowId, {String? url, ManagementFetcher? fetcher}) async =>
      FlowDefinition.fromJson(
        readMap(await _send('getFlow', 'Failed to fetch flow', segments: [flowId], url: url, fetcher: fetcher)),
      );

  Future<FlowDefinition> createFlow(CreateFlowRequest payload, {String? url, ManagementFetcher? fetcher}) async =>
      FlowDefinition.fromJson(
        readMap(
          await _send(
            'createFlow',
            'Failed to create flow',
            method: 'POST',
            body: payload.toJson(),
            url: url,
            fetcher: fetcher,
          ),
        ),
      );

  /// Saves [payload] as a new version of [flowId], which becomes the active one.
  Future<FlowDefinition> updateFlow(
    String flowId,
    UpdateFlowRequest payload, {
    String? url,
    ManagementFetcher? fetcher,
  }) async =>
      FlowDefinition.fromJson(
        readMap(
          await _send(
            'updateFlow',
            'Failed to update flow',
            method: 'PUT',
            segments: [flowId],
            body: payload.toJson(),
            url: url,
            fetcher: fetcher,
          ),
        ),
      );

  Future<void> deleteFlow(String flowId, {String? url, ManagementFetcher? fetcher}) => _send(
        'deleteFlow',
        'Failed to delete flow',
        method: 'DELETE',
        segments: [flowId],
        url: url,
        fetcher: fetcher,
      );

  /// Reads [flowId]'s version history.
  Future<FlowVersions> getFlowVersions(String flowId, {String? url, ManagementFetcher? fetcher}) async =>
      FlowVersions.fromJson(
        readMap(
          await _send(
            'getFlowVersions',
            'Failed to fetch flow versions',
            segments: [flowId, 'versions'],
            url: url,
            fetcher: fetcher,
          ),
        ),
      );

  Future<FlowVersion> getFlowVersion(
    String flowId,
    int version, {
    String? url,
    ManagementFetcher? fetcher,
  }) async =>
      FlowVersion.fromJson(
        readMap(
          await _send(
            'getFlowVersion',
            'Failed to fetch flow version',
            segments: [flowId, 'versions', '$version'],
            url: url,
            fetcher: fetcher,
          ),
        ),
      );

  /// Makes an earlier [version] of [flowId] the active one again.
  Future<FlowDefinition> restoreFlowVersion(
    String flowId,
    int version, {
    String? url,
    ManagementFetcher? fetcher,
  }) async =>
      FlowDefinition.fromJson(
        readMap(
          await _send(
            'restoreFlowVersion',
            'Failed to restore flow version',
            method: 'POST',
            segments: [flowId, 'restore'],
            body: {'version': version},
            url: url,
            fetcher: fetcher,
          ),
        ),
      );

  /// Lists the applications and agents that use [flowId], and what happens to each when it is
  /// deleted.
  Future<ResourceUsages> getFlowUsages(String flowId, {String? url, ManagementFetcher? fetcher}) async =>
      ResourceUsages.fromJson(
        readMap(
          await _send(
            'getFlowUsages',
            'Failed to fetch flow usages',
            segments: [flowId, 'usages'],
            url: url,
            fetcher: fetcher,
          ),
        ),
      );

  Future<Object?> _send(
    String operation,
    String failureMessage, {
    String method = 'GET',
    List<String> segments = const [],
    Map<String, Object?> query = const {},
    Object? body,
    String? url,
    ManagementFetcher? fetcher,
  }) =>
      sendCollectionRequest(
        this,
        operation: operation,
        failureMessage: failureMessage,
        endpointKey: ManagementEndpointKeys.flows,
        collection: 'flows',
        method: method,
        segments: segments,
        query: query,
        body: body,
        url: url,
        fetcher: fetcher,
      );
}
