import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_i])),
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
