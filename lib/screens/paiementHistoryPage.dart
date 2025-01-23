import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/pdfPrinter.dart';
import 'package:basileapp/outils/sharedData.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaiementHistoryPage extends StatefulWidget {
  final dynamic clientID;
  const PaiementHistoryPage({super.key, this.clientID});

  @override
  State<PaiementHistoryPage> createState() => _PaiementHistoryPageState();
}

class _PaiementHistoryPageState extends State<PaiementHistoryPage> {
  final pdfPrinter = PdfPrinter();
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sharedData = SharedData(prefs: prefs);
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
      appBar: AppBar(),
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
                title: Text('Montant: ${payment['amount_recu']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Client: ${payment['client_name']}'),
                    Text('Taxe: ${payment['tax_amount']}'),
                    Text('Agent: ${payment['agent_name']}'),
                    Text('Date: ${payment['created_at']}'),
                  ],
                ),
                isThreeLine: true,
                trailing: IconButton(
                    onPressed: () async {
                      // Récupérer les données du client et taxe
                      List<Map<String, dynamic>> clientData =
                          await dbHelper.getClient(int.parse(widget.clientID));
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
