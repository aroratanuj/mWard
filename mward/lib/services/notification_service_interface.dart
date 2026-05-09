import '../models/notification.dart';

abstract class NotificationService {
  Future<List<Notification>> getUserNotifications(String userId);
  Future<List<Notification>> getAllNotifications();
  Future<void> sendBroadcastNotification({
    required String title,
    required String message,
    required String createdBy,
    String? creatorName,
    String? imageUrl,
    DateTime? expiryDate,
    required int priority,
  });
  Future<void> sendWardNotification({
    required String title,
    required String message,
    required String wardCode,
    required String createdBy,
    String? creatorName,
    String? imageUrl,
    DateTime? expiryDate,
    required int priority,
  });
  Future<void> markAsRead(String notificationId, String userId);
  Future<int> getUnreadCount(String userId);
  Future<void> resetNotifications();
  bool get isLoading;
  String? get error;
  bool get hasError;
}
