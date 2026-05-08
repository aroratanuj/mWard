import '../models/ward.dart';

class MockWards {
  static List<Ward> getSampleWards() {
    return [
      Ward(
        wardCode: 'WARD-001',
        wardName: 'Sanjauli',
        wardNameHindi: 'संजौली',
        city: 'Shimla',
        cityHindi: 'शिमला',
        district: 'Shimla',
        districtHindi: 'शिमला',
        state: 'Himachal Pradesh',
        stateHindi: 'हिमाचल प्रदेश',
        councilorName: 'Ramesh Kumar',
        councilorPhone: '+919876543210',
        boundaries: BoundaryData(
          northLat: 31.1100,
          southLat: 31.1000,
          eastLng: 77.1800,
          westLng: 77.1700,
        ),
        population: 15000,
        totalComplaints: 45,
        resolvedComplaints: 32,
      ),
      Ward(
        wardCode: 'WARD-002',
        wardName: 'Summer Hill',
        wardNameHindi: 'समर हिल',
        city: 'Shimla',
        cityHindi: 'शिमला',
        district: 'Shimla',
        districtHindi: 'शिमला',
        state: 'Himachal Pradesh',
        stateHindi: 'हिमाचल प्रदेश',
        councilorName: 'Sunita Sharma',
        councilorPhone: '+919876543211',
        boundaries: BoundaryData(
          northLat: 31.1000,
          southLat: 31.0900,
          eastLng: 77.1700,
          westLng: 77.1600,
        ),
        population: 12000,
        totalComplaints: 38,
        resolvedComplaints: 28,
      ),
      Ward(
        wardCode: 'WARD-003',
        wardName: 'Chotta Shimla',
        wardNameHindi: 'छोटा शिमला',
        city: 'Shimla',
        cityHindi: 'शिमला',
        district: 'Shimla',
        districtHindi: 'शिमला',
        state: 'Himachal Pradesh',
        stateHindi: 'हिमाचल प्रदेश',
        councilorName: 'Vijay Thakur',
        councilorPhone: '+919876543212',
        boundaries: BoundaryData(
          northLat: 31.0900,
          southLat: 31.0800,
          eastLng: 77.1600,
          westLng: 77.1500,
        ),
        population: 10000,
        totalComplaints: 30,
        resolvedComplaints: 22,
      ),
      Ward(
        wardCode: 'WARD-004',
        wardName: 'Boileauganj',
        wardNameHindi: 'बॉयलगंज',
        city: 'Shimla',
        cityHindi: 'शिमला',
        district: 'Shimla',
        districtHindi: 'शिमला',
        state: 'Himachal Pradesh',
        stateHindi: 'हिमाचल प्रदेश',
        councilorName: 'Meena Devi',
        councilorPhone: '+919876543213',
        boundaries: BoundaryData(
          northLat: 31.0800,
          southLat: 31.0700,
          eastLng: 77.1500,
          westLng: 77.1400,
        ),
        population: 8000,
        totalComplaints: 25,
        resolvedComplaints: 18,
      ),
      Ward(
        wardCode: 'WARD-005',
        wardName: 'Lakkar Bazar',
        wardNameHindi: 'लक्कड़ बाज़ार',
        city: 'Shimla',
        cityHindi: 'शिमला',
        district: 'Shimla',
        districtHindi: 'शिमला',
        state: 'Himachal Pradesh',
        stateHindi: 'हिमाचल प्रदेश',
        councilorName: 'Rajender Singh',
        councilorPhone: '+919876543214',
        boundaries: BoundaryData(
          northLat: 31.0700,
          southLat: 31.0600,
          eastLng: 77.1400,
          westLng: 77.1300,
        ),
        population: 6000,
        totalComplaints: 20,
        resolvedComplaints: 15,
      ),
    ];
  }

  static Ward? getWardByCode(String wardCode) {
    try {
      return getSampleWards()
          .firstWhere((ward) => ward.wardCode == wardCode);
    } catch (e) {
      return null;
    }
  }

  static List<Ward> getWardsByCity(String city) {
    return getSampleWards()
        .where((ward) => ward.city.toLowerCase() == city.toLowerCase())
        .toList();
  }

  static Ward? getWardByCoordinates(double latitude, double longitude) {
    // Simple implementation - find ward that contains the coordinates
    for (final ward in getSampleWards()) {
      if (ward.boundaries != null) {
        final bounds = ward.boundaries!;
        if (latitude <= bounds.northLat! &&
            latitude >= bounds.southLat! &&
            longitude <= bounds.eastLng! &&
            longitude >= bounds.westLng!) {
          return ward;
        }
      }
    }
    // Return first ward if no match
    return getSampleWards().first;
  }
}
