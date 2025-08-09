import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';  // <-- Add this import
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

    final remainingAmount = customer.remainingAmount;
    final remainingColor = remainingAmount > 0 ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRow(label: 'Mobile', value: customer.mobile ?? 'N/A'),
            const SizedBox(height: 20),
            InfoRow(label: 'Total Amount', value: '₹${customer.totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            InfoRow(label: 'Paid Amount', value: '₹${customer.paidAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            InfoRow(
              label: 'Remaining Amount',
              value: '₹${remainingAmount.toStringAsFixed(2)}',
              valueColor: remainingColor,
            ),
            const SizedBox(height: 40),

            // View Payment History button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.history, color: Colors.black),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
                  child: Text(
                    'View Payment History',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 6,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentHistoryScreen(customerKey: customerKey),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Send Reminder button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.message, color: Colors.white),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
                  child: Text(
                    'Send Reminder',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 6,
                ),
                onPressed: () async {
                  final phone = customer.mobile ?? '';
                  final message = Uri.encodeComponent(
                    'Hi there!! You have a pending amount of ₹${remainingAmount.toStringAsFixed(2)} for your purchase.',
                  );
                  final smsUri = Uri.parse('sms:$phone?body=$message');

                  if (await canLaunchUrl(smsUri)) {
                    await launchUrl(smsUri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open SMS app')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const InfoRow({
    Key? key,
    required this.label,
    required this.value,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
