import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/complaint_provider.dart';
import '../../models/complaint.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../config/theme_config.dart';
import '../../complaint/complaint_details_screen.dart';

class ComplaintsTab extends StatefulWidget {
  const ComplaintsTab({super.key});

  @override
  State<ComplaintsTab> createState() => _ComplaintsTabState();
}

class _ComplaintsTabState extends State<ComplaintsTab> {
  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    final authProvider = context.read<AuthProvider>();
    final complaintProvider = context.read<ComplaintProvider>();

    if (authProvider.currentUser != null) {
      await complaintProvider.loadUserComplaints(
        authProvider.currentUser!.userId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintProvider>(
      builder: (context, complaintProvider, child) {
        final complaints = complaintProvider.userComplaints;

        if (complaintProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (complaints.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No complaints yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to file your first complaint',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadComplaints,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: complaints.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              return _buildComplaintCard(complaint);
            },
          ),
        );
      },
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ComplaintDetailsScreen(
                complaintId: complaint.complaintId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      complaint.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(complaint.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                complaint.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.category,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppHelpers.getCategoryLabel(complaint.category),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.priority_high,
                    size: 16,
                    color: AppHelpers.getPriorityColor(complaint.priority),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppHelpers.getPriorityLabel(complaint.priority),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppHelpers.getPriorityColor(complaint.priority),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppHelpers.formatRelativeTime(complaint.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  if (complaint.photoUrls.isNotEmpty) ...[
                    Icon(
                      Icons.photo_camera,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${complaint.photoUrls.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppHelpers.getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppHelpers.getStatusColor(status),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppHelpers.getStatusIcon(status),
            size: 12,
            color: AppHelpers.getStatusColor(status),
          ),
          const SizedBox(width: 4),
          Text(
            AppHelpers.getStatusLabel(status),
            style: TextStyle(
              fontSize: 11,
              color: AppHelpers.getStatusColor(status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
