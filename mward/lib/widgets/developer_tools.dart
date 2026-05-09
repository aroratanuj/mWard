import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/mock_config.dart';
import '../providers/auth_provider.dart';
import '../providers/complaint_provider.dart';
import '../providers/notification_provider.dart';
import '../services/hive_service.dart';

class DeveloperTools extends StatelessWidget {
  const DeveloperTools({super.key});

  @override
  Widget build(BuildContext context) {
    if (!MockConfig.isMockMode) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Developer Tools',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Auth Actions
          const Text(
            'Authentication',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _loginAsUser(context),
                icon: const Icon(Icons.person, size: 16),
                label: const Text('Login as User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _loginAsAdmin(context),
                icon: const Icon(Icons.admin_panel_settings, size: 16),
                label: const Text('Login as Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                },
                icon: const Icon(Icons.logout, size: 16),
                label: const Text('Logout'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data Management
          const Text(
            'Data Management',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _clearAllData(context),
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear All Data'),
              ),
              OutlinedButton.icon(
                onPressed: () => _resetToDefaults(context),
                icon: const Icon(Icons.restore, size: 16),
                label: const Text('Reset to Defaults'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mock Configuration
          const Text(
            'Mock Configuration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Mock Mode'),
            subtitle: const Text('Toggle between demo and production mode'),
            value: MockConfig.isMockMode,
            onChanged: (value) {
              if (value) {
                MockConfig.enableMockMode();
              } else {
                MockConfig.disableMockMode();
              }
            },
          ),
          SwitchListTile(
            title: const Text('Show Mock Banner'),
            value: MockConfig.showMockBanner,
            onChanged: (value) {
              MockConfig.showMockBanner = value;
            },
          ),
          SwitchListTile(
            title: const Text('Persist Data'),
            subtitle: const Text('Keep mock data between app restarts'),
            value: MockConfig.persistData,
            onChanged: (value) {
              MockConfig.persistData = value;
            },
          ),
          const SizedBox(height: 16),

          // Quick Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Info',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoItem('Test Phone (User)', MockConfig.testPhoneUser),
                const SizedBox(height: 4),
                _buildInfoItem('Test Phone (Admin)', MockConfig.testPhoneAdmin),
                const SizedBox(height: 4),
                _buildInfoItem('Test OTP', MockConfig.testOTP),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _loginAsUser(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.sendOTP(MockConfig.testPhoneUser);
      await authProvider.verifyOTP(MockConfig.testPhoneUser, MockConfig.testOTP);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged in as User'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to login: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _loginAsAdmin(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.sendOTP(MockConfig.testPhoneAdmin);
      await authProvider.verifyOTP(MockConfig.testPhoneAdmin, MockConfig.testOTP);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged in as Admin'),
            backgroundColor: Colors.purple,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to login: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will delete all mock data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await HiveService.clearAll();
      if (context.mounted) {
        final complaintProvider = context.read<ComplaintProvider>();
        final notificationProvider = context.read<NotificationProvider>();
        await complaintProvider.resetComplaints();
        await notificationProvider.resetNotifications();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _resetToDefaults(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text('This will reset all settings to default values. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Reset to defaults
      MockConfig.isMockMode = true;
      MockConfig.showMockBanner = true;
      MockConfig.persistData = true;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings reset to defaults'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const DeveloperTools(),
    );
  }
}
