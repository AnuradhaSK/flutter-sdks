// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import '../models/management/json_reader.dart';
import '../models/management/managed_user.dart';
import '../models/management/management_page.dart';
import '../models/management/sharing_policy.dart';
import 'management_collection.dart';
import 'management_transport.dart';
import 'thunderid_management_client.dart';

/// The user and application endpoints beyond their CRUD: users by organization unit path
/// (`/users/tree/{path}`), sharing policies (`/{users|applications}/{id}/sharing-policies`), and
/// the overlay that applies to a shared user or application in a unit (`.../overlay-rules`).
///
/// URLs resolve like the other user and application operations: the `url` passed to the call,
/// the [ManagementEndpointKeys.users] or [ManagementEndpointKeys.applications] override, then
/// `{baseUrl}/users` or `{baseUrl}/applications`.
extension SharingOperations on ThunderIDManagementClient {
  // ── Users by path ──────────────────────────────────────────────────────

  /// Lists the users in the organization unit at [path], a path of handles such as
  /// `engineering/platform`. The server takes no filter on this listing.
  Future<ManagementPage<ManagedUser>> getUsersByPath(
    String path, {
    int? limit,
    int? offset,
    String? url,
    ManagementFetcher? fetcher,
  }) async {
    const operation = 'getUsersByPath';
    return ManagementPage.fromJson(
      await _send(
        _users,
        operation,
        'Failed to fetch users',
        segments: ['tree', ...organizationUnitPathSegments(operation, path)],
        query: {'include': 'display', 'limit': limit, 'offset': offset},
        url: url,
        fetcher: fetcher,
      ),
      'users',
      (item) => ManagedUser.fromJson(readMap(item)),
    );
  }

  /// Creates a user in the organization unit at [path], a path of handles such as
  /// `engineering/platform`.
  Future<ManagedUser> createUserByPath(
    String path,
    CreateUserByPathRequest payload, {
    String? url,
    ManagementFetcher? fetcher,
  }) async {
    const operation = 'createUserByPath';
    return ManagedUser.fromJson(
      readMap(
        await _send(
          _users,
          operation,
          'Failed to create user',
          method: 'POST',
          segments: ['tree', ...organizationUnitPathSegments(operation, path)],
          body: payload.toJson(),
          url: url,
          fetcher: fetcher,
        ),
      ),
    );
  }

  // ── User sharing ───────────────────────────────────────────────────────

  Future<ManagementPage<SharingPolicy>> getUserSharingPolicies(
    String userId, {
    int? limit,
    int? offset,
    String? url,
    ManagementFetcher? fetcher,
  }) =>
      _getPolicies(_users, 'getUserSharingPolicies', userId, limit, offset, url, fetcher);

  Future<SharingPolicy> createUserSharingPolicy(
    String userId,
    CreateSharingPolicyRequest payload, {
    String? url,
    ManagementFetcher? fetcher,
  }) =>
      _writePolicy(_users, 'createUserSharingPolicy', 'POST', userId, null, payload.toJson(), url, fetcher);

  Future<SharingPolicy> getUserSharingPolicy(
    String userId,
    String policyId, {
    String? url,
    ManagementFetcher? fetcher,
  }) =>
      _writePolicy(_users, 'getUserSharingPolicy', 'GET', userId, policyId, null, url, fetcher);

  Future<SharingPolicy> updateUserSharingPolicy(
    String userId,
    String policyId,
    UpdateSharingPolicyRequest payload, {
    String? url,
    ManagementFetcher? fetcher,
  }) =>
      _writePolicy(_users, 'updateUserSharingPolicy', 'PUT', userId, policyId, payload.toJson(), url, fetcher);

  Future<void> deleteUserSharingPolicy(
    String userId,
    String policyId, {
    String? url,
    ManagementFetcher? fetcher,
  }) =>
      _deletePolicy(_users, 'deleteUserSharingPolicy', userId, policyId, url, fetcher);

  /// Reads how [userId] appears in the organization unit [ouId] (by default, the unit the
  /// caller signed in to).
  Future<ResolvedOverlay> getUserOverlayRules(
    String userId, {
    String? ouId,
    String? url,
    ManagementFetcher? fetcher,
  }) =>
      _getOverlay(_users, 'getUserOverlayRules', userId, ouId, url, fetcher);

  // ── Application sharing ────────────────────────────────────────────────

  Future<ManagementPage<SharingPolicy>> getApplicationSharingPolicies(
    String applicationId, {
    int? limit,
    int? offset,
    String? url,
    ManagementFetcher? fetcher,
  }) =>
      _getPolicies(_applications, 'getApplicationSharingPolicies', applicationId, limit, offset, url, fetcher);

