import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFGenerator {
  static Future<void> generateAndPrint(List<Map<String, dynamic>> expenses) async {
    final pdf = pw.Document();
    final total = expenses.fold(0.0, (sum, item) => sum + (item['valor'] as double));

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Relatório de Despesas', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Descrição', 'Valor (R\$)'],
              data: expenses
                  .map((e) => [e['descricao'], e['valor'].toStringAsFixed(2)])
                  .toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Total Gasto: R\$ ${total.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}