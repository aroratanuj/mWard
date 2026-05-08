import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<Notification> _notifications = [];
  List<Notification> _userNotifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<Notification> get notifications => _notifications;
  List<Notification> get userNotifications => _userNotifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all notifications (admin)
  Future<void> loadAllNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getAllNotifications();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user notifications
  Future<void> loadUserNotifications(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userNotifications = await _notificationService.getUserNotifications(userId);
      _unreadCount = _userNotifications.where((n) => !n.isRead).length;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load ward notifications
  Future<void> loadWardNotifications(String wardCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userNotifications = await _notificationService.getWardNotifications(wardCode);
      _unreadCount = _userNotifications.where((n) => !n.isRead).length;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create notification (admin)
  Future<void> createNotification(Notification notification) async {
    try {
      final created = await _notificationService.createNotification(notification);
      _notifications.insert(0, created);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update notification (admin)
  Future<void> updateNotification(Notification notification) async {
    try {
      final updated = await _notificationService.updateNotification(notification);
      final index = _notifications.indexWhere(
        (n) => n.notificationId == updated.notificationId,
      );
      if (index != -1) {
        _notifications[index] = updated;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete notification (admin)
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.notificationId == notificationId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId, String userId) async {
    try {
      await _notificationService.markAsRead(notificationId, userId);
      final index = _userNotifications.indexWhere(
        (n) => n.notificationId == notificationId,
      );
      if (index != -1) {
        final updated = Notification(
          notificationId: _userNotifications[index].notificationId,
          title: _userNotifications[index].title,
          message: _userNotifications[index].message,
          type: _userNotifications[index].type,
          imageUrl: _userNotifications[index].imageUrl,
          wardCode: _userNotifications[index].wardCode,
          createdBy: _userNotifications[index].createdBy,
          creatorName: _userNotifications[index].creatorName,
          createdAt: _userNotifications[index].createdAt,
          expiryDate: _userNotifications[index].expiryDate,
          isRead: true,
          targetAudience: _userNotifications[index].targetAudience,
          priority: _userNotifications[index].priority,
        );
        _userNotifications[index] = updated;
        _unreadCount = _userNotifications.where((n) => !n.isRead).length;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Send broadcast notification (admin)
  Future<void> sendBroadcastNotification({
    required String title,
    required String message,
    required String createdBy,
    String? creatorName,
    String? imageUrl,
    DateTime? expiryDate,
    int priority = 5,
  }) async {
    try {
      final notification = await _notificationService.sendBroadcastNotification(
        title: title,
        message: message,
        createdBy: createdBy,
        creatorName: creatorName,
        imageUrl: imageUrl,
        expiryDate: expiryDate,
        priority: priority,
      );
      _notifications.insert(0, notification);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Send ward notification (admin)
  Future<void> sendWardNotification({
    required String title,
    required String message,
    required String wardCode,
    required String createdBy,
    String? creatorName,
    String? imageUrl,
    DateTime? expiryDate,
    int priority = 3,
  }) async {
    try {
      final notification = await _notificationService.sendWardNotification(
        title: title,
        message: message,
        wardCode: wardCode,
        createdBy: createdBy,
        creatorName: creatorName,
        imageUrl: imageUrl,
        expiryDate: expiryDate,
        priority: priority,
      );
      _notifications.insert(0, notification);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
