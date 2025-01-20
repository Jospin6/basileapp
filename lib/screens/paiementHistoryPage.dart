import 'package:basileapp/db/database_helper.dart';
import 'package:flutter/material.dart';

class PaiementHistoryPage extends StatefulWidget {
  final dynamic clientID;
  const PaiementHistoryPage({super.key, this.clientID});

  @override
  State<PaiementHistoryPage> createState() => _PaiementHistoryPageState();
}

class _PaiementHistoryPageState extends State<PaiementHistoryPage> {
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
          return const Center(child: Text('Aucun historique de paiement trouvé.'));  
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
            );  
          },  
        );  
      },  
    ),
    );
  }
}