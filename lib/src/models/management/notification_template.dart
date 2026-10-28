// Copyright 2026 The ThunderID Authors
// SPDX-License-Identifier: Apache-2.0

import 'json_reader.dart';

/// The channels notification templates exist for, each under
/// `/notification-templates/{channel}/templates`.
enum NotificationChannel {
  email('email'),
  sms('sms');

  /// The wire value, also the URL segment.
  final String value;

  const NotificationChannel(this.value);
}

/// A notification template as listed.
class NotificationTemplateSummary {
  final String id;
  final String handle;
  final String displayName;
  final String? description;

  /// The template's own URL.
  final String? self;

  const NotificationTemplateSummary({
    required this.id,
    required this.handle,
    required this.displayName,
    this.description,
    this.self,
  });

  factory NotificationTemplateSummary.fromJson(Map<String, dynamic> json) => NotificationTemplateSummary(
        id: readString(json, 'id'),
        handle: readString(json, 'handle'),
        displayName: readString(json, 'displayName'),
        description: readOptionalString(json, 'description'),
        self: readOptionalString(json, 'self'),
      );
}

/// What a template sends: a [body], and for email a [subject].
class NotificationTemplateContent {
  /// Email only.
  final String? subject;
  final String body;

  const NotificationTemplateContent({required this.body, this.subject});

  factory NotificationTemplateContent.fromJson(Map<String, dynamic> json) =>
      NotificationTemplateContent(body: readString(json, 'body'), subject: readOptionalString(json, 'subject'));

  Map<String, dynamic> toJson() => {if (subject != null) 'subject': subject, 'body': body};
}

/// A notification template, email or SMS.
class NotificationTemplate {
  final String id;
  final String ouId;
  final String handle;
  final String displayName;
  final String? description;
  final bool isReadOnly;
  final NotificationTemplateContent content;

  /// Email only: `light` or `dark`.
  final String? colorScheme;

  const NotificationTemplate({
    required this.id,
    required this.ouId,
    required this.handle,
    required this.displayName,
    required this.content,
    this.description,
    this.isReadOnly = false,
    this.colorScheme,
  });

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) => NotificationTemplate(
        id: readString(json, 'id'),
        ouId: readString(json, 'ouId'),
        handle: readString(json, 'handle'),
        displayName: readString(json, 'displayName'),
        description: readOptionalString(json, 'description'),
        isReadOnly: readOptionalBool(json, 'isReadOnly') ?? false,
        content: NotificationTemplateContent.fromJson(readMap(json['content'])),
        colorScheme: readOptionalString(readMap(json['design']), 'colorScheme'),
      );
}

/// Payload for creating a notification template.
class CreateNotificationTemplateRequest {
  final String handle;
  final String ouId;
  final String displayName;
  final String? description;
  final NotificationTemplateContent content;

  /// Email only: `light` or `dark`.
  final String? colorScheme;

  const CreateNotificationTemplateRequest({
    required this.handle,
    required this.ouId,
    required this.displayName,
    required this.content,
    this.description,
    this.colorScheme,
  });

  Map<String, dynamic> toJson() => {
        'handle': handle,
        'ouId': ouId,
        'displayName': displayName,
        if (description != null) 'description': description,
        if (colorScheme != null) 'design': {'colorScheme': colorScheme},
        'content': content.toJson(),
      };
}

/// Payload for updating a notification template. The handle and organization unit are fixed.
class UpdateNotificationTemplateRequest {
  final String displayName;
  final String? description;
  final NotificationTemplateContent content;

  /// Email only: `light` or `dark`.
  final String? colorScheme;

  const UpdateNotificationTemplateRequest({
    required this.displayName,
    required this.content,
    this.description,
    this.colorScheme,
  });

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        if (description != null) 'description': description,
        if (colorScheme != null) 'design': {'colorScheme': colorScheme},
        'content': content.toJson(),
      };
}
