import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerationService {
  Future<File> generateAdvancedReport(
    Map<String, dynamic> scanData,
    bool isAdvancedMode,
  ) async {
    final pdf = pw.Document();

    final String imagePath = scanData['image_path'] as String;
    final image = pw.MemoryImage(
      File(imagePath).readAsBytesSync(),
    );

    final ttf = pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Regular.ttf'));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: ttf),
        header: (context) => _buildHeader(context, scanData),
        footer: _buildFooter,
        build: (context) => [
          _buildPatientInfo(context, scanData),
          pw.SizedBox(height: 20),
          pw.Image(image, height: 200, fit: pw.BoxFit.contain),
          pw.SizedBox(height: 20),
          _buildAnalysisSection(context, scanData, isAdvancedMode),
          pw.SizedBox(height: 20),
          _buildRecommendationsSection(context, scanData),
          pw.SizedBox(height: 20),
          if (isAdvancedMode) _buildMetricsSection(context, scanData),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/VisionInfinity_Report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildHeader(pw.Context context, Map<String, dynamic> scanData) {
    final DateTime timestamp = DateTime.tryParse(scanData['timestamp'] ?? '') ?? DateTime.now();
    final String date = '${timestamp.day}/${timestamp.month}/${timestamp.year}';

    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Vision Infinity - Eye Health Report', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('Date of Scan: $date'),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Column(
        children: [
          pw.Divider(thickness: 1),
          pw.Text(
            'This report is generated based on an AI analysis and is not a substitute for a professional medical diagnosis. Please consult a qualified eye care professional.',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPatientInfo(pw.Context context, Map<String, dynamic> scanData) {
    // In a real app, this would come from user data
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Patient Information'),
        pw.Text('Patient ID: 12345'),
        pw.Text('Patient Name: John Doe'),
      ],
    );
  }

  pw.Widget _buildAnalysisSection(pw.Context context, Map<String, dynamic> scanData, bool isAdvancedMode) {
    final String description = isAdvancedMode ? scanData['advanced_analysis'] : scanData['basic_analysis'];
    final List<String> symptoms = List<String>.from(scanData['symptoms'] ?? []);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Eye Health Analysis'),
        pw.Text(description),
        if (symptoms.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Text('Observed Symptoms:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...symptoms.map((s) => pw.Bullet(text: s)),
        ],
      ],
    );
  }

  pw.Widget _buildRecommendationsSection(pw.Context context, Map<String, dynamic> scanData) {
    final List<String> recommendations = List<String>.from(scanData['recommendations'] ?? []);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Recommendations'),
        ...recommendations.map((r) => pw.Bullet(text: r)),
      ],
    );
  }

  pw.Widget _buildMetricsSection(pw.Context context, Map<String, dynamic> scanData) {
    final Map<String, dynamic> metrics = scanData['metrics'] as Map<String, dynamic>;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Clinical Metrics'),
        pw.GridView(
          crossAxisCount: 2,
          childAspectRatio: 4,
          children: [
            _buildMetricItem('Pressure', '${(metrics['pressure'] as num).toStringAsFixed(1)}%'),
            _buildMetricItem('Redness', '${(metrics['redness'] as num).toStringAsFixed(1)}%'),
            _buildMetricItem('Dryness', '${(metrics['dryness'] as num).toStringAsFixed(1)}%'),
          ],
        ),
        // Add more advanced metrics here from the scanData if available
      ],
    );
  }

  pw.Widget _buildSectionHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
        pw.SizedBox(height: 5),
      ],
    );
  }

  pw.Widget _buildMetricItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey)),
        pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
