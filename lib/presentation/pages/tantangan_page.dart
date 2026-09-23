import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../mobx/product_store.dart';

class TantanganPage extends StatelessWidget {
  final ProductStore productStore;

  const TantanganPage({super.key, required this.productStore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tantangan MobX'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Demonstrasi Computed & Reaction',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Observer(
                builder: (_) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Jumlah Produk saat ini: ${productStore.totalProducts}'),
                        const SizedBox(height: 8),
                        Text('Total Nilai Aset: Rp ${productStore.totalPrice.toStringAsFixed(0)}'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Memicu reaction log pada console
                  widgetStoreTriggerError(productStore);
                },
                child: const Text('Picu Error Reaction (Cek Console)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void widgetStoreTriggerError(ProductStore store) {
    store.errorMessage = "Pengujian Reaction pada Tantangan Page ${DateTime.now().second}";
  }
}