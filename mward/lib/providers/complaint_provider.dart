import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/complaint.dart';
import '../services/complaint_service.dart';

class ComplaintProvider with ChangeNotifier {
  final ComplaintService _service;
  
  List<Complaint> _complaints = [];
  List<Complaint> _userComplaints = [];
  bool _isLoading = false;
  String? _error;

  List<Complaint> get complaints => _complaints;
  List<Complaint> get userComplaints => _userComplaints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ComplaintProvider(this._service);

  Future<void> loadAllComplaints() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _complaints = await _service.getAllComplaints();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadUserComplaints(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userComplaints = await _service.getUserComplaints(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Complaint?> getComplaintById(String complaintId) async {
    try {
      return await _service.getComplaintById(complaintId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> createComplaint({
    required String title,
    required String description,
    required String category,
    required String priority,
    required List<String> photoUrls,
    required Position location,
    String? address,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newComplaint = await _service.createComplaint(
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

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateComplaintStatus(
    String complaintId,
    String status, {
    String? resolutionNote,
    String? assignedTo,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.updateComplaintStatus(complaintId, status);

      // Update local complaint
      final userIndex = _userComplaints.indexWhere((c) => c.complaintId == complaintId);
      if (userIndex != -1) {
        final updated = _userComplaints[userIndex].copyWith(
          status: status,
          resolutionNote: resolutionNote,
          assignedTo: assignedTo,
          resolvedAt: status == 'resolved' ? DateTime.now() : null,
          updatedAt: DateTime.now(),
        );
        _userComplaints[userIndex] = updated;
      }

      final adminIndex = _complaints.indexWhere((c) => c.complaintId == complaintId);
      if (adminIndex != -1) {
        final updated = _complaints[adminIndex].copyWith(
          status: status,
          resolutionNote: resolutionNote,
          assignedTo: assignedTo,
          resolvedAt: status == 'resolved' ? DateTime.now() : null,
          updatedAt: DateTime.now(),
        );
        _complaints[adminIndex] = updated;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addComment(
    String complaintId,
    String text,
    String userId,
    String userName,
  ) async {
    try {
      final comment = Comment(
        commentId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userName: userName,
        text: text,
        createdAt: DateTime.now(),
      );

      await _service.addComment(complaintId, comment);

      // Reload to get updated comments
      await loadUserComplaints(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Complaint>> searchComplaints(String query) async {
    try {
      return await _service.searchComplaints(query);
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  Future<Map<String, int>> getComplaintStats(String userId) async {
    try {
      return await _service.getComplaintStats(userId);
    } catch (e) {
      _error = e.toString();
      return {};
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> resetComplaints() async {
    await _service.resetComplaints();
    _complaints.clear();
    _userComplaints.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
