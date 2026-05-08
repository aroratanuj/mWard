import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../utils/constants.dart';

class AppHelpers {
  static String formatDate(DateTime date, {String format = AppConstants.dateFormat}) {
    return DateFormat(format).format(date);
  }

  static String formatTime(DateTime time, {String format = AppConstants.timeFormat}) {
    return DateFormat(format).format(time);
  }

  static String formatDateTime(DateTime dateTime, {String format = AppConstants.dateTimeFormat}) {
    return DateFormat(format).format(dateTime);
  }

  static String formatRelativeTime(DateTime dateTime) {
    return timeago.format(dateTime, locale: 'en');
  }

  static String formatRelativeTimeHindi(DateTime dateTime) {
    return timeago.format(dateTime, locale: 'hi');
  }

  static String formatPhoneNumber(String phone) {
    // Format: +91 98765 43210
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('+91') && cleaned.length == 13) {
      return '+91 ${cleaned.substring(3, 8)} ${cleaned.substring(8)}';
    }
    return phone;
  }

  static String getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      default:
        return priority;
    }
  }

  static String getPriorityLabelHindi(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'कम';
      case 'medium':
        return 'मध्यम';
      case 'high':
        return 'उच्च';
      default:
        return priority;
    }
  }

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in-progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  static String getStatusLabelHindi(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'लंबित';
      case 'in-progress':
        return 'प्रगति में';
      case 'resolved':
        return 'हल';
      case 'rejected':
        return 'अस्वीकृत';
      default:
        return status;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in-progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'in-progress':
        return Icons.autorenew;
      case 'resolved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  static String getCategoryLabel(String category) {
    final index = AppConstants.complaintCategories.indexOf(category);
    if (index != -1 && index < AppConstants.complaintCategoriesHindi.length) {
      return '${AppConstants.complaintCategoriesHindi[index]} (${category})';
    }
    return category;
  }

  static String getNotificationTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'news':
        return 'News';
      case 'alert':
        return 'Alert';
      case 'update':
        return 'Update';
      case 'broadcast':
        return 'Broadcast';
      default:
        return type;
    }
  }

  static String getNotificationTypeLabelHindi(String type) {
    switch (type.toLowerCase()) {
      case 'news':
        return 'समाचार';
      case 'alert':
        return 'चेतावनी';
      case 'update':
        return 'अपडेट';
      case 'broadcast':
        return 'प्रसारण';
      default:
        return type;
    }
  }

  static IconData getNotificationTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'news':
        return Icons.newspaper;
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'update':
        return Icons.update;
      case 'broadcast':
        return Icons.broadcast_on_personal;
      default:
        return Icons.notifications;
    }
  }

  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0].toUpperCase()}${parts[parts.length - 1][0].toUpperCase()}';
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static List<String> splitName(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return ['', ''];
    if (parts.length == 1) return [parts[0], ''];
    final firstName = parts.sublist(0, parts.length - 1).join(' ');
    final lastName = parts.last;
    return [firstName, lastName];
  }

  static String generateComplaintId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (DateTime.now().microsecond % 1000).toString().padLeft(3, '0');
    return 'CMP-$timestamp-$random';
  }

  static String generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'USR-$timestamp';
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  static String getGreetingHindi() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'सुप्रभात';
    } else if (hour < 17) {
      return 'शुभ दोपहर';
    } else {
      return 'शुभ संध्या';
    }
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  static bool isImageFile(String fileName) {
    final ext = getFileExtension(fileName);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
