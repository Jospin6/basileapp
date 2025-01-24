import 'package:basileapp/screens/newAgentPage.dart';
import 'package:basileapp/screens/singleAgentPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgentsPage extends StatefulWidget {
  const AgentsPage({super.key});

  @override
  State<AgentsPage> createState() => _AgentsPageState();
}

class _AgentsPageState extends State<AgentsPage> {
  late Future<List<Map<String, dynamic>>> _agentsFuture;

  @override
  void initState() {
    super.initState();
    _agentsFuture = fetchAgents();
  }

  // Fonction pour récupérer les utilisateurs
  Future<List<Map<String, dynamic>>> fetchAgents() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // Mappe les documents Firestore en une liste de maps
      List<Map<String, dynamic>> agents = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'surname': data['surname'] ?? '',
          'role': data['role'] ?? '',
        };
      }).toList();

      return agents;
    } catch (e) {
      print("Erreur lors de la récupération des utilisateurs : $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des agents"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewAgentPage(),
                  ),
                );
              }, 
              icon: const Icon(Icons.add_circle_outline))
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _agentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun agent trouvé."));
          }

          // Liste des agents récupérés
          List<Map<String, dynamic>> agents = snapshot.data!;

          return ListView.builder(
            itemCount: agents.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> agent = agents[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(agent['name'].substring(0, 1).toUpperCase()),
                  ),
                  title: Text("${agent['name']} ${agent['surname']}"),
                  subtitle: Text("Rôle : ${agent['role']}"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SingleAgentPage(
                          agentID: agent['id'],
                        ),
                      ),
                    );
                    print("Agent sélectionné : ${agent['id']}");
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
