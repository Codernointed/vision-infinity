import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:vision_infinity_eye_health_flutter/services/pdf_generation_service.dart';

void main() {
  group('PdfGenerationService', () {
    final pdfService = PdfGenerationService();

    test('generateReport creates a PDF file', () async {
      final file = await pdfService.generateReport(
        'Healthy',
        0.95,
        ['Regular check-up in 6 months'],
      );

      expect(file, isA<File>());
      expect(await file.exists(), isTrue);
    });
  });
} 