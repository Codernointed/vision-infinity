import 'package:json_annotation/json_annotation.dart';

part 'scan_result.g.dart';

@JsonSerializable()
class ScanResult {
  final String id;
  final String userId;
  final String imageUrl;
  final String diagnosis;
  final double confidence;
  final DateTime createdAt;
  final List<String> detectedConditions;
  final Map<String, dynamic> metadata;

  ScanResult({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.diagnosis,
    required this.confidence,
    required this.createdAt,
    required this.detectedConditions,
    required this.metadata,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) =>
      _$ScanResultFromJson(json);

  Map<String, dynamic> toJson() => _$ScanResultToJson(this);
}
