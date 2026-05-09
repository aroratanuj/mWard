import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import '../models/complaint.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'complaint_service.dart';

class AmplifyComplaintService implements ComplaintService {
  @override
  Future<List<Complaint>> getAllComplaints() async {
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

    return (data['listComplaints']['items'] as List)
        .map((item) => Complaint.fromJson(item))
        .toList();
  }

  @override
  Future<List<Complaint>> getUserComplaints(String userId) async {
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

    return (data['queryComplaintsByUserId']['items'] as List)
        .map((item) => Complaint.fromJson(item))
        .toList();
  }

  @override
  Future<Complaint> createComplaint({
    required String title,
    required String description,
    required String category,
    required String priority,
    required List<String> photoUrls,
    required Map<String, double> location,
    String? address,
  }) async {
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
            'latitude': location['latitude'],
            'longitude': location['longitude'],
            'accuracy': location['accuracy'],
          },
          'address': address,
        },
      },
    );

    final response = await Amplify.API.mutate(request: request).response;
    final data = jsonDecode(response.data);

    return Complaint.fromJson(data['createComplaint']);
  }

  @override
  Future<Complaint> getComplaintById(String id) async {
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
      variables: {'complaintId': id},
    );

    final response = await Amplify.API.query(request: request).response;
    final data = jsonDecode(response.data);

    if (data['getComplaint'] != null) {
      return Complaint.fromJson(data['getComplaint']);
    }
    throw Exception('Complaint not found');
  }

  @override
  Future<void> updateComplaintStatus(String id, String status) async {
    final request = GraphQLRequest(
      document: '''
        mutation UpdateComplaintStatus(
          \$complaintId: ID!
          \$status: String!
        ) {
          updateComplaintStatus(
            input: {
              complaintId: \$complaintId
              status: \$status
            }
          ) {
            complaintId
            status
            resolvedAt
            updatedAt
          }
        }
      ''',
      variables: {
        'complaintId': id,
        'status': status,
      },
    );

    await Amplify.API.mutate(request: request).response;
  }

  @override
  Future<void> addComment(String complaintId, Comment comment) async {
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
        'text': comment.text,
        'userId': comment.userId,
        'userName': comment.userName,
      },
    );

    await Amplify.API.mutate(request: request).response;
  }

  @override
  Future<List<Complaint>> searchComplaints(String query) async {
    // TODO: Implement search with GraphQL
    // For now, load all complaints and filter client-side
    final allComplaints = await getAllComplaints();
    return allComplaints.where((c) =>
        c.title.toLowerCase().contains(query.toLowerCase()) ||
        c.description.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Future<Map<String, int>> getComplaintStats(String userId) async {
    final complaints = await getUserComplaints(userId);
    return {
      'total': complaints.length,
      'pending': complaints.where((c) => c.status == 'pending').length,
      'in_progress': complaints.where((c) => c.status == 'in-progress').length,
      'resolved': complaints.where((c) => c.status == 'resolved').length,
      'rejected': complaints.where((c) => c.status == 'rejected').length,
    };
  }

  @override
  Future<void> resetComplaints() async {
    // No-op for real service - complaints are in the backend
  }
}