  Future<SharingPolicy> createApplicationSharingPolicy(
    String applicationId,
    CreateSharingPolicyRequest payload, {
    String? url,
    ManagementFetcher? fetcher,
  }) =>
      _writePolicy(
        _applications,
        'createApplicationSharingPolicy',
        'POST',
        applicationId,
        null,
        payload.toJson(),
        url,
        fetcher,
      );

  Future<SharingPolicy> getApplicationSharingPolicy(
    String applicationId,
    String policyId, {
    String? url,
    ManagementFetcher? fetcher,
  }) =>
      _writePolicy(_applications, 'getApplicationSharingPolicy', 'GET', applicationId, policyId, null, url, fetcher);

  Future<SharingPolicy> updateApplicationSharingPolicy(
    String applicationId,
    String policyId,
    UpdateSharingPolicyRequest payload, {
    String? url,
    ManagementFetcher? fetcher,
  }) =>
      _writePolicy(
        _applications,
        'updateApplicationSharingPolicy',
        'PUT',
        applicationId,
        policyId,
        payload.toJson(),
        url,
        fetcher,
      );

  Future<void> deleteApplicationSharingPolicy(
    String applicationId,
    String policyId, {
    String? url,
    ManagementFetcher? fetcher,
  }) =>
      _deletePolicy(_applications, 'deleteApplicationSharingPolicy', applicationId, policyId, url, fetcher);

  /// Reads how [applicationId] appears in the organization unit [ouId] (by default, the unit the
  /// caller signed in to).
  Future<ResolvedOverlay> getApplicationOverlayRules(
    String applicationId, {
    String? ouId,
    String? url,
    ManagementFetcher? fetcher,
  }) =>
      _getOverlay(_applications, 'getApplicationOverlayRules', applicationId, ouId, url, fetcher);

  // ── Internals ──────────────────────────────────────────────────────────

  static const _Collection _users = (key: ManagementEndpointKeys.users, path: 'users', noun: 'user');
  static const _Collection _applications =
      (key: ManagementEndpointKeys.applications, path: 'applications', noun: 'application');

  Future<ManagementPage<SharingPolicy>> _getPolicies(
    _Collection collection,
    String operation,
    String id,
    int? limit,
    int? offset,
    String? url,
    ManagementFetcher? fetcher,
  ) async =>
      ManagementPage.fromJson(
        await _send(
          collection,
          operation,
          'Failed to fetch ${collection.noun} sharing policies',
          segments: [id, 'sharing-policies'],
          query: {'limit': limit, 'offset': offset},
          url: url,
          fetcher: fetcher,
        ),
        'policies',
        (item) => SharingPolicy.fromJson(readMap(item)),
      );

  Future<SharingPolicy> _writePolicy(
    _Collection collection,
    String operation,
    String method,
    String id,
    String? policyId,
    Map<String, dynamic>? body,
    String? url,
    ManagementFetcher? fetcher,
  ) async {
    final verb = switch (method) { 'POST' => 'create', 'PUT' => 'update', _ => 'fetch' };
    return SharingPolicy.fromJson(
      readMap(
        await _send(
          collection,
          operation,
          'Failed to $verb ${collection.noun} sharing policy',
          method: method,
          segments: [id, 'sharing-policies', if (policyId != null) policyId],
          body: body,
          url: url,
          fetcher: fetcher,
        ),
      ),
    );
  }

  Future<void> _deletePolicy(
    _Collection collection,
    String operation,
    String id,
    String policyId,
    String? url,
    ManagementFetcher? fetcher,
  ) =>
      _send(
        collection,
        operation,
        'Failed to delete ${collection.noun} sharing policy',
        method: 'DELETE',
        segments: [id, 'sharing-policies', policyId],
        url: url,
        fetcher: fetcher,
      );

  Future<ResolvedOverlay> _getOverlay(
    _Collection collection,
    String operation,
    String id,
    String? ouId,
    String? url,
    ManagementFetcher? fetcher,
  ) async =>
      ResolvedOverlay.fromJson(
        readMap(
          await _send(
            collection,
            operation,
            'Failed to fetch ${collection.noun} overlay rules',
            segments: [id, 'overlay-rules'],
            query: {'ouId': ouId},
            url: url,
            fetcher: fetcher,
          ),
        ),
      );

  Future<Object?> _send(
    _Collection collection,
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
        endpointKey: collection.key,
        collection: collection.path,
        method: method,
        segments: segments,
        query: query,
        body: body,
        url: url,
        fetcher: fetcher,
      );
}

typedef _Collection = ({String key, String path, String noun});
