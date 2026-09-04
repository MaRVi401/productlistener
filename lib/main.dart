import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/tantangan_page.dart';
import 'pages/product_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product Catalog',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Home',
    'Tantangan',
    'Tugas Katalog',
  ];

  @override
  Widget build(BuildContext context) {
    // List Halaman ditaruh di dalam build agar fungsi pindah tab aktif sempurna
    final List<Widget> pages = [
      HomePage(
        onNavigateToCatalog: () {
          setState(() {
            _selectedIndex = 2; // Otomatis pindah ke Tab Tugas Katalog
          });
        },
      ),
      const TantanganPage(),
      const ProductListPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Tantangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tugas',
          ),
        ],
      ),
    );
  }
}