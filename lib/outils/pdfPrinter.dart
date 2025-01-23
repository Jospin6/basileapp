import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfPrinter {
  Future<void> printReceipt({
    required Map<String, dynamic> taxData,
    required String agentName,
    required String agentSurname,
    required String agentZone,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Reçu de paiement",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text("Date : ${taxData['created_at']}"),
            pw.Text("Client Nom : ${taxData['client_name']}"),
            pw.Text("Type taxe : ${taxData['type_taxe']}"),
            pw.Text("Taxe : ${taxData['taxe_name']}"),
            pw.Text("Agent : $agentName $agentSurname"),
            pw.Text("Zone : $agentZone"),
            pw.SizedBox(height: 10),
            pw.Text("Montant Total : ${taxData['amount_tot']}"),
            pw.Text("Montant Reçu : ${taxData['amount_recu']}"),
            pw.Text(
              "Montant Dû : ${(taxData['amount_tot'] - taxData['amount_recu']).toStringAsFixed(2)}",
            ),
          ],
        ),
      ),
    );

    // Envoyer le document pour impression
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
