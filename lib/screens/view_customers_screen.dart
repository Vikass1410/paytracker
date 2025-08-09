import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';
import 'customer_detail_screen.dart'; // Import your detail screen

class ViewCustomersScreen extends StatelessWidget {
  const ViewCustomersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Box<Customer> customerBox = Hive.box<Customer>('customers');

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: ValueListenableBuilder<Box<Customer>>(
        valueListenable: customerBox.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No customers added yet.'));
          }

          final customers = box.values.toList();

          return ListView.separated(
            itemCount: customers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final customer = customers[index];

              return ListTile(
                title: Text(customer.name),
                subtitle: Text('Due: ₹${customer.remainingAmount.toStringAsFixed(2)}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CustomerDetailScreen(customerKey: customer.key),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
