import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/customer.dart';
import 'payment_history_screen.dart';

class CustomerSelectionScreen extends StatefulWidget {
  const CustomerSelectionScreen({Key? key}) : super(key: key);

  @override
  State<CustomerSelectionScreen> createState() => _CustomerSelectionScreenState();
}

class _CustomerSelectionScreenState extends State<CustomerSelectionScreen> {
  late Box<Customer> customerBox;
  List<Customer> allCustomers = [];
  List<Customer> filteredCustomers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    customerBox = Hive.box<Customer>('customers');
    allCustomers = customerBox.values.toList();
    filteredCustomers = List.from(allCustomers);

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        filteredCustomers = allCustomers.where((c) => c.name.toLowerCase().contains(query)).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (allCustomers.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Customer')),
        body: const Center(child: Text('No customers found. Please add customers first.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Customer'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search customer by name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filteredCustomers.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final customer = filteredCustomers[index];
                final key = customerBox.keyAt(customerBox.values.toList().indexOf(customer));
                return ListTile(
                  title: Text(customer.name),
                  subtitle: Text(customer.mobile ?? 'No phone'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentHistoryScreen(customerKey: key),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
