import '../models/complaint.dart';
import '../utils/constants.dart';
import '../config/mock_config.dart';

class MockComplaints {
  static List<Complaint> getSampleComplaints() {
    return [
      Complaint(
        complaintId: 'CMP-001',
        userId: 'user-001',
        wardCode: 'WARD-001',
        title: 'Water Supply Issue in Sector 4',
        description: 'No water supply for the past 3 days in Sector 4. This is affecting daily life and hygiene.',
        category: 'Water Supply',
        priority: 'high',
        status: 'pending',
        photoUrls: [
          'https://via.placeholder.com/400x300/2196F3/FFFFFF?text=Water+Issue+1',
          'https://via.placeholder.com/400x300/2196F3/FFFFFF?text=Water+Issue+2',
        ],
        videoUrls: [],
        audioUrl: null,
        location: LocationData(
          latitude: 31.1048,
          longitude: 77.1734,
          accuracy: 10.0,
        ),
        address: 'Sector 4, Sanjauli, Shimla',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        comments: [
          Comment(
            commentId: 'cmt-001',
            userId: MockConfig.mockAdminId,
            userName: 'Ramesh Kumar',
            text: 'We are looking into this issue. Will resolve it soon.',
            createdAt: DateTime.now().subtract(Duration(hours: 1)),
          ),
        ],
      ),
      Complaint(
        complaintId: 'CMP-002',
        userId: 'user-001',
        wardCode: 'WARD-001',
        title: 'Road Damage on Mall Road',
        description: 'Large pothole on Mall Road near the bus stand. Dangerous for vehicles.',
        category: 'Roads',
        priority: 'medium',
        status: 'in-progress',
        photoUrls: [
          'https://via.placeholder.com/400x300/FF5722/FFFFFF?text=Pothole+Road',
        ],
        videoUrls: [],
        audioUrl: null,
        location: LocationData(
          latitude: 31.1058,
          longitude: 77.1744,
          accuracy: 10.0,
        ),
        address: 'Mall Road, Shimla',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        updatedAt: DateTime.now().subtract(Duration(hours: 6)),
        assignedTo: 'Municipal Corporation',
        comments: [
          Comment(
            commentId: 'cmt-002',
            userId: MockConfig.mockAdminId,
            userName: 'Ramesh Kumar',
            text: 'Work order issued. Repair will start tomorrow.',
            createdAt: DateTime.now().subtract(Duration(hours: 6)),
          ),
        ],
      ),
      Complaint(
        complaintId: 'CMP-003',
        userId: 'user-002',
        wardCode: 'WARD-002',
        title: 'Garbage Collection Issue',
        description: 'Garbage not collected from our street for a week. Bad smell and health hazard.',
        category: 'Garbage Collection',
        priority: 'high',
        status: 'resolved',
        photoUrls: [
          'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Garbage',
        ],
        videoUrls: [],
        audioUrl: 'https://mock-storage.mward.app/audios/garbage-complaint.mp3',
        location: LocationData(
          latitude: 31.1038,
          longitude: 77.1724,
          accuracy: 10.0,
        ),
        address: 'Summer Hill, Shimla',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        updatedAt: DateTime.now().subtract(Duration(hours: 12)),
        resolvedAt: DateTime.now().subtract(const Duration(hours: 12)),
        assignedTo: 'Sanitation Department',
        resolutionNote: 'Garbage collected. Regular service restored.',
      ),
      Complaint(
        complaintId: 'CMP-004',
        userId: 'user-001',
        wardCode: 'WARD-001',
        title: 'Street Light Not Working',
        description: 'Street light pole number 45 not working for a week. Dark street at night.',
        category: 'Street Lights',
        priority: 'medium',
        status: 'pending',
        photoUrls: [
          'https://via.placeholder.com/400x300/FFC107/000000?text=Street+Light',
        ],
        videoUrls: [
          'https://mock-storage.mward.app/videos/street-light-issue.mp4',
        ],
        audioUrl: null,
        location: LocationData(
          latitude: 31.1068,
          longitude: 77.1754,
          accuracy: 10.0,
        ),
        address: 'Sanjauli Bazar, Shimla',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      Complaint(
        complaintId: 'CMP-005',
        userId: 'user-003',
        wardCode: 'WARD-003',
        title: 'Drainage Blockage',
        description: 'Drain blocked causing water logging. Mosquito breeding and foul smell.',
        category: 'Drainage',
        priority: 'high',
        status: 'in-progress',
        photoUrls: [
          'https://via.placeholder.com/400x300/9C27B0/FFFFFF?text=Drainage',
        ],
        videoUrls: [],
        audioUrl: null,
        location: LocationData(
          latitude: 31.1078,
          longitude: 77.1764,
          accuracy: 10.0,
        ),
        address: 'Chotta Shimla',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 24)),
        assignedTo: 'Municipal Corporation',
      ),
      Complaint(
        complaintId: 'CMP-006',
        userId: 'user-004',
        wardCode: 'WARD-001',
        title: 'Electricity Wire Hanging',
        description: 'Loose electric wire hanging low near school. Dangerous for children.',
        category: 'Electricity',
        priority: 'high',
        status: 'resolved',
        photoUrls: [
          'https://via.placeholder.com/400x300/F44336/FFFFFF?text=Electric+Wire',
        ],
        videoUrls: [],
        audioUrl: 'https://mock-storage.mward.app/audios/electric-wire.mp3',
        location: LocationData(
          latitude: 31.1088,
          longitude: 77.1774,
          accuracy: 10.0,
        ),
        address: 'Near Government School, Sanjauli',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        resolvedAt: DateTime.now().subtract(const Duration(days: 2)),
        assignedTo: 'Electricity Department',
        resolutionNote: 'Wire repaired and secured.',
      ),
      Complaint(
        complaintId: 'CMP-007',
        userId: 'user-005',
        wardCode: 'WARD-004',
        title: 'Park Needs Maintenance',
        description: 'Children park needs maintenance. Broken swings and overgrown grass.',
        category: 'Park & Recreation',
        priority: 'low',
        status: 'pending',
        photoUrls: [
          'https://via.placeholder.com/400x300/8BC34A/FFFFFF?text=Park',
        ],
        videoUrls: [
          'https://mock-storage.mward.app/videos/park-issue.mp4',
        ],
        audioUrl: null,
        location: LocationData(
          latitude: 31.1098,
          longitude: 77.1784,
          accuracy: 10.0,
        ),
        address: 'Boileauganj Park',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  static List<Complaint> getComplaintsByUserId(String userId) {
    return getSampleComplaints()
        .where((complaint) => complaint.userId == userId)
        .toList();
  }

  static Complaint? getComplaintById(String complaintId) {
    try {
      return getSampleComplaints()
          .firstWhere((complaint) => complaint.complaintId == complaintId);
    } catch (e) {
      return null;
    }
  }

  static List<Complaint> getComplaintsByStatus(String status) {
    return getSampleComplaints()
        .where((complaint) => complaint.status == status)
        .toList();
  }

  static List<Complaint> getComplaintsByWardCode(String wardCode) {
    return getSampleComplaints()
        .where((complaint) => complaint.wardCode == wardCode)
        .toList();
  }
}
