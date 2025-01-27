import 'package:basileapp/db/database_helper.dart';  
import 'package:basileapp/outils/pdfPrinter.dart';  
import 'package:basileapp/outils/sharedData.dart';  
import 'package:flutter/material.dart';  

class NewPaiementPage extends StatefulWidget {  
  final int clientID;  
  final String typeTaxe;  
  final String nameTaxe;  
  final int idTaxe;  
  final double montantTaxe;  

  const NewPaiementPage({  
    super.key,  
    required this.clientID,  
    required this.nameTaxe,  
    required this.typeTaxe,  
    required this.idTaxe,  
    required this.montantTaxe,  
  });  

  @override  
  State<NewPaiementPage> createState() => _NewPaiementPageState();  
}  

class _NewPaiementPageState extends State<NewPaiementPage> {  
  final _formKey = GlobalKey<FormState>();  
  final TextEditingController _amountController = TextEditingController();  
  final DatabaseHelper dbHelper = DatabaseHelper();  
  String? agentName;  
  String? agentSurname;  
  String? agentZone;  

  final PdfPrinter pdfPrinter = PdfPrinter();  

  String? agentID;  
  String? numTeleAdmin;  

  late SharedData sharedData;  

  @override  
  void initState() {  
    super.initState();  
    loadUserData();  
  }  

  @override  
  void dispose() {  
    _amountController.dispose();  
    super.dispose();  
  }  

  Future<void> loadUserData() async {  
    sharedData = SharedData();  

    setState(() {  
      agentID = sharedData.getAgentId().toString();  
      numTeleAdmin = sharedData.getNumTeleAdmin().toString();  
      agentName = sharedData.getAgentName().toString();  
      agentSurname = sharedData.getAgentSurname().toString();  
      agentZone = sharedData.getAgentZone().toString();  
    });  
  }  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(  
        backgroundColor: const Color.fromRGBO(173, 104, 0, 1),  
        title: const Text(  
          "Paiement taxe",  
          style: TextStyle(color: Colors.white),  
        ),  
      ),  
      body: Padding(  
        padding: const EdgeInsets.all(16.0),  
        child: Column(  
          children: [  
            Form(  
              key: _formKey,  
              child: Column(  
                children: [  
                  // Champ pour le montant  
                  TextFormField(  
                    controller: _amountController,  
                    decoration: const InputDecoration(  
                      labelText: "Montant",  
                      border: OutlineInputBorder(),  
                    ),  
                    keyboardType: TextInputType.number,  
                    validator: (value) {  
                      if (value == null || value.isEmpty) {  
                        return "Veuillez entrer un montant";  
                      }  
                      if (double.tryParse(value) == null) {  
                        return "Veuillez entrer un montant valide";  
                      }  
                      return null;  
                    },  
                  ),  
                ],  
              ),  
            ),  
            const SizedBox(height: 20), // Espacement  
            ElevatedButton(  
              onPressed: () async {  
                if (_formKey.currentState!.validate()) {  
                  // Traitement des données  
                  final amountReceived = double.parse(_amountController.text);  
                  final taxData = {  
                    "id_client": widget.clientID,  
                    "id_taxe": widget.idTaxe,  
                    "id_agent": agentID,  
                    "amount_tot": widget.montantTaxe,  
                    "amount_recu": amountReceived,  
                    "zone": agentZone,  
                    "created_at": DateTime.now().toIso8601String(),  
                  };  
                  final taxHistData = {  
                    "id_client": widget.clientID,  
                    "id_taxe": widget.idTaxe,  
                    "id_agent": agentID,  
                    "amount_recu": amountReceived,  
                    "zone": agentZone,  
                    "created_at": DateTime.now().toIso8601String(),  
                  };  

                  print("Taxe ajoutée : $taxData");  

                  // Insérer les données dans la base de données  
                  await dbHelper.insertPayment(taxData);  
                  await dbHelper.insertPaymentHistory(taxHistData);  

                  // Récupérer les données du client et taxe  
                  List<Map<String, dynamic>> clientData =  
                      await dbHelper.getClient(widget.clientID);  
                  List<Map<String, dynamic>> taxeData =  
                      await dbHelper.getTax(widget.idTaxe);  
                  if (clientData.isEmpty || taxeData.isEmpty) {  
                    print("Erreur : aucun client ou taxe trouvé avec cet ID.");  
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
                        "amount_tot": widget.montantTaxe,  
                        "amount_recu": amountReceived,  
                      },  
                      agentName: agentName ?? "Inconnu",  
                      agentSurname: agentSurname ?? "Inconnu",  
                      agentZone: agentZone ?? "Inconnu",  
                    );  
                  } catch (e) {  
                    print("Erreur lors de l'impression : $e");  
                  }  

                  // Nettoyer les champs  
                  setState(() {  
                    _amountController.clear();  
                  });  

                  Navigator.pop(context); // Fermer le popup  
                }  
              },  
              style: ElevatedButton.styleFrom(  
                padding: const EdgeInsets.symmetric(  
                    horizontal: 40.0, vertical: 12.0),  
                shape: RoundedRectangleBorder(  
                  borderRadius: BorderRadius.circular(10.0),  
                ),  
                backgroundColor: const Color.fromRGBO(173, 104, 0, 1),  
              ),  
              child: const Text(  
                "Enregistrer",  
                style: TextStyle(color: Colors.white),  
              ),  
            ),  
          ],  
        ),  
      ),  
    );  
  }  
}




