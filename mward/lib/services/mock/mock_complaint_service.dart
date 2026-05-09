import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/complaint.dart';
import '../../mock_data/mock_complaints.dart';
import '../../config/mock_config.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../services/hive_service.dart';
import '../complaint_service.dart';

class MockComplaintService implements ComplaintService {
  // Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: MockConfig.mockApiDelay));
  }

  // Get all complaints (Admin)
  Future<List<Complaint>> getAllComplaints() async {
    await _simulateDelay();
    
    // Try to get from Hive first (persisted data)
    if (MockConfig.persistData) {
      final hiveComplaints = HiveService.getAllComplaints();
      if (hiveComplaints.isNotEmpty) {
        return hiveComplaints.map((c) => Complaint.fromJson(c)).toList();
      }
    }
    
    // Return sample data
    return MockComplaints.getSampleComplaints();
  }

  // Get user complaints
  Future<List<Complaint>> getUserComplaints(String userId) async {
    await _simulateDelay();
    
    // Try to get from Hive first (persisted data)
    if (MockConfig.persistData) {
      final hiveComplaints = HiveService.getAllComplaints();
      final userComplaints = hiveComplaints
          .where((c) => c['userId'] == userId)
          .map((c) => Complaint.fromJson(c))
          .toList();
      
      if (userComplaints.isNotEmpty) {
        return userComplaints;
      }
    }
    
    // Return sample data
    return MockComplaints.getComplaintsByUserId(userId);
  }

  // Get complaint by ID
  Future<Complaint> getComplaintById(String complaintId) async {
    await _simulateDelay();

    // Try to get from Hive first
    if (MockConfig.persistData) {
      final hiveComplaint = HiveService.getComplaint(complaintId);
      if (hiveComplaint != null) {
        return Complaint.fromJson(hiveComplaint);
      }
    }

    // Return sample data
    final complaint = MockComplaints.getComplaintById(complaintId);
    if (complaint == null) {
      throw Exception('Complaint not found');
    }
    return complaint;
  }

  // Create complaint
  Future<Complaint> createComplaint({
    required String title,
    required String description,
    required String category,
    required String priority,
    required List<String> photoUrls,
    required Map<String, dynamic> location,
    String? address,
    String? userId,
    String? wardCode,
  }) async {
    await _simulateDelay();

    final complaintId = AppHelpers.generateComplaintId();
    final complaintUserId = userId ?? MockConfig.mockUserId;
    final complaintWardCode = wardCode ?? MockConfig.mockWardCode;

    final complaint = Complaint(
      complaintId: complaintId,
      userId: complaintUserId,
      wardCode: complaintWardCode,
      title: title,
      description: description,
      category: category,
      priority: priority,
      status: 'pending',
      photoUrls: photoUrls,
      location: LocationData(
        latitude: location['latitude'] ?? MockConfig.mockLatitude,
        longitude: location['longitude'] ?? MockConfig.mockLongitude,
        accuracy: location['accuracy'],
      ),
      address: address,
      createdAt: DateTime.now(),
      comments: [],
    );

    // Save to Hive if persistence is enabled
    if (MockConfig.persistData) {
      await HiveService.saveComplaint(complaint.toJson());
    }

    debugPrint('Mock: Complaint created: $complaintId');
    return complaint;
  }

  // Update complaint status (Admin)
  Future<Complaint> updateComplaintStatus(
    String complaintId,
    String status, {
    String? resolutionNote,
    String? assignedTo,
  }) async {
    await _simulateDelay();

    final complaint = await getComplaintById(complaintId);
    if (complaint == null) {
      throw Exception('Complaint not found');
    }

    final updatedComplaint = complaint.copyWith(
      status: status,
      resolutionNote: resolutionNote,
      assignedTo: assignedTo,
      resolvedAt: status == 'resolved' ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );

    // Update in Hive
    if (MockConfig.persistData) {
      await HiveService.updateComplaint(complaintId, updatedComplaint.toJson());
    }

    debugPrint('Mock: Complaint status updated: $complaintId -> $status');
    return updatedComplaint;
  }

  // Add comment to complaint
  Future<void> addComment(String complaintId, Comment comment) async {
    await _simulateDelay();

    final complaint = await getComplaintById(complaintId);

    final updatedComments = [...complaint.comments, comment];
    await HiveService.updateComplaint(complaintId, {'comments': updatedComments.map((c) => c.toJson()).toList()});

    debugPrint('Mock: Comment added to complaint: $complaintId');
  }

  // Delete complaint (Admin only)
  Future<void> deleteComplaint(String complaintId) async {
    await _simulateDelay();

    // Delete from Hive
    if (MockConfig.persistData) {
      await HiveService.deleteComplaint(complaintId);
    }

    debugPrint('Mock: Complaint deleted: $complaintId');
  }

  // Get complaints by status
  Future<List<Complaint>> getComplaintsByStatus(String status) async {
    await _simulateDelay();
    return MockComplaints.getComplaintsByStatus(status);
  }

  // Get complaints by ward
  Future<List<Complaint>> getComplaintsByWardCode(String wardCode) async {
    await _simulateDelay();
    return MockComplaints.getComplaintsByWardCode(wardCode);
  }

  // Search complaints
  Future<List<Complaint>> searchComplaints(String query) async {
    await _simulateDelay();

    final allComplaints = await getAllComplaints();
    final lowerQuery = query.toLowerCase();

    return allComplaints.where((complaint) {
      return complaint.title.toLowerCase().contains(lowerQuery) ||
          complaint.description.toLowerCase().contains(lowerQuery) ||
          complaint.category.toLowerCase().contains(lowerQuery) ||
          complaint.status.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get complaint statistics
  @override
  Future<Map<String, int>> getComplaintStats(String userId) async {
    await _simulateDelay();

    final userComplaints = await getUserComplaints(userId);

    return {
      'total': userComplaints.length,
      'pending': userComplaints.where((c) => c.status == 'pending').length,
      'in_progress': userComplaints.where((c) => c.status == 'in-progress').length,
      'resolved': userComplaints.where((c) => c.status == 'resolved').length,
      'rejected': userComplaints.where((c) => c.status == 'rejected').length,
    };
  }

  // Reset all complaints (for testing)
  Future<void> resetComplaints() async {
    if (MockConfig.persistData) {
      await HiveService.deleteComplaint('all'); // Clear all
    }
    debugPrint('Mock: All complaints reset');
  }
}
