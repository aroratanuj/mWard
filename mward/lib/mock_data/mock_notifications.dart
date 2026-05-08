import '../models/notification.dart';
import '../config/mock_config.dart';
import '../utils/constants.dart';

class MockNotifications {
  static List<Notification> getSampleNotifications() {
    final now = DateTime.now();

    return [
      Notification(
        notificationId: 'NOT-001',
        title: 'Important: Ward Meeting Announcement',
        message: 'A ward meeting will be held on 15th May at 4 PM at the Community Center. All residents are requested to attend.',
        messageHindi: '15 मई को शाम 4 बजे सामुदायिक केंद्र में वार्ड बैठक होगी। सभी निवासियों से उपस्थित होने का अनुरोध है।',
        type: 'news',
        imageUrl: 'https://via.placeholder.com/600x300/2196F3/FFFFFF?text=Ward+Meeting',
        wardCode: null, // Broadcast to all
        createdBy: MockConfig.mockAdminId,
        creatorName: 'Ramesh Kumar',
        createdAt: now.subtract(const Duration(hours: 1)),
        expiryDate: now.add(const Duration(days: 3)),
        isRead: false,
        targetAudience: 'all',
        priority: 4,
      ),
      Notification(
        notificationId: 'NOT-002',
        title: '⚠️ Heavy Rain Alert',
        message: 'IMD has issued a heavy rain alert for the next 24 hours. Residents in low-lying areas are advised to stay alert.',
        messageHindi: 'आईएमडी ने अगले 24 घंटों के लिए भारी बारिश की चेतावनी जारी की है। निचले इलाकों के निवासियों को सावधान रहने की सलाह दी जाती है।',
        type: 'alert',
        imageUrl: 'https://via.placeholder.com/600x300/FF5722/FFFFFF?text=Rain+Alert',
        wardCode: null, // Broadcast to all
        createdBy: MockConfig.mockAdminId,
        creatorName: 'Disaster Management',
        createdAt: now.subtract(const Duration(hours: 6)),
        expiryDate: now.add(const Duration(days: 1)),
        isRead: false,
        targetAudience: 'all',
        priority: 5,
      ),
      Notification(
        notificationId: 'NOT-003',
        title: '✅ Road Repair Work Completed',
        message: 'Road repair work on Mall Road has been completed. Thank you for your patience.',
        messageHindi: 'मॉल रोड पर सड़क मरम्मत कार्य पूरा हो गया है। आपके धैर्य के लिए धन्यवाद।',
        type: 'update',
        imageUrl: 'https://via.placeholder.com/600x300/4CAF50/FFFFFF?text=Road+Fixed',
        wardCode: 'WARD-001',
        createdBy: MockConfig.mockAdminId,
        creatorName: 'Municipal Corporation',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
        targetAudience: 'all',
        priority: 3,
      ),
      Notification(
        notificationId: 'NOT-004',
        title: '🏥 COVID-19 Vaccination Drive',
        message: 'Free COVID-19 vaccination drive at Community Health Center from 10 AM to 4 PM. Bring your Aadhaar card.',
        messageHindi: 'सामुदायिक स्वास्थ्य केंद्र में सुबह 10 बजे से शाम 4 बजे तक मुफ्त कोविड-19 टीकाकरण अभियान। अपना आधार कार्ड लाएं।',
        type: 'broadcast',
        imageUrl: 'https://via.placeholder.com/600x300/9C27B0/FFFFFF?text=Vaccination',
        wardCode: null, // Broadcast to all
        createdBy: 'health-dept',
        creatorName: 'Health Department',
        createdAt: now.subtract(const Duration(days: 2)),
        expiryDate: now.add(const Duration(days: 5)),
        isRead: true,
        targetAudience: 'all',
        priority: 4,
      ),
      Notification(
        notificationId: 'NOT-005',
        title: '🗑️ Garbage Collection Schedule Change',
        message: 'Due to the upcoming festival, garbage collection schedule has been changed to 7 AM instead of 8 AM for next week.',
        messageHindi: 'आगामी त्योहार के कारण, अगले सप्ताह कूड़ा संग्रह का समय सुबह 8 बजे के बजाय सुबह 7 बजे कर दिया गया है।',
        type: 'update',
        wardCode: 'WARD-001',
        createdBy: MockConfig.mockAdminId,
        creatorName: 'Sanitation Department',
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: false,
        targetAudience: 'all',
        priority: 2,
      ),
      Notification(
        notificationId: 'NOT-006',
        title: '🚨 Urgent: Water Supply Maintenance',
        message: 'Emergency maintenance work on main water pipeline. Water supply will be affected in Ward 1, 2, and 3 from 2 PM to 6 PM today.',
        messageHindi: 'मुख्य पानी पाइपलाइन पर आपातकालीन रखरखाव कार्य। आज दोपहर 2 बजे से शाम 6 बजे तक वार्ड 1, 2 और 3 में पानी की आपूर्ति प्रभावित रहेगी।',
        type: 'alert',
        wardCode: 'WARD-001',
        createdBy: MockConfig.mockAdminId,
        creatorName: 'Water Supply Department',
        createdAt: now.subtract(const Duration(hours: 12)),
        expiryDate: now.add(const Duration(hours: 6)),
        isRead: false,
        targetAudience: 'all',
        priority: 5,
      ),
      Notification(
        notificationId: 'NOT-007',
        title: '🎉 Independence Day Celebration',
        message: 'Join us for Independence Day celebration at the main ground on 15th August at 8 AM. Cultural programs and flag hoisting.',
        messageHindi: '15 अगस्त को सुबह 8 बजे मुख्य मैदान पर स्वतंत्रता दिवस समारोह में शामिल हों। सांस्कृतिक कार्यक्रम और झंडारोहण।',
        type: 'news',
        imageUrl: 'https://via.placeholder.com/600x300/FF6F00/FFFFFF?text=Independence+Day',
        wardCode: null, // Broadcast to all
        createdBy: MockConfig.mockAdminId,
        creatorName: 'Ward Office',
        createdAt: now.subtract(const Duration(days: 5)),
        expiryDate: now.add(const Duration(days: 10)),
        isRead: true,
        targetAudience: 'all',
        priority: 3,
      ),
    ];
  }

  static List<Notification> getNotificationsByUserId(String userId) {
    // Return all notifications for user (both broadcast and ward-specific)
    return getSampleNotifications()
        .where((notification) =>
            notification.targetAudience == 'all' ||
            notification.wardCode == MockConfig.mockWardCode)
        .toList();
  }

  static List<Notification> getNotificationsByWardCode(String wardCode) {
    return getSampleNotifications()
        .where((notification) =>
            notification.wardCode == null ||
            notification.wardCode == wardCode)
        .toList();
  }

  static Notification? getNotificationById(String notificationId) {
    try {
      return getSampleNotifications()
          .firstWhere((notification) => notification.notificationId == notificationId);
    } catch (e) {
      return null;
    }
  }

  static List<Notification> getUnreadNotifications() {
    return getSampleNotifications()
        .where((notification) => !notification.isRead)
        .toList();
  }

  static List<Notification> getBroadcastNotifications() {
    return getSampleNotifications()
        .where((notification) => notification.wardCode == null)
        .toList();
  }

  static List<Notification> getHighPriorityNotifications() {
    return getSampleNotifications()
        .where((notification) => notification.priority >= 4)
        .toList();
  }
}
