import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/complaint_provider.dart';
import '../../../providers/auth_provider.dart' as local;
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../config/theme_config.dart';
import '../../complaint/complaint_details_screen.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  String _selectedFilter = 'all';
  final List<String> _filters = ['all', 'pending', 'in-progress', 'resolved', 'rejected'];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    final authProvider = context.read<local.AuthProvider>();
    final complaintProvider = context.read<ComplaintProvider>();

    if (authProvider.currentUser != null) {
      await complaintProvider.loadUserComplaints(
        authProvider.currentUser!.userId,
      );
    }
  }

  List<dynamic> _getFilteredComplaints() {
    final complaintProvider = context.read<ComplaintProvider>();
    final allComplaints = complaintProvider.userComplaints;

    if (_selectedFilter == 'all') {
      return allComplaints;
    }

    return allComplaints.where((c) => c.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintProvider>(
      builder: (context, complaintProvider, child) {
        final filteredComplaints = _getFilteredComplaints();

        return Column(
          children: [
            // Filter Chips
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    final label = filter == 'all'
                        ? 'All'
                        : AppHelpers.getStatusLabel(filter);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryColor,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Complaint List
            Expanded(
              child: complaintProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : filteredComplaints.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No complaints found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedFilter == 'all'
                                    ? 'You haven\'t filed any complaints yet'
                                    : 'No ${AppHelpers.getStatusLabel(_selectedFilter).toLowerCase()} complaints',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadComplaints,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredComplaints.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final complaint = filteredComplaints[index];
                              return _buildComplaintCard(complaint);
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildComplaintCard(dynamic complaint) {
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
                  const Spacer(),
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
