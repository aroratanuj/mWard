import 'package:flutter/material.dart';
import '../../models/complaint.dart';
import '../../utils/helpers.dart';
import '../../config/theme_config.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  final String complaintId;

  const ComplaintDetailsScreen({
    super.key,
    required this.complaintId,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Load complaint details from provider
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
      ),
      body: const Center(
        child: Text('Complaint details will be loaded here'),
      ),
    );
  }
}
