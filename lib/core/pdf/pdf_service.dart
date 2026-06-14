
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateReport({
    required List<List<String>> rows,
    required String period,
    required double? avg,
    required double? high,
    required double? low,
    required int entries,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [

          pw.Header(
            level: 0,
            child: pw.Text(
              "Glucose Logger Report",
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Text("Period: $period"),

          pw.Text(
            "Average: ${avg?.toStringAsFixed(0) ?? '--'}",
          ),

          pw.Text(
            "Highest: ${high?.toStringAsFixed(0) ?? '--'}",
          ),

          pw.Text(
            "Lowest: ${low?.toStringAsFixed(0) ?? '--'}",
          ),

          pw.Text(
            "Entries: $entries",
          ),

          pw.SizedBox(height: 20),

          pw.TableHelper.fromTextArray(
            headers: const [
              "Date",
              "BB",
              "AB",
              "BL",
              "AL",
              "BD",
              "AD",
              "L",
            ],
            data: rows,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async =>
          pdf.save(),
    );
  }
}