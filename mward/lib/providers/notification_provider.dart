import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/notification_service_interface.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service;
  
  List<Notification> _notifications = [];
  List<Notification> _userNotifications = [];
  bool _isLoading = false;
  String? _error;

  List<Notification> get notifications => _notifications;
  List<Notification> get userNotifications => _userNotifications;
  bool get isLoading => _service.isLoading;
  String? get error => _service.error;
  bool get hasError => _service.hasError;
  int get unreadCount => _userNotifications.where((n) => !n.isRead).length;

  NotificationProvider(this._service);

  Future<void> loadAllNotifications() async {
    try {
      _notifications = await _service.getAllNotifications();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadUserNotifications(String userId) async {
    try {
      _userNotifications = await _service.getUserNotifications(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendBroadcastNotification({
    required String title,
    required String message,
    required String createdBy,
    String? creatorName,
    String? imageUrl,
    DateTime? expiryDate,
    required int priority,
  }) async {
    try {
      await _service.sendBroadcastNotification(
        title: title,
        message: message,
        createdBy: createdBy,
        creatorName: creatorName,
        imageUrl: imageUrl,
        expiryDate: expiryDate,
        priority: priority,
      );
      await loadAllNotifications();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> sendWardNotification({
    required String title,
    required String message,
    required String wardCode,
    required String createdBy,
    String? creatorName,
    String? imageUrl,
    DateTime? expiryDate,
    required int priority,
  }) async {
    try {
      await _service.sendWardNotification(
        title: title,
        message: message,
        wardCode: wardCode,
        createdBy: createdBy,
        creatorName: creatorName,
        imageUrl: imageUrl,
        expiryDate: expiryDate,
        priority: priority,
      );
      await loadAllNotifications();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    try {
      await _service.markAsRead(notificationId, userId);
      
      // Update local notification
      final index = _userNotifications.indexWhere((n) => n.notificationId == notificationId);
      if (index != -1) {
        final updated = _userNotifications[index].copyWith(isRead: true);
        _userNotifications[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> resetNotifications() async {
    await _service.resetNotifications();
    _notifications.clear();
    _userNotifications.clear();
    notifyListeners();
  }
}
