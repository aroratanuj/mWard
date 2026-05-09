import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/mock_config.dart';
import '../providers/auth_provider.dart' as real_auth;
import '../providers/mock/mock_auth_provider.dart';
import '../providers/complaint_provider.dart' as real_complaint;
import '../providers/mock/mock_complaint_provider.dart';
import '../providers/notification_provider.dart' as real_notification;
import '../providers/mock/mock_notification_provider.dart';
import '../services/hive_service.dart';
import '../screens/complaint/file_complaint_screen.dart';
import '../screens/admin/create_notification_screen.dart';

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
          Row(
            children: [
              Icon(
                Icons.developer_mode,
                size: 20,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Developer Tools',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickButton(
                context,
                label: 'Login as User',
                icon: Icons.person,
                color: Colors.blue,
                onTap: () => _loginAsUser(context),
              ),
              _buildQuickButton(
                context,
                label: 'Login as Admin',
                icon: Icons.admin_panel_settings,
                color: Colors.purple,
                onTap: () => _loginAsAdmin(context),
              ),
              _buildQuickButton(
                context,
                label: 'File Complaint',
                icon: Icons.add_circle,
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FileComplaintScreen(),
                    ),
                  );
                },
              ),
              _buildQuickButton(
                context,
                label: 'Create Notification',
                icon: Icons.notifications,
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateNotificationScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data Management
          const Text(
            'Data Management',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _clearAllData(context),
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  label: const Text('Clear All Data'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _resetToDefaults(context),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reset Defaults'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Settings
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Persist Data'),
            subtitle: const Text('Save data between app restarts'),
            value: MockConfig.persistData,
            onChanged: (value) {
              MockConfig.persistData = value;
            },
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Show Mock Banner'),
            subtitle: const Text('Display mock mode warning banner'),
            value: MockConfig.showMockBanner,
            onChanged: (value) {
              MockConfig.showMockBanner = value;
            },
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),

          // Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Mock Mode Active',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'All data is local and simulated. No real API calls are made.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loginAsUser(BuildContext context) async {
    final authProvider = context.read<MockAuthProvider>();
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
    final authProvider = context.read<MockAuthProvider>();
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
        content: const Text('This will delete all local data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await HiveService.clearAll();
      if (context.mounted) {
        final complaintProvider = context.read<MockComplaintProvider>();
        final notificationProvider = context.read<MockNotificationProvider>();
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
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      MockConfig.persistData = true;
      MockConfig.showMockBanner = true;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings reset to defaults'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Show developer tools
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: const DeveloperTools(),
      ),
    );
  }
}
