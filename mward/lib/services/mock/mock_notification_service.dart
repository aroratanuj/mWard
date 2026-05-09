import 'package:flutter/foundation.dart';
import '../../models/notification.dart';
import '../../mock_data/mock_notifications.dart';
import '../../config/mock_config.dart';
import '../hive_service.dart';
import '../notification_service_interface.dart';

class MockNotificationService implements NotificationService {
  bool _isLoading = false;
  String? _error;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  @override
  bool get hasError => _error != null;
  // Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: MockConfig.mockApiDelay));
  }

  // Get all notifications (Admin)
  Future<List<Notification>> getAllNotifications() async {
    await _simulateDelay();
    
    // Try to get from Hive first (persisted data)
    if (MockConfig.persistData) {
      final hiveNotifications = HiveService.getAllNotifications();
      if (hiveNotifications.isNotEmpty) {
        return hiveNotifications.map((n) => Notification.fromJson(n)).toList();
      }
    }
    
    // Return sample data
    return MockNotifications.getSampleNotifications();
  }

  // Get user notifications
  Future<List<Notification>> getUserNotifications(String userId) async {
    await _simulateDelay();
    
    // Try to get from Hive first
    if (MockConfig.persistData) {
      final hiveNotifications = HiveService.getAllNotifications();
      if (hiveNotifications.isNotEmpty) {
        return hiveNotifications
            .map((n) => Notification.fromJson(n))
            .where((n) => !n.isExpired)
            .toList();
      }
    }
    
    // Return sample data
    return MockNotifications.getNotificationsByUserId(userId);
  }

  // Get notifications for specific ward
  Future<List<Notification>> getWardNotifications(String wardCode) async {
    await _simulateDelay();
    
    if (MockConfig.persistData) {
      final hiveNotifications = HiveService.getAllNotifications();
      final wardNotifications = hiveNotifications
          .where((n) => 
              n['wardCode'] == null || 
              n['wardCode'] == wardCode)
          .map((n) => Notification.fromJson(n))
          .where((n) => !n.isExpired)
          .toList();
      
      if (wardNotifications.isNotEmpty) {
        return wardNotifications;
      }
    }
    
    return MockNotifications.getNotificationsByWardCode(wardCode);
  }

  // Get notification by ID
  Future<Notification?> getNotificationById(String notificationId) async {
    await _simulateDelay();
    
    if (MockConfig.persistData) {
      final hiveNotification = HiveService.getNotification(notificationId);
      if (hiveNotification != null) {
        return Notification.fromJson(hiveNotification);
      }
    }
    
    return MockNotifications.getNotificationById(notificationId);
  }

  // Create notification (Admin)
  Future<Notification> createNotification(Notification notification) async {
    await _simulateDelay();

    // Save to Hive if persistence is enabled
    if (MockConfig.persistData) {
      await HiveService.saveNotification(notification.toJson());
    }

    debugPrint('Mock: Notification created: ${notification.notificationId}');
    return notification;
  }

  // Update notification (Admin)
  Future<Notification> updateNotification(Notification notification) async {
    await _simulateDelay();

    // Update in Hive
    if (MockConfig.persistData) {
      await HiveService.updateNotification(
        notification.notificationId,
        notification.toJson(),
      );
    }

    debugPrint('Mock: Notification updated: ${notification.notificationId}');
    return notification;
  }

  // Delete notification (Admin)
  Future<void> deleteNotification(String notificationId) async {
    await _simulateDelay();

    if (MockConfig.persistData) {
      await HiveService.deleteNotification(notificationId);
    }

    debugPrint('Mock: Notification deleted: $notificationId');
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId, String userId) async {
    await _simulateDelay();

    // This would typically update a user_notification join table
    // For simplicity, we'll update the notification directly
    final notification = await getNotificationById(notificationId);
    if (notification != null) {
      final updatedNotification = Notification(
        notificationId: notification.notificationId,
        title: notification.title,
        message: notification.message,
        type: notification.type,
        imageUrl: notification.imageUrl,
        wardCode: notification.wardCode,
        createdBy: notification.createdBy,
        creatorName: notification.creatorName,
        createdAt: notification.createdAt,
        expiryDate: notification.expiryDate,
        isRead: true,
        targetAudience: notification.targetAudience,
        priority: notification.priority,
      );

      if (MockConfig.persistData) {
        await HiveService.updateNotification(
          notificationId,
          updatedNotification.toJson(),
        );
      }

      debugPrint('Mock: Notification marked as read: $notificationId');
    }
  }

  // Mark all notifications as read for user
  Future<void> markAllAsRead(String userId) async {
    await _simulateDelay();

    final notifications = await getUserNotifications(userId);
    for (final notification in notifications) {
      if (!notification.isRead) {
        await markAsRead(notification.notificationId, userId);
      }
    }

    debugPrint('Mock: All notifications marked as read for user: $userId');
  }

  // Get unread count for user
  Future<int> getUnreadCount(String userId) async {
    await _simulateDelay();

    final notifications = await getUserNotifications(userId);
    return notifications.where((n) => !n.isRead).length;
  }

  // Send broadcast notification (to all users across all wards)
  Future<Notification> sendBroadcastNotification({
    required String title,
    required String message,
    required String createdBy,
    String? creatorName,
    String? imageUrl,
    DateTime? expiryDate,
    int priority = 5,
  }) async {
    await _simulateDelay();

    final notification = Notification(
      notificationId: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: 'broadcast',
      imageUrl: imageUrl,
      wardCode: null, // null means all wards
      createdBy: createdBy,
      creatorName: creatorName,
      createdAt: DateTime.now(),
      expiryDate: expiryDate,
      isRead: false,
      targetAudience: 'all',
      priority: priority,
    );

    return await createNotification(notification);
  }

  // Send ward-specific notification
  Future<Notification> sendWardNotification({
    required String title,
    required String message,
    required String wardCode,
    required String createdBy,
    String? creatorName,
    String? imageUrl,
    DateTime? expiryDate,
    int priority = 3,
  }) async {
    await _simulateDelay();

    final notification = Notification(
      notificationId: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: 'update',
      imageUrl: imageUrl,
      wardCode: wardCode,
      createdBy: createdBy,
      creatorName: creatorName,
      createdAt: DateTime.now(),
      expiryDate: expiryDate,
      isRead: false,
      targetAudience: 'all',
      priority: priority,
    );

    return await createNotification(notification);
  }

  // Get notifications by type
  Future<List<Notification>> getNotificationsByType(String type) async {
    await _simulateDelay();

    final allNotifications = await getAllNotifications();
    return allNotifications.where((n) => n.type == type).toList();
  }

  // Get high priority notifications
  Future<List<Notification>> getHighPriorityNotifications() async {
    await _simulateDelay();

    final allNotifications = await getAllNotifications();
    return allNotifications.where((n) => n.isHighPriority).toList();
  }

  // Get broadcast notifications
  Future<List<Notification>> getBroadcastNotifications() async {
    await _simulateDelay();

    final allNotifications = await getAllNotifications();
    return allNotifications.where((n) => n.isBroadcast).toList();
  }

  // Search notifications
  Future<List<Notification>> searchNotifications(String query) async {
    await _simulateDelay();

    final allNotifications = await getAllNotifications();
    final lowerQuery = query.toLowerCase();

    return allNotifications.where((notification) {
      return notification.title.toLowerCase().contains(lowerQuery) ||
          notification.message.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Reset all notifications (for testing)
  @override
  Future<void> resetNotifications() async {
    if (MockConfig.persistData) {
      await HiveService.deleteNotification('all'); // Clear all
    }
    _error = null;
    debugPrint('Mock: All notifications reset');
  }
}
