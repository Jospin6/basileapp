import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/formatDate.dart';
import 'package:basileapp/outils/pdfPrinter.dart';
import 'package:basileapp/outils/sharedData.dart';
import 'package:flutter/material.dart';

class PaiementHistoryPage extends StatefulWidget {
  final int clientID;
  const PaiementHistoryPage({super.key, required this.clientID});

  @override
  State<PaiementHistoryPage> createState() => _PaiementHistoryPageState();
}

class _PaiementHistoryPageState extends State<PaiementHistoryPage> {
  final pdfPrinter = PdfPrinter();
  Formatdate formatDate = Formatdate();
  String? agentName;
  String? agentSurname;
  String? agentZone;
  late SharedData sharedData;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    sharedData = SharedData();
    setState(() {
      agentName = sharedData.getAgentName().toString();
      agentSurname = sharedData.getAgentSurname().toString();
      agentZone = sharedData.getAgentZone().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    DatabaseHelper dbHelper = DatabaseHelper();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
        backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
        title: const Text("Historique de paiements", style: TextStyle(color: Colors.white),),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getPaymentHistoryByClient(widget.clientID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Aucun historique de paiement trouvé.'));
          }

          final paymentHistory = snapshot.data!;

          return ListView.builder(
            itemCount: paymentHistory.length,
            itemBuilder: (context, index) {
              final payment = paymentHistory[index];
              return ListTile(
                title: Text('Montant: ${payment['amount_recu']} fc'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Client: ${payment['client_name']}'),
                    Text('Taxe: ${payment['tax_amount']}'),
                    Text('Agent: $agentName'),
                    Text('Date: ${formatDate.formatCreatedAt(payment['created_at'])}'),
                  ],
                ),
                isThreeLine: true,
                trailing: IconButton(
                    onPressed: () async {
                      // Récupérer les données du client et taxe
                      List<Map<String, dynamic>> clientData =
                          await dbHelper.getClient(widget.clientID);
                      List<Map<String, dynamic>> taxeData =
                          await dbHelper.getTax(payment['id_taxe']);
                      if (clientData.isEmpty || taxeData.isEmpty) {
                        print(
                            "Erreur : aucun client ou taxe trouvé avec cet ID.");
                        return;
                      }
                      final client = clientData.first;
                      final taxe = taxeData.first;

                      // Impression reçu
                      try {
                        await pdfPrinter.printReceipt(
                          taxData: {
                            "created_at": DateTime.now().toIso8601String(),
                            "client_name": client['name'].toString(),
                            "type_taxe": taxe['type'].toString(),
                            "taxe_name": taxe['name'].toString(),
                            "amount_recu": payment['amount_recu'].toString(),
                          },
                          agentName: agentName!,
                          agentSurname: agentSurname!,
                          agentZone: agentZone!,
                        );
                      } catch (e) {
                        print("Erreur lors de l'envoi du SMS : $e");
                      }
                    },
                    icon: const Icon(Icons.print)),
              );
            },
          );
        },
      ),
    );
  }
}
