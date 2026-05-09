import '../models/complaint.dart';

abstract class ComplaintService {
  Future<List<Complaint>> getUserComplaints(String userId);
  Future<List<Complaint>> getAllComplaints();
  Future<Complaint> createComplaint({
    required String title,
    required String description,
    required String category,
    required String priority,
    required List<String> photoUrls,
    required Map<String, double> location,
    String? address,
  });
  Future<Complaint> getComplaintById(String id);
  Future<void> updateComplaintStatus(String id, String status);
  Future<void> addComment(String complaintId, Comment comment);
  Future<List<Complaint>> searchComplaints(String query);
  Future<Map<String, int>> getComplaintStats(String userId);
  Future<void> resetComplaints();
}
