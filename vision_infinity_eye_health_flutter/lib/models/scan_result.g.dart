// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScanResult _$ScanResultFromJson(Map<String, dynamic> json) => ScanResult(
  id: json['id'] as String,
  userId: json['userId'] as String,
  imageUrl: json['imageUrl'] as String,
  diagnosis: json['diagnosis'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  detectedConditions:
      (json['detectedConditions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$ScanResultToJson(ScanResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'imageUrl': instance.imageUrl,
      'diagnosis': instance.diagnosis,
      'confidence': instance.confidence,
      'createdAt': instance.createdAt.toIso8601String(),
      'detectedConditions': instance.detectedConditions,
      'metadata': instance.metadata,
    };
