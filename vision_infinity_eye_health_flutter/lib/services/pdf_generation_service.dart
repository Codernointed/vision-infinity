import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerationService {
  Future<File> generateReport(
    String diagnosis,
    double confidence,
    List<String> recommendations,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Diagnosis Report',
                    style: const pw.TextStyle(fontSize: 24),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text('Diagnosis: $diagnosis'),
                  pw.Text(
                    'Confidence: ${(confidence * 100).toStringAsFixed(2)}%',
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text('Recommendations:'),
                  ...recommendations.map((rec) => pw.Text('- $rec')),
                ],
              ),
            ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
