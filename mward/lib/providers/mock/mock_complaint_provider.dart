import 'package:flutter/foundation.dart';
import '../../models/complaint.dart';
import '../../services/mock/mock_complaint_service.dart';
import '../../utils/constants.dart';
import 'package:geolocator/geolocator.dart';

class MockComplaintProvider with ChangeNotifier {
  final MockComplaintService _complaintService = MockComplaintService();

  List<Complaint> _complaints = [];
  List<Complaint> _userComplaints = [];
  bool _isLoading = false;
  String? _error;

  List<Complaint> get complaints => _complaints;
  List<Complaint> get userComplaints => _userComplaints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all complaints (admin)
  Future<void> loadAllComplaints() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _complaints = await _complaintService.getAllComplaints();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user complaints
  Future<void> loadUserComplaints(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userComplaints = await _complaintService.getUserComplaints(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get complaint by ID
  Future<Complaint?> getComplaintById(String complaintId) async {
    return await _complaintService.getComplaintById(complaintId);
  }

  // Create complaint
  Future<void> createComplaint({
    required String title,
    required String description,
    required String category,
    required String priority,
    required List<String> photoUrls,
    required Position location,
    String? address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newComplaint = await _complaintService.createComplaint(
        title: title,
        description: description,
        category: category,
        priority: priority,
        photoUrls: photoUrls,
        location: {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'accuracy': location.accuracy,
        },
        address: address,
      );

      _userComplaints.insert(0, newComplaint);
      _complaints.insert(0, newComplaint);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update complaint status (admin)
  Future<void> updateComplaintStatus(
    String complaintId,
    String status, {
    String? resolutionNote,
    String? assignedTo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedComplaint = await _complaintService.updateComplaintStatus(
        complaintId,
        status,
        resolutionNote: resolutionNote,
        assignedTo: assignedTo,
      );

      // Update in user complaints
      final userIndex = _userComplaints.indexWhere((c) => c.complaintId == complaintId);
      if (userIndex != -1) {
        _userComplaints[userIndex] = updatedComplaint;
      }

      // Update in all complaints
      final adminIndex = _complaints.indexWhere((c) => c.complaintId == complaintId);
      if (adminIndex != -1) {
        _complaints[adminIndex] = updatedComplaint;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Add comment to complaint
  Future<void> addComment(
    String complaintId,
    String text,
    String userId,
    String userName,
  ) async {
    try {
      await _complaintService.addComment(complaintId, text, userId, userName);

      // Reload complaints to get updated comments
      if (_userComplaints.any((c) => c.complaintId == complaintId)) {
        await loadUserComplaints(userId);
      }
      if (_complaints.any((c) => c.complaintId == complaintId)) {
        await loadAllComplaints();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete complaint (admin only)
  Future<void> deleteComplaint(String complaintId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _complaintService.deleteComplaint(complaintId);

      _complaints.removeWhere((c) => c.complaintId == complaintId);
      _userComplaints.removeWhere((c) => c.complaintId == complaintId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get complaints by status
  Future<List<Complaint>> getComplaintsByStatus(String status) async {
    return await _complaintService.getComplaintsByStatus(status);
  }

  // Get complaints by ward
  Future<List<Complaint>> getComplaintsByWardCode(String wardCode) async {
    return await _complaintService.getComplaintsByWardCode(wardCode);
  }

  // Search complaints
  Future<List<Complaint>> searchComplaints(String query) async {
    return await _complaintService.searchComplaints(query);
  }

  // Get complaint statistics
  Future<Map<String, int>> getComplaintStatistics() async {
    return await _complaintService.getComplaintStatistics();
  }

  // Reset all complaints (for testing)
  Future<void> resetComplaints() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _complaintService.resetComplaints();
      _complaints.clear();
      _userComplaints.clear();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get complaints count by status
  Map<String, int> getComplaintCountByStatus() {
    final counts = <String, int>{
      'pending': 0,
      'in-progress': 0,
      'resolved': 0,
      'rejected': 0,
    };

    for (final complaint in _userComplaints) {
      counts[complaint.status] = (counts[complaint.status] ?? 0) + 1;
    }

    return counts;
  }
}
