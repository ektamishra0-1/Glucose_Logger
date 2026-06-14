import 'package:flutter/material.dart';

import '../features/records/records_vault_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Center(
              child: Text("⚡ GLUCOSE VAULT", style: TextStyle(fontSize: 24)),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text("Records Vault"),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecordsVaultPage()),
              );
            },
          ),

          const ListTile(leading: Icon(Icons.games), title: Text("Arcade")),

          const ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
          ),
        ],
      ),
    );
  }
}
