import '../models/user.dart';
import '../utils/constants.dart';
import '../config/mock_config.dart';

class MockUsers {
  static List<User> getSampleUsers() {
    return [
      User(
        userId: MockConfig.mockAdminId,
        phoneNumber: MockConfig.testPhoneAdmin,
        name: 'Ramesh Kumar',
        email: 'ramesh.kumar@example.com',
        role: AppConstants.roleAdmin,
        wardCode: 'WARD-001',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastActive: DateTime.now(),
      ),
      User(
        userId: MockConfig.mockUserId,
        phoneNumber: MockConfig.testPhoneUser,
        name: 'Sita Devi',
        email: 'sita.devi@example.com',
        role: AppConstants.roleUser,
        wardCode: 'WARD-001',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastActive: DateTime.now(),
      ),
      User(
        userId: 'user-002',
        phoneNumber: '+919876543212',
        name: 'Rajesh Singh',
        email: 'rajesh.singh@example.com',
        role: AppConstants.roleUser,
        wardCode: 'WARD-002',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      User(
        userId: 'user-003',
        phoneNumber: '+919876543213',
        name: 'Anita Thakur',
        email: 'anita.thakur@example.com',
        role: AppConstants.roleUser,
        wardCode: 'WARD-003',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        lastActive: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      User(
        userId: 'user-004',
        phoneNumber: '+919876543214',
        name: 'Sunil Verma',
        email: 'sunil.verma@example.com',
        role: AppConstants.roleUser,
        wardCode: 'WARD-001',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        lastActive: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      User(
        userId: 'user-005',
        phoneNumber: '+919876543215',
        name: 'Priya Sharma',
        email: 'priya.sharma@example.com',
        role: AppConstants.roleUser,
        wardCode: 'WARD-004',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        lastActive: DateTime.now(),
      ),
    ];
  }

  static User? getUserByPhone(String phoneNumber) {
    return getSampleUsers().firstWhere(
      (user) => user.phoneNumber == phoneNumber,
      orElse: () => User(
        userId: DateTime.now().millisecondsSinceEpoch.toString(),
        phoneNumber: phoneNumber,
        role: AppConstants.roleUser,
        createdAt: DateTime.now(),
      ),
    );
  }

  static User? getUserById(String userId) {
    try {
      return getSampleUsers().firstWhere((user) => user.userId == userId);
    } catch (e) {
      return null;
    }
  }
}
