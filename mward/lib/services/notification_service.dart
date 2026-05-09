import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'dart:convert';
import '../models/notification.dart';
import 'notification_service_interface.dart';

class AmplifyNotificationService implements NotificationService {
  static const String _notificationsTable = 'notifications';
  bool _isLoading = false;
  String? _error;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  @override
  bool get hasError => _error != null;

  // Get all notifications for user
  Future<List<Notification>> getUserNotifications(String userId) async {
    try {
      final request = GraphQLRequest(
        document: '''
          query GetUserNotifications(\$userId: ID!) {
            listNotifications(filter: {
              targetAudience: { eq: "all" }
            }) {
              items {
                notificationId
                title
                message
                type
                imageUrl
                wardCode
                createdBy
                creatorName
                createdAt
                expiryDate
                isRead
                targetAudience
                priority
              }
              nextToken
            }
          }
        ''',
        variables: {'userId': userId},
      );

      final response = await Amplify.API.query(request: request).response;
      final data = jsonDecode(response.data);

      final notifications = (data['listNotifications']['items'] as List)
          .map((item) => Notification.fromJson(item))
          .toList();

      return notifications.where((n) => !n.isExpired).toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // Get notifications for specific ward
  Future<List<Notification>> getWardNotifications(String wardCode) async {
    try {
      final request = GraphQLRequest(
        document: '''
          query GetWardNotifications(\$wardCode: String) {
            queryNotificationsByWardCode(
              wardCode: \$wardCode
              sortDirection: DESC
            ) {
              items {
                notificationId
                title
                message
                type
                imageUrl
                wardCode
                createdBy
                creatorName
                createdAt
                expiryDate
                isRead
                targetAudience
                priority
              }
              nextToken
            }
          }
        ''',
        variables: {'wardCode': wardCode},
      );

      final response = await Amplify.API.query(request: request).response;
      final data = jsonDecode(response.data);

      final notifications = (data['queryNotificationsByWardCode']['items'] as List)
          .map((item) => Notification.fromJson(item))
          .toList();

      return notifications.where((n) => !n.isExpired).toList();
    } catch (e) {
      throw Exception('Failed to fetch ward notifications: $e');
    }
  }

  // Get all notifications (admin only)
  Future<List<Notification>> getAllNotifications() async {
    try {
      final request = GraphQLRequest(
        document: '''
          query GetAllNotifications {
            listNotifications {
              items {
                notificationId
                title
                message
                type
                imageUrl
                wardCode
                createdBy
                creatorName
                createdAt
                expiryDate
                isRead
                targetAudience
                priority
              }
              nextToken
            }
          }
        ''',
      );

      final response = await Amplify.API.query(request: request).response;
      final data = jsonDecode(response.data);

      return (data['listNotifications']['items'] as List)
          .map((item) => Notification.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all notifications: $e');
    }
  }

  // Create notification (admin only)
  Future<Notification> createNotification(Notification notification) async {
    try {
      final request = GraphQLRequest(
        document: '''
          mutation CreateNotification(\$input: CreateNotificationInput!) {
            createNotification(input: \$input) {
              notificationId
              title
              message
              type
              imageUrl
              wardCode
              createdBy
              creatorName
              createdAt
              expiryDate
              isRead
              targetAudience
              priority
            }
          }
        ''',
        variables: {
          'input': notification.toJson(),
        },
      );

      final response = await Amplify.API.mutate(request: request).response;
      final data = jsonDecode(response.data);

      return Notification.fromJson(data['createNotification']);
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  // Update notification (admin only)
  Future<Notification> updateNotification(Notification notification) async {
    try {
      final request = GraphQLRequest(
        document: '''
          mutation UpdateNotification(\$input: UpdateNotificationInput!) {
            updateNotification(input: \$input) {
              notificationId
              title
              message
              type
              imageUrl
              wardCode
              createdBy
              creatorName
              createdAt
              expiryDate
              isRead
              targetAudience
              priority
            }
          }
        ''',
        variables: {
          'input': notification.toJson(),
        },
      );

      final response = await Amplify.API.mutate(request: request).response;
      final data = jsonDecode(response.data);

      return Notification.fromJson(data['updateNotification']);
    } catch (e) {
      throw Exception('Failed to update notification: $e');
    }
  }

  // Delete notification (admin only)
  Future<void> deleteNotification(String notificationId) async {
    try {
      final request = GraphQLRequest(
        document: '''
          mutation DeleteNotification(\$notificationId: ID!) {
            deleteNotification(input: { notificationId: \$notificationId }) {
              notificationId
            }
          }
        ''',
        variables: {'notificationId': notificationId},
      );

      await Amplify.API.mutate(request: request).response;
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId, String userId) async {
    try {
      // This would typically update a user_notification join table
      // For simplicity, we'll use a separate API call
      final request = GraphQLRequest(
        document: '''
          mutation MarkNotificationAsRead(\$notificationId: ID!, \$userId: ID!) {
            markNotificationAsRead(
              notificationId: \$notificationId
              userId: \$userId
            ) {
              success
            }
          }
        ''',
        variables: {
          'notificationId': notificationId,
          'userId': userId,
        },
      );

      await Amplify.API.mutate(request: request).response;
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Get unread count for user
  Future<int> getUnreadCount(String userId) async {
    try {
      final notifications = await getUserNotifications(userId);
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      return 0;
    }
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
      targetAudience: 'all',
      priority: priority,
    );

    return await createNotification(notification);
  }

  @override
  Future<void> resetNotifications() async {
    // No-op for real service - notifications are in the backend
    _error = null;
  }
}
