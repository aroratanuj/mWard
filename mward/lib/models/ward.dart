import 'package:json_annotation/json_annotation.dart';

part 'ward.g.dart';

@JsonSerializable()
class Ward {
  final String wardCode;
  final String wardName;
  final String? wardNameHindi;
  final String city;
  final String? cityHindi;
  final String district;
  final String? districtHindi;
  final String state;
  final String? stateHindi;
  final String? councilorName;
  final String? councilorPhone;
  final BoundaryData? boundaries;
  final int population;
  final int? totalComplaints;
  final int? resolvedComplaints;

  Ward({
    required this.wardCode,
    required this.wardName,
    this.wardNameHindi,
    required this.city,
    this.cityHindi,
    required this.district,
    this.districtHindi,
    required this.state,
    this.stateHindi,
    this.councilorName,
    this.councilorPhone,
    this.boundaries,
    required this.population,
    this.totalComplaints,
    this.resolvedComplaints,
  });

  factory Ward.fromJson(Map<String, dynamic> json) => _$WardFromJson(json);

  Map<String, dynamic> toJson() => _$WardToJson(this);

  double get resolutionRate {
    if (totalComplaints == null || totalComplaints == 0) return 0.0;
    return (resolvedComplaints! / totalComplaints!) * 100;
  }
}

@JsonSerializable()
class BoundaryData {
  final double? northLat;
  final double? southLat;
  final double? eastLng;
  final double? westLng;

  BoundaryData({
    this.northLat,
    this.southLat,
    this.eastLng,
    this.westLng,
  });

  factory BoundaryData.fromJson(Map<String, dynamic> json) => _$BoundaryDataFromJson(json);

  Map<String, dynamic> toJson() => _$BoundaryDataToJson(this);
}
