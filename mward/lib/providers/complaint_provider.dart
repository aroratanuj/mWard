import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import '../models/complaint.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ComplaintProvider with ChangeNotifier {
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
      final request = GraphQLRequest(
        document: '''
          query GetAllComplaints {
            listComplaints {
              items {
                complaintId
                userId
                wardCode
                title
                description
                category
                priority
                status
                photoUrls
                location {
                  latitude
                  longitude
                  accuracy
                }
                address
                createdAt
                updatedAt
                resolvedAt
                assignedTo
                resolutionNote
                comments {
                  commentId
                  userId
                  userName
                  text
                  createdAt
                }
              }
              nextToken
            }
          }
        ''',
      );

      final response = await Amplify.API.query(request: request).response;
      final data = jsonDecode(response.data);

      _complaints = (data['listComplaints']['items'] as List)
          .map((item) => Complaint.fromJson(item))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load user complaints
  Future<void> loadUserComplaints(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = GraphQLRequest(
        document: '''
          query GetUserComplaints(\$userId: ID!) {
            queryComplaintsByUserId(
              userId: \$userId
              sortDirection: DESC
            ) {
              items {
                complaintId
                userId
                wardCode
                title
                description
                category
                priority
                status
                photoUrls
                location {
                  latitude
                  longitude
                  accuracy
                }
                address
                createdAt
                updatedAt
                resolvedAt
                assignedTo
                resolutionNote
                comments {
                  commentId
                  userId
                  userName
                  text
                  createdAt
                }
              }
              nextToken
            }
          }
        ''',
        variables: {'userId': userId},
      );

      final response = await Amplify.API.query(request: request).response;
      final data = jsonDecode(response.data);

      _userComplaints = (data['queryComplaintsByUserId']['items'] as List)
          .map((item) => Complaint.fromJson(item))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get complaint by ID
  Future<Complaint?> getComplaintById(String complaintId) async {
    try {
      final request = GraphQLRequest(
        document: '''
          query GetComplaint(\$complaintId: ID!) {
            getComplaint(id: \$complaintId) {
              complaintId
              userId
              wardCode
              title
              description
              category
              priority
              status
              photoUrls
              location {
                latitude
                longitude
                accuracy
              }
              address
              createdAt
              updatedAt
              resolvedAt
              assignedTo
              resolutionNote
              comments {
                commentId
                userId
                userName
                text
                createdAt
              }
            }
          }
        ''',
        variables: {'complaintId': complaintId},
      );

      final response = await Amplify.API.query(request: request).response;
      final data = jsonDecode(response.data);

      if (data['getComplaint'] != null) {
        return Complaint.fromJson(data['getComplaint']);
      }
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
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
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final complaintId = AppHelpers.generateComplaintId();

      final request = GraphQLRequest(
        document: '''
          mutation CreateComplaint(\$input: CreateComplaintInput!) {
            createComplaint(input: \$input) {
              complaintId
              userId
              wardCode
              title
              description
              category
              priority
              status
              photoUrls
              location {
                latitude
                longitude
                accuracy
              }
              address
              createdAt
              updatedAt
              resolvedAt
              assignedTo
              resolutionNote
              comments {
                commentId
                userId
                userName
                text
                createdAt
              }
            }
          }
        ''',
        variables: {
          'input': {
            'complaintId': complaintId,
            'title': title,
            'description': description,
            'category': category,
            'priority': priority,
            'status': 'pending',
            'photoUrls': photoUrls,
            'location': {
              'latitude': location.latitude,
              'longitude': location.longitude,
              'accuracy': location.accuracy,
            },
            'address': address,
          },
        },
      );

      final response = await Amplify.API.mutate(request: request).response;
      final data = jsonDecode(response.data);

      final newComplaint = Complaint.fromJson(data['createComplaint']);
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

  // Update complaint status (admin)
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

      final request = GraphQLRequest(
        document: '''
          mutation UpdateComplaintStatus(
            \$complaintId: ID!
            \$status: String!
            \$resolutionNote: String
            \$assignedTo: String
          ) {
            updateComplaintStatus(
              input: {
                complaintId: \$complaintId
                status: \$status
                resolutionNote: \$resolutionNote
                assignedTo: \$assignedTo
              }
            ) {
              complaintId
              status
              resolutionNote
              assignedTo
              resolvedAt
              updatedAt
            }
          }
        ''',
        variables: {
          'complaintId': complaintId,
          'status': status,
          'resolutionNote': resolutionNote,
          'assignedTo': assignedTo,
        },
      );

      await Amplify.API.mutate(request: request).response;

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

  // Add comment to complaint
  Future<void> addComment(
    String complaintId,
    String text,
    String userId,
    String userName,
  ) async {
    try {
      final request = GraphQLRequest(
        document: '''
          mutation AddComment(
            \$complaintId: ID!
            \$text: String!
            \$userId: ID!
            \$userName: String!
          ) {
            addComment(
              input: {
                complaintId: \$complaintId
                text: \$text
                userId: \$userId
                userName: \$userName
              }
            ) {
              commentId
              complaintId
              userId
              userName
              text
              createdAt
            }
          }
        ''',
        variables: {
          'complaintId': complaintId,
          'text': text,
          'userId': userId,
          'userName': userName,
        },
      );

      await Amplify.API.mutate(request: request).response;

      // Reload complaints to get updated comments
      await loadUserComplaints(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete complaint (admin only)
  Future<void> deleteComplaint(String complaintId) async {
    try {
      final request = GraphQLRequest(
        document: '''
          mutation DeleteComplaint(\$complaintId: ID!) {
            deleteComplaint(input: { id: \$complaintId }) {
              id
            }
          }
        ''',
        variables: {'complaintId': complaintId},
      );

      await Amplify.API.mutate(request: request).response;

      _complaints.removeWhere((c) => c.complaintId == complaintId);
      _userComplaints.removeWhere((c) => c.complaintId == complaintId);

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
