// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../management/management_display.dart';
import '../../models/management/application.dart';
import '../../models/preferences.dart';
import '../../state/management_resources.dart';
import '../../state/resource_notifiers.dart';
import 'admin_render_state.dart';
import 'identity_candidate.dart';
import 'internal/admin_connected.dart';
import 'internal/admin_context.dart';
import 'internal/admin_inputs.dart';
import 'internal/admin_parts.dart';
import 'internal/application_form.dart';

/// The application's status value, such as `ACTIVE`, when the server reported one.
String? _statusOf(Application application) {
  final status = application.additionalFields['status'];
  final value = status is Map ? status['value'] : null;
  return value is String ? value : null;
}

String? _clientIdOf(Application application) {
  final fromConfig = application.oauth2Config?.clientId;
  if (fromConfig != null && fromConfig.isNotEmpty) return fromConfig;
  final clientId = application.additionalFields['clientId'];
  return clientId is String && clientId.isNotEmpty ? clientId : null;
}

/// Presentational view of one application: its general fields and its OAuth client.
///
/// Edit, delete and regenerate secret appear only when [onUpdate], [onDelete] and
/// [onRegenerateSecret] are set, and never for a read-only application; regenerate also needs a
/// confidential OAuth client. Delete and regenerate ask for confirmation first (spec "UI",
/// requirement 6). While [clientSecret] is set it is shown once, with copy and done actions.
class BaseApplicationDetails extends StatefulWidget {
  final Application? application;
  final bool isLoading;

  /// An already-translated error message. Never pass the server's text here.
  final String? error;
  final VoidCallback? onDelete;
  final bool isDeleting;
  final ValueChanged<ApplicationEdit>? onUpdate;
  final bool isUpdating;
  final VoidCallback? onRegenerateSecret;
  final bool isRegeneratingSecret;

  /// A newly regenerated client secret to show once.
  final String? clientSecret;
  final VoidCallback? onSecretDismissed;
  final List<Widget> actions;
  final ThunderIDPreferences? preferences;

  /// Builds custom UI in place of the default view, from the application, the loading and error state, the secret to show once, and the update, delete and regenerate callbacks the app allows.
  final AdminWidgetBuilder<ApplicationDetailsState>? builder;

  const BaseApplicationDetails({
    super.key,
    this.application,
    this.isLoading = false,
    this.error,
    this.onDelete,
    this.isDeleting = false,
    this.onUpdate,
    this.isUpdating = false,
    this.onRegenerateSecret,
    this.isRegeneratingSecret = false,
    this.clientSecret,
    this.onSecretDismissed,
    this.actions = const [],
    this.preferences,
    this.builder,
  });

  @override
  State<BaseApplicationDetails> createState() => _BaseApplicationDetailsState();
}

class _Draft {
  String name;
  String description;
  String url;
  String logoUrl;
  String redirectUris;
  List<String> grantTypes;

  _Draft(Application application)
      : name = application.name,
        description = application.description ?? '',
        url = application.url ?? '',
        logoUrl = application.logoUrl ?? '',
        redirectUris = (application.oauth2Config?.redirectUris ?? const []).join('\n'),
        grantTypes = List.of(application.oauth2Config?.grantTypes ?? const <String>[]);

  ApplicationEdit toEdit() => ApplicationEdit(
        name: name.trim(),
        description: description.trim(),
        url: url.trim(),
        logoUrl: logoUrl.trim(),
        redirectUris: parseRedirectUris(redirectUris),
        grantTypes: grantTypes,
      );
}

class _BaseApplicationDetailsState extends State<BaseApplicationDetails> {
  _Draft? _draft;

