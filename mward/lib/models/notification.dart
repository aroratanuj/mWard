import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class Notification {
  final String notificationId;
  final String title;
  final String message;
  final String? messageHindi;
  final String type; // 'news', 'alert', 'update', 'broadcast'
  final String? imageUrl;
  final String? wardCode; // null means broadcast to all wards
  final String createdBy;
  final String? creatorName;
  final DateTime createdAt;
  final DateTime? expiryDate;
  final bool isRead;
  final String? targetAudience; // 'all', 'users', 'admins'
  final int priority; // 1-5, 5 being highest

  Notification({
    required this.notificationId,
    required this.title,
    required this.message,
    this.messageHindi,
    required this.type,
    this.imageUrl,
    this.wardCode,
    required this.createdBy,
    this.creatorName,
    required this.createdAt,
    this.expiryDate,
    this.isRead = false,
    this.targetAudience = 'all',
    this.priority = 3,
  });

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  bool get isExpired =>
      expiryDate != null && DateTime.now().isAfter(expiryDate!);

  bool get isBroadcast => wardCode == null;

  bool get isHighPriority => priority >= 4;

  Notification copyWith({
    String? notificationId,
    String? title,
    String? message,
    String? messageHindi,
    String? type,
    String? imageUrl,
    String? wardCode,
    String? createdBy,
    String? creatorName,
    DateTime? createdAt,
    DateTime? expiryDate,
    bool? isRead,
    String? targetAudience,
    int? priority,
  }) {
    return Notification(
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      message: message ?? this.message,
      messageHindi: messageHindi ?? this.messageHindi,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      wardCode: wardCode ?? this.wardCode,
      createdBy: createdBy ?? this.createdBy,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      expiryDate: expiryDate ?? this.expiryDate,
      isRead: isRead ?? this.isRead,
      targetAudience: targetAudience ?? this.targetAudience,
      priority: priority ?? this.priority,
    );
  }
}
