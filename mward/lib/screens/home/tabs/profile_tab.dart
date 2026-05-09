import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart' as real;
import '../../../providers/mock/mock_auth_provider.dart';
import '../../../providers/complaint_provider.dart' as real_complaint;
import '../../../providers/mock/mock_complaint_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../config/theme_config.dart';
import '../../../config/mock_config.dart';
import '../../../widgets/developer_tools.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    if (MockConfig.isMockMode) {
      return Consumer<MockAuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return _ProfileContent(user: user);
        },
      );
    } else {
      return Consumer<real.AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return _ProfileContent(user: user);
        },
      );
    }
  }
}

class _ProfileContent extends StatelessWidget {
  final dynamic user;

  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: user.photoUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  user.photoUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      AppHelpers.getInitials(user.name ?? 'User'),
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                AppHelpers.getInitials(user.name ?? 'User'),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      Text(
                        user.name ?? 'User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Phone
                      Text(
                        AppHelpers.formatPhoneNumber(user.phoneNumber),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: user.isAdmin
                              ? Colors.purple.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                              size: 16,
                              color: user.isAdmin ? Colors.purple : Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.isAdmin ? 'Admin' : 'User',
                              style: TextStyle(
                                fontSize: 12,
                                color: user.isAdmin ? Colors.purple : Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Edit Profile Button
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to edit profile
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit Profile'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Statistics
              if (MockConfig.isMockMode)
                Consumer<MockComplaintProvider>(
                  builder: (context, complaintProvider, child) {
                    final userComplaints = complaintProvider.userComplaints;
                    final total = userComplaints.length;
                    final pending = userComplaints
                        .where((c) => c.status == 'pending')
                        .length;
                    final resolved = userComplaints
                        .where((c) => c.status == 'resolved')
                        .length;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My Statistics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatItem(
                                    'Total',
                                    total.toString(),
                                    Icons.assignment,
                                    Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildStatItem(
                                    'Pending',
                                    pending.toString(),
                                    Icons.pending,
                                    Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildStatItem(
                                    'Resolved',
                                    resolved.toString(),
                                    Icons.check_circle,
                                    Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              else
                Consumer<real_complaint.ComplaintProvider>(
                  builder: (context, complaintProvider, child) {
                    final userComplaints = complaintProvider.userComplaints;
                    final total = userComplaints.length;
                    final pending = userComplaints
                        .where((c) => c.status == 'pending')
                        .length;
                    final resolved = userComplaints
                        .where((c) => c.status == 'resolved')
                        .length;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Statistics',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  'Total',
                                  total.toString(),
                                  Icons.assignment,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildStatItem(
                                  'Pending',
                                  pending.toString(),
                                  Icons.pending,
                                  Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildStatItem(
                                  'Resolved',
                                  resolved.toString(),
                                  Icons.check_circle,
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Menu Items
              Card(
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        // TODO: Navigate to settings
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        // TODO: Navigate to help
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: 'About App',
                      onTap: () {
                        _showAboutDialog(context);
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        // TODO: Navigate to privacy policy
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () {
                        // TODO: Navigate to terms of service
                      },
                    ),
                    // Developer Tools (only in mock mode)
                    if (MockConfig.isMockMode)
                      _buildMenuItem(
                        icon: Icons.developer_mode,
                        title: 'Developer Tools',
                        color: Colors.purple,
                        onTap: () {
                          DeveloperTools.show(context);
                        },
                      ),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      color: AppTheme.errorColor,
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              // App Version
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Version ${AppConstants.appVersion}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? AppTheme.textColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: color ?? AppTheme.textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(Icons.location_city, size: 48),
      children: [
        const Text(AppConstants.appDescription),
        const SizedBox(height: 16),
        const Text('Built for Himachal Pradesh communities'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (MockConfig.isMockMode) {
                await context.read<MockAuthProvider>().logout();
              } else {
                await context.read<real.AuthProvider>().logout();
              }
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