  @override
  Widget build(BuildContext context) {
    final ac = AdminContext.of(context, widget.preferences);
    final application = widget.application;
    final isWritable = application != null && !(application.isReadOnly ?? false);
    final oauth = application?.oauth2Config;
    final canRegenerate = isWritable && oauth != null && oauth.publicClient != true;
    final onDelete = isWritable ? widget.onDelete : null;
    final onUpdate = isWritable ? widget.onUpdate : null;
    final onRegenerate = canRegenerate ? widget.onRegenerateSecret : null;

    final builder = widget.builder;
    if (builder != null) {
      return builder(
        context,
        ApplicationDetailsState(
          application: application,
          isLoading: widget.isLoading,
          error: widget.error,
          isDeleting: widget.isDeleting,
          isUpdating: widget.isUpdating,
          isRegeneratingSecret: widget.isRegeneratingSecret,
          clientSecret: widget.clientSecret,
          onDelete: onDelete,
          onUpdate: onUpdate,
          onRegenerateSecret: onRegenerate,
          onSecretDismissed: widget.clientSecret == null ? null : widget.onSecretDismissed,
        ),
      );
    }
    if (application == null) {
      return AdminSection(
        ac: ac,
        block: 'application-details',
        children: [
          if (widget.isLoading)
            AdminLoading(ac: ac)
          else
            AdminAlert(
              ac: ac,
              block: 'application-details',
              message: widget.error ?? ac.t('admin.common.errors.not_found'),
            ),
        ],
      );
    }

    final clientId = _clientIdOf(application);
    final status = _statusOf(application);
    final secret = widget.clientSecret;
    final draft = _draft;

    return AdminSection(
      ac: ac,
      block: 'application-details',
      title: application.name,
      description: application.description,
      actions: [
        ...widget.actions,
        if (onUpdate != null && draft == null)
          AdminButton(
            ac: ac,
            label: ac.t('admin.applications.details.edit.action'),
            identifier: 'thunderid-action-application-details-edit',
            variant: AdminButtonVariant.outline,
            onPressed: () => setState(() => _draft = _Draft(application)),
          ),
        if (onRegenerate != null)
          AdminConfirmButton(
            ac: ac,
            label: ac.t('admin.applications.details.regenerate.action'),
            confirmText: ac.t('admin.applications.details.regenerate.confirm', {'name': application.name}),
            identifier: 'thunderid-action-application-details-regenerateSecret',
            isLoading: widget.isRegeneratingSecret,
            onConfirm: onRegenerate,
          ),
        if (onDelete != null)
          AdminConfirmButton(
            ac: ac,
            label: ac.t('admin.applications.details.delete.action'),
            confirmText: ac.t('admin.applications.details.delete.confirm', {'name': application.name}),
            identifier: 'thunderid-action-application-details-delete',
            isLoading: widget.isDeleting,
            onConfirm: onDelete,
          ),
      ],
      children: [
        if (widget.error != null) AdminAlert(ac: ac, message: widget.error!, block: 'application-details'),
        if (secret != null)
          AdminSecretReveal(
            ac: ac,
            block: 'application-details',
            secret: secret,
            onDone: () => widget.onSecretDismissed?.call(),
          ),
        if (draft != null)
          _editor(ac, draft, onUpdate)
        else ...[
          AdminPanel(
            ac: ac,
            title: ac.t('admin.applications.details.overview'),
            child: AdminDetailList(
              ac: ac,
              items: [
                if (clientId != null)
                  (
                    ac.t('admin.applications.list.columns.client_id'),
                    Row(
                      children: [
                        Flexible(
                          child: SelectableText(clientId, style: const TextStyle(fontFamily: 'monospace')),
                        ),
                        AdminButton(
                          ac: ac,
                          label: ac.t('elements.display.copyable_text.copy'),
                          identifier: 'thunderid-action-application-details-copyClientId',
                          variant: AdminButtonVariant.text,
                          onPressed: () => unawaited(Clipboard.setData(ClipboardData(text: clientId))),
                        ),
                      ],
                    ),
                  ),
                if (application.type != null)
                  (ac.t('admin.applications.fields.type'), Text(applicationTypeLabel(ac, application.type))),
                if (application.template != null)
                  (ac.t('admin.applications.details.template'), Text(application.template!)),
                if (status != null)
                  (ac.t('admin.applications.list.columns.status'), Text(applicationStatusLabel(ac, status))),
                if (application.ouId != null)
                  (ac.t('admin.common.columns.organization_unit'), Text(application.ouId!)),
                if (application.url != null) (ac.t('admin.applications.fields.url'), Text(application.url!)),
                if (application.logoUrl != null)
                  (ac.t('admin.applications.fields.logo_url'), Text(application.logoUrl!)),
              ],
            ),
          ),
          AdminPanel(
            ac: ac,
            title: ac.t('admin.applications.details.oauth'),
            child: oauth == null
                ? AdminMuted(ac: ac, text: ac.t('admin.applications.details.no_oauth'))
                : AdminDetailList(
                    ac: ac,
                    items: [
                      (
                        ac.t('admin.applications.fields.grant_types'),
                        AdminChipList(
                          ac: ac,
                          label: ac.t('admin.applications.fields.grant_types'),
                          emptyText: ac.t('admin.applications.details.no_grant_types'),
                          items: [
                            for (final grant in oauth.grantTypes)
                              AdminChip(
                                id: grant,
                                label: applicationGrantTypes.contains(grant)
                                    ? ac.t('admin.applications.grant_types.$grant')
                                    : grant,
                              ),
                          ],
                        ),
                      ),
                      (
                        ac.t('admin.applications.fields.redirect_uris'),
                        (oauth.redirectUris ?? const []).isEmpty
                            ? AdminMuted(ac: ac, text: ac.t('admin.applications.details.no_redirect_uris'))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [for (final uri in oauth.redirectUris!) SelectableText(uri)],
                              ),
                      ),
                      (
                        ac.t('admin.applications.fields.public_client'),
                        Text(ac.t(oauth.publicClient == true ? 'admin.common.yes' : 'admin.common.no')),
                      ),
                    ],
                  ),
          ),
        ],
      ],
    );
  }

  Widget _editor(AdminContext ac, _Draft draft, ValueChanged<ApplicationEdit>? onUpdate) {
    final edit = draft.toEdit();
    final hasOAuth = widget.application?.oauth2Config != null;
    final isValid = edit.name.isNotEmpty &&
        (!hasOAuth ||
            isValidOAuthSetup(
              grantTypes: edit.grantTypes,
              redirectUris: edit.redirectUris,
              publicClient: widget.application?.oauth2Config?.publicClient == true,
            ));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AdminTextField(
          ac: ac,
          label: ac.t('admin.applications.fields.name'),
          identifier: 'thunderid-field-application-details-name',
          required: true,
          initialValue: draft.name,
          onChanged: (value) => setState(() => draft.name = value),
        ),
        AdminTextField(
          ac: ac,
          label: ac.t('admin.applications.fields.description'),
          identifier: 'thunderid-field-application-details-description',
          initialValue: draft.description,
          onChanged: (value) => setState(() => draft.description = value),
        ),
        AdminTextField(
          ac: ac,
          label: ac.t('admin.applications.fields.url'),
          identifier: 'thunderid-field-application-details-url',
          initialValue: draft.url,
          keyboardType: TextInputType.url,
          onChanged: (value) => setState(() => draft.url = value),
        ),
        AdminTextField(
          ac: ac,
          label: ac.t('admin.applications.fields.logo_url'),
          identifier: 'thunderid-field-application-details-logoUrl',
          initialValue: draft.logoUrl,
          keyboardType: TextInputType.url,
          onChanged: (value) => setState(() => draft.logoUrl = value),
        ),
        if (hasOAuth) ...[
          AdminCheckboxGroup(
            ac: ac,
            label: ac.t('admin.applications.fields.grant_types'),
            identifier: 'thunderid-field-application-details-grantTypes',
            options: [
              ...applicationGrantTypeOptions(ac),
              for (final grant in draft.grantTypes)
                if (!applicationGrantTypes.contains(grant)) AdminSelectOption(value: grant, label: grant),
            ],
            selected: draft.grantTypes,
            onChanged: (grant, selected) => setState(() {
              draft.grantTypes = selected
                  ? [...draft.grantTypes.where((entry) => entry != grant), grant]
                  : draft.grantTypes.where((entry) => entry != grant).toList();
            }),
          ),
          AdminTextField(
            ac: ac,
            label: ac.t('admin.applications.fields.redirect_uris'),
            identifier: 'thunderid-field-application-details-redirectUris',
            hint: ac.t('admin.applications.fields.redirect_uris_hint'),
            initialValue: draft.redirectUris,
            maxLines: 3,
            onChanged: (value) => setState(() => draft.redirectUris = value),
          ),
        ],
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          children: [
            AdminButton(
              ac: ac,
              label: ac.t('admin.common.actions.cancel'),
              identifier: 'thunderid-action-application-details-edit-cancel',
              variant: AdminButtonVariant.text,
              onPressed: widget.isUpdating ? null : () => setState(() => _draft = null),
            ),
            AdminButton(
              ac: ac,
              label: ac.t('admin.applications.details.edit.save'),
              identifier: 'thunderid-action-application-details-edit-save',
              isLoading: widget.isUpdating,
              onPressed: isValid && onUpdate != null
                  ? () {
                      onUpdate(edit);
                      setState(() => _draft = null);
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

/// Application details that loads the application through the management API.
///
/// Changing data is off by default: set [editable] to offer editing the general fields and the
/// OAuth redirect URIs and grant types, [deletable] to offer delete, and [secretRegenerable] to
/// offer regenerating the client secret (both with confirmation; the new secret is shown once).
/// The server guards applications with the root `system` permission.
class ApplicationDetails extends StatefulWidget {
  final String applicationId;
  final bool deletable;
  final bool editable;
  final bool secretRegenerable;
  final VoidCallback? onDeleted;
  final List<Widget> actions;
  final ThunderIDPreferences? preferences;

  /// Builds custom UI in place of the default view. See [BaseApplicationDetails.builder].
  final AdminWidgetBuilder<ApplicationDetailsState>? builder;

  const ApplicationDetails({
    super.key,
    required this.applicationId,
    this.deletable = false,
    this.editable = false,
    this.secretRegenerable = false,
    this.onDeleted,
    this.actions = const [],
    this.preferences,
    this.builder,
  });

  @override
  State<ApplicationDetails> createState() => _ApplicationDetailsState();
}

class _ApplicationDetailsState extends AdminConnectedState<ApplicationDetails> {
  ResourceQuery<Application>? _application;
  ResourceMutation<String, void>? _delete;
  ResourceMutation<UpdateApplicationVariables, Application>? _update;
  ResourceMutation<String, RegenerateClientSecretResult>? _regenerate;

  @override
  void bind(ManagementResources resources) {
    _application = own(resources.applicationQuery(widget.applicationId));
    _delete = own(resources.deleteApplicationMutation(onSuccess: (_, __) => widget.onDeleted?.call()));
    _update = own(resources.updateApplicationMutation());
    _regenerate = own(resources.regenerateClientSecretMutation());
  }

  @override
  void didUpdateWidget(ApplicationDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.applicationId != widget.applicationId) rebind();
  }

  @override
  Widget build(BuildContext context) {
    final ac = AdminContext.of(context, widget.preferences);
    final application = _application?.data;
    final delete = _delete;
    final update = _update;
    final regenerate = _regenerate;
    return BaseApplicationDetails(
      application: application,
      isLoading: _application?.isLoading ?? !providerFailed,
      error: providerFailed
          ? ac.t('admin.applications.details.error')
          : toManagementErrorMessage(ac.t, _application?.error, 'admin.applications.details.error') ??
              toManagementErrorMessage(ac.t, delete?.error, 'admin.applications.details.delete.error') ??
              toManagementErrorMessage(ac.t, update?.error, 'admin.applications.details.edit.error') ??
              toManagementErrorMessage(ac.t, regenerate?.error, 'admin.applications.details.regenerate.error'),
      isDeleting: delete?.isLoading ?? false,
      onDelete: widget.deletable && delete != null ? () => unawaited(delete.mutate(widget.applicationId)) : null,
      isUpdating: update?.isLoading ?? false,
      onUpdate: widget.editable && update != null && application != null
          ? (edit) => unawaited(
                update.mutate((applicationId: widget.applicationId, data: edit.applyTo(application))),
              )
          : null,
      isRegeneratingSecret: regenerate?.isLoading ?? false,
      onRegenerateSecret: widget.secretRegenerable && regenerate != null
          ? () => unawaited(regenerate.mutate(widget.applicationId))
          : null,
      clientSecret: regenerate?.data?.clientSecret,
      onSecretDismissed: regenerate?.reset,
      actions: widget.actions,
      preferences: widget.preferences,
      builder: widget.builder,
    );
  }
}
