import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/customer.dart';
import '../models/payment_entry.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final int customerKey;

  const PaymentHistoryScreen({Key? key, required this.customerKey}) : super(key: key);

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late Box<Customer> customerBox;
  late Customer customer;

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    customerBox = Hive.box<Customer>('customers');
    customer = customerBox.get(widget.customerKey)!;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addPayment() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text.trim());
      final note = _noteController.text.trim();

      if (amount > customer.remainingAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment exceeds remaining due amount.')),
        );
        return;
      }

      final newPayment = PaymentEntry(
        amount: amount,
        note: note,
        date: DateTime.now(),
      );

      setState(() {
        customer.paymentHistory.add(newPayment);
        customer.paidAmount += amount;
        customerBox.put(widget.customerKey, customer);
      });

      _amountController.clear();
      _noteController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment of ₹$amount added.')),
      );
    }
  }

  void _deletePayment(int index) {
    final payment = customer.paymentHistory[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payment?'),
        content: Text('Delete payment of ₹${payment.amount.toStringAsFixed(2)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                customer.paidAmount -= payment.amount;
                customer.paymentHistory.removeAt(index);
                customerBox.put(widget.customerKey, customer);
              });
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Payment of ₹${payment.amount.toStringAsFixed(2)} deleted.')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = customer.totalAmount - customer.paidAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Payments for ${customer.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(customer.mobile ?? 'No mobile'),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Total: ₹${customer.totalAmount.toStringAsFixed(2)}'),
                    Text('Paid: ₹${customer.paidAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green)),
                    Text('Remaining: ₹${remaining.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Payment Amount (₹)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Enter amount';
                      final val = double.tryParse(value.trim());
                      if (val == null || val <= 0) return 'Enter valid positive number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Payment'),
                    onPressed: _addPayment,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: customer.paymentHistory.isEmpty
                  ? const Center(child: Text('No payments recorded yet.'))
                  : ListView.builder(
                itemCount: customer.paymentHistory.length,
                itemBuilder: (context, index) {
                  final payment = customer.paymentHistory[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text('₹${payment.amount.toStringAsFixed(2)}'),
                    subtitle: Text(
                      '${payment.note.isNotEmpty ? '${payment.note}\n' : ''}${DateFormat.yMMMd().add_jm().format(payment.date)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePayment(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
