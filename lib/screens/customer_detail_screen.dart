import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/customer.dart';
import 'payment_history_screen.dart';

class CustomerDetailScreen extends StatelessWidget {
  final int customerKey;

  const CustomerDetailScreen({Key? key, required this.customerKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Customer>('customers');
    final customer = box.get(customerKey);

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Customer Details')),
        body: const Center(child: Text('Customer not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(customer.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mobile: ${customer.mobile ?? "N/A"}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Total Amount: ₹${customer.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Paid Amount: ₹${customer.paidAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Remaining Amount: ₹${customer.remainingAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentHistoryScreen(customerKey: customerKey),
                    ),
                  );
                },
                child: const Text('View Payment History'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
