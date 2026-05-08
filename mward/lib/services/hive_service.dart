import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class HiveService {
  static const String _complaintsBoxName = 'complaints_box';
  static const String _notificationsBoxName = 'notifications_box';
  static const String _usersBoxName = 'users_box';
  static const String _settingsBoxName = 'settings_box';

  static Box? _complaintsBox;
  static Box? _notificationsBox;
  static Box? _usersBox;
  static Box? _settingsBox;

  static bool _isInitialized = false;
  static String? _initError;

  // Initialize Hive
  static Future<void> init() async {
    if (_isInitialized) {
      debugPrint('HiveService: Already initialized');
      return;
    }

    try {
      Directory appDocDir;
      
      try {
        appDocDir = await getApplicationDocumentsDirectory();
      } catch (e) {
        // Fallback to temporary directory if getApplicationDocumentsDirectory fails
        debugPrint('HiveService: getApplicationDocumentsDirectory failed, using temp directory: $e');
        appDocDir = Directory.systemTemp;
      }
      
      Hive.init(appDocDir.path);

      // Open boxes
      _complaintsBox = await Hive.openBox(_complaintsBoxName);
      _notificationsBox = await Hive.openBox(_notificationsBoxName);
      _usersBox = await Hive.openBox(_usersBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);
      
      _isInitialized = true;
      _initError = null;
      debugPrint('HiveService: Initialized successfully at ${appDocDir.path}');
    } catch (e) {
      _initError = e.toString();
      _isInitialized = false;
      debugPrint('HiveService: Initialization failed: $e');
      rethrow;
    }
  }

  // Check if Hive is properly initialized
  static bool get isInitialized => _isInitialized;
  static String? get initError => _initError;

  // Close all boxes
  static Future<void> close() async {
    await _complaintsBox?.close();
    await _notificationsBox?.close();
    await _usersBox?.close();
    await _settingsBox?.close();
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _complaintsBox?.clear();
    await _notificationsBox?.clear();
    await _usersBox?.clear();
    await _settingsBox?.clear();
  }

  // Complaints CRUD
  static Future<void> saveComplaint(Map<String, dynamic> complaint) async {
    final id = complaint['complaintId'];
    await _complaintsBox?.put(id, complaint);
  }

  static Map<String, dynamic>? getComplaint(String complaintId) {
    return _complaintsBox?.get(complaintId);
  }

  static List<Map<String, dynamic>> getAllComplaints() {
    final complaints = <Map<String, dynamic>>[];
    for (var key in _complaintsBox?.keys ?? []) {
      final value = _complaintsBox?.get(key);
      if (value != null) {
        complaints.add(Map<String, dynamic>.from(value));
      }
    }
    return complaints;
  }

  static Future<void> deleteComplaint(String complaintId) async {
    await _complaintsBox?.delete(complaintId);
  }

  static Future<void> updateComplaint(String complaintId, Map<String, dynamic> updates) async {
    final complaint = getComplaint(complaintId);
    if (complaint != null) {
      complaint.addAll(updates);
      await saveComplaint(complaint);
    }
  }

  // Notifications CRUD
  static Future<void> saveNotification(Map<String, dynamic> notification) async {
    final id = notification['notificationId'];
    await _notificationsBox?.put(id, notification);
  }

  static Map<String, dynamic>? getNotification(String notificationId) {
    return _notificationsBox?.get(notificationId);
  }

  static List<Map<String, dynamic>> getAllNotifications() {
    final notifications = <Map<String, dynamic>>[];
    for (var key in _notificationsBox?.keys ?? []) {
      final value = _notificationsBox?.get(key);
      if (value != null) {
        notifications.add(Map<String, dynamic>.from(value));
      }
    }
    return notifications;
  }

  static Future<void> deleteNotification(String notificationId) async {
    await _notificationsBox?.delete(notificationId);
  }

  static Future<void> updateNotification(String notificationId, Map<String, dynamic> updates) async {
    final notification = getNotification(notificationId);
    if (notification != null) {
      notification.addAll(updates);
      await saveNotification(notification);
    }
  }

  // Users CRUD
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final id = user['userId'];
    await _usersBox?.put(id, user);
  }

  static Map<String, dynamic>? getUser(String userId) {
    return _usersBox?.get(userId);
  }

  static List<Map<String, dynamic>> getAllUsers() {
    final users = <Map<String, dynamic>>[];
    for (var key in _usersBox?.keys ?? []) {
      final value = _usersBox?.get(key);
      if (value != null) {
        users.add(Map<String, dynamic>.from(value));
      }
    }
    return users;
  }

  static Future<void> deleteUser(String userId) async {
    await _usersBox?.delete(userId);
  }

  // Settings
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox?.get(key, defaultValue: defaultValue);
  }

  static Future<void> deleteSetting(String key) async {
    await _settingsBox?.delete(key);
  }

  // Get box references for direct access
  static Box? get complaintsBox => _complaintsBox;
  static Box? get notificationsBox => _notificationsBox;
  static Box? get usersBox => _usersBox;
  static Box? get settingsBox => _settingsBox;
}
