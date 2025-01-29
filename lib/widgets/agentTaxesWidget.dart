import 'package:basileapp/db/database_helper.dart';
import 'package:flutter/material.dart'; // Assure-toi que le chemin est correct

class AgentTaxesWidget extends StatefulWidget {
  const AgentTaxesWidget({super.key});

  @override
  State<AgentTaxesWidget> createState() => _AgentTaxesWidgetState();
}

class _AgentTaxesWidgetState extends State<AgentTaxesWidget> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: dbHelper.getAllTaxes(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Erreur : ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucune taxe trouvée."));
        }

        final taxes = snapshot.data!;

        return ListView.builder(
          itemCount: taxes.length,
          itemBuilder: (context, index) {
            final tax = taxes[index];
            return ListTile(
              title: Text("Nom : ${tax['name']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Type : ${tax['type']}"),
                  Text("Montant : ${tax['amount']} \$"),
                ],
              ),
              isThreeLine: true,
              leading: const Icon(Icons.monetization_on, color: Colors.green,size: 40,),
            );
          },
        );
      },
    );
  }
}
