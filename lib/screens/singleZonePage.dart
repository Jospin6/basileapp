import 'package:basileapp/widgets/zoneAgentsTab.dart';
import 'package:basileapp/widgets/zoneClientTab.dart';
import 'package:basileapp/widgets/zoneDashboardTab.dart';
import 'package:basileapp/widgets/zoneHistsTab.dart';
import 'package:flutter/material.dart';

class SingleZonePage extends StatefulWidget {
  final String zoneName;
  const SingleZonePage({super.key, required this.zoneName});

  @override
  State<SingleZonePage> createState() => _SingleZonePageState();
}

class _SingleZonePageState extends State<SingleZonePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
        title: Text(
          widget.zoneName,
          style: const TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          unselectedLabelColor: const Color.fromARGB(255, 209, 208, 208),
          tabs: const [
            Tab(text: "Dash"),
            Tab(text: "Hist"),
            Tab(text: "Clients"),
            Tab(text: "Agents"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // dash
          Zonedashboardtab(
            zoneName: widget.zoneName,
          ),
          // hist
          Zonehiststab(
            zoneName: widget.zoneName,
          ),
          // clients
          Zoneclienttab(
            zoneName: widget.zoneName,
          ),
          // agents
          Zoneagentstab(
            zoneName: widget.zoneName,
          )
        ],
      ),
    );
  }
}
