import 'package:basileapp/screens/homePage.dart';
import 'package:flutter/material.dart';
import 'package:basileapp/screens/agentsPage.dart';
import 'package:basileapp/screens/clientPage.dart';
import 'package:basileapp/screens/settingsPage.dart';
import 'package:basileapp/screens/singleAgentPage.dart';

class DrawerWidget extends StatefulWidget {
  final String agentID;
  final String agentName;
  final String agentSurname;
  final String agentZone;
  final String agentRole;
  const DrawerWidget(
      {super.key,
      required this.agentID,
      required this.agentName,
      required this.agentSurname,
      required this.agentZone,
      required this.agentRole});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: const Color.fromRGBO(173, 104, 0, 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/basile.jpg'),
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.agentName} ${widget.agentSurname}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Role ${widget.agentRole}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () {
              Navigator.pop(context); // Ferme la Drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Homepage(),
                ),
              );
            },
          ),
          if (widget.agentRole != "Admin")
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Clients'),
              onTap: () {
                Navigator.pop(context); // Ferme la Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClientPage(),
                  ),
                );
              },
            ),
          if (widget.agentRole == "Admin")
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Agents'),
              onTap: () {
                Navigator.pop(context); // Ferme la Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AgentsPage(),
                  ),
                );
              },
            ),
          if (widget.agentRole == "Admin")
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Ferme la Drawer
                // Ajoutez une action ici
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
            ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mon compte'),
            onTap: () {
              Navigator.pop(context); // Ferme la Drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SingleAgentPage(
                    agentID: widget.agentID,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
