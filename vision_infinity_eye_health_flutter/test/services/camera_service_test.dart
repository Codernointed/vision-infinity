import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vision_infinity_eye_health_flutter/services/camera_service.dart';

void main() {
  group('CameraService', () {
    final cameraService = CameraService();

    test('captureImage returns null when no image is captured', () async {
      final result = await cameraService.captureImage();
      expect(result, isNull);
    });

    test('analyzeImage returns dummy analysis data', () async {
      final dummyImage = XFile('path/to/dummy/image.jpg');
      final result = await cameraService.analyzeImage(dummyImage);

      expect(result['diagnosis'], 'Healthy');
      expect(result['confidence'], 0.95);
      expect(result['recommendations'], ['Regular check-up in 6 months']);
    });
  });
}
