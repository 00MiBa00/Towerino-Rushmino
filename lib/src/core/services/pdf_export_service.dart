import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/entities/task.dart';

class PdfExportService {
  static Future<void> exportTasks(List<Task> tasks) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Towerino Rushmino - Tasks Export',
                  style: pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 16),
              ...tasks.map(
                (task) => pw.Text(
                  '${task.title} • ${task.category.name} • ${task.priority.name}',
                ),
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }
}
