import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTaxesWidget extends StatefulWidget {
  const AdminTaxesWidget({super.key});

  @override
  State<AdminTaxesWidget> createState() => _AdminTaxesWidgetState();
}

class _AdminTaxesWidgetState extends State<AdminTaxesWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('taxes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Erreur : ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Aucune taxe trouvée."));
        }

        final taxes = snapshot.data!.docs;

        return ListView.builder(
          itemCount: taxes.length,
          itemBuilder: (context, index) {
            final tax = taxes[index].data() as Map<String, dynamic>;

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
              leading: const Icon(Icons.monetization_on, color: Colors.green, size: 40,),
            );
          },
        );
      },
    );
  }
}
