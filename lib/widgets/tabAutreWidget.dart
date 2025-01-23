import 'package:basileapp/outils/syncData.dart';
import 'package:basileapp/widgets/cardAddTaxWidget.dart';
import 'package:basileapp/widgets/cardAddZoneWidget.dart';
import 'package:flutter/material.dart';

class TabAutreWidget extends StatefulWidget {
  const TabAutreWidget({super.key});

  @override
  State<TabAutreWidget> createState() => _TabAutreWidgetState();
}

class _TabAutreWidgetState extends State<TabAutreWidget> {
  SyncData syncData = SyncData();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () async {
                      await syncData.fetchAndSyncTaxes();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Taxes synchronisées !')),
                      );
                    },
                    icon: const Icon(Icons.arrow_circle_down))
              ],
            ),
            const CardAddTaxWidget(),
            const SizedBox(height: 20),
            const CardAddZoneWidget()
          ],
        ),
      ),
    );
  }
}
