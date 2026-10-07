import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/profile_page.dart';
import 'features/catalog/presentation/catalog_pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _i = 0;
  static const _titles = ['Produits', 'Catégories', 'Profil'];

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text('Les données enregistrées sur l’appareil seront effacées.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Déconnexion')),
        ],
      ),
    );
    // logout() vide tokens + cache ; l'App bascule seule sur LoginPage (AuthStatus).
    if (ok == true && mounted) await context.read<AuthController>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_i]),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: IndexedStack(index: _i, children: const [
        ProductsPage(),
        CategoriesPage(),
        ProfilePage(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), label: 'Produits'),
          NavigationDestination(icon: Icon(Icons.category_outlined), label: 'Catégories'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
