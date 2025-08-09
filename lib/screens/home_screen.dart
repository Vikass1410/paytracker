import 'dart:async';
// <-- Add this import
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';
import 'add_customer_screen.dart';
import 'customer_detail_screen.dart';
import 'customer_selection_screen.dart';
import 'settings_screen.dart';
import 'payment_history_screen.dart' hide CustomerDetailScreen;

enum SortOption { nameAsc, nameDesc, pendingHigh, pendingLow }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Customer> customerBox;
  List<Customer> filteredCustomers = [];
  String _searchQuery = '';
  Timer? _debounce;
  SortOption _sortOption = SortOption.nameAsc;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    customerBox = Hive.box<Customer>('customers');
    _applyFilters();
    customerBox.listenable().addListener(_applyFilters);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    customerBox.listenable().removeListener(_applyFilters);
    super.dispose();
  }

  void _applyFilters() {
    List<Customer> allCustomers = customerBox.values.toList();

    // Filter by search query (name only)
    if (_searchQuery.isNotEmpty) {
      allCustomers = allCustomers
          .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Sort customers based on selected option
    _sortCustomers(allCustomers);

    setState(() {
      filteredCustomers = allCustomers;
    });
  }

  void _sortCustomers(List<Customer> list) {
    switch (_sortOption) {
      case SortOption.nameAsc:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.nameDesc:
        list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case SortOption.pendingHigh:
        list.sort(
                (a, b) => (b.totalAmount - b.paidAmount).compareTo(a.totalAmount - a.paidAmount));
        break;
      case SortOption.pendingLow:
        list.sort(
                (a, b) => (a.totalAmount - a.paidAmount).compareTo(b.totalAmount - b.paidAmount));
        break;
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _searchQuery = query.trim();
      });
      _applyFilters();
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    await Future.delayed(const Duration(seconds: 1)); // simulate refresh delay
    _applyFilters();
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate summary
    final pendingCustomers = filteredCustomers.where((c) => (c.totalAmount - c.paidAmount) > 0).toList();
    final totalPendingAmount = pendingCustomers.fold<double>(
      0,
          (sum, c) => sum + (c.totalAmount - c.paidAmount),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          // Sorting dropdown menu
          PopupMenuButton<SortOption>(
            tooltip: 'Sort Customers',
            icon: const Icon(Icons.sort),
            onSelected: (option) {
              setState(() {
                _sortOption = option;
              });
              _applyFilters();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortOption.nameAsc,
                child: Text('Name A-Z'),
              ),
              const PopupMenuItem(
                value: SortOption.nameDesc,
                child: Text('Name Z-A'),
              ),
              const PopupMenuItem(
                value: SortOption.pendingHigh,
                child: Text('Pending Amount High → Low'),
              ),
              const PopupMenuItem(
                value: SortOption.pendingLow,
                child: Text('Pending Amount Low → High'),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: theme.primaryColor),
              child: const Text('PayTracker Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Add Customer'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Payment History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerSelectionScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: [
            // Summary card
            Card(
              margin: const EdgeInsets.all(12),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${pendingCustomers.length}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.redAccent.shade200 : Colors.red,
                          ),
                          semanticsLabel: '${pendingCustomers.length} customers pending payment',
                        ),
                        const SizedBox(height: 4),
                        const Text('Customers Pending'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '₹${totalPendingAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.redAccent.shade200 : Colors.red,
                          ),
                          semanticsLabel: 'Total pending amount ₹${totalPendingAmount.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 4),
                        const Text('Total Pending Amount'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search customers by name',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                      _applyFilters();
                    },
                  )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            Expanded(
              child: filteredCustomers.isEmpty
                  ? Center(
                child: Text(
                  _searchQuery.isEmpty
                      ? 'No customers found.'
                      : 'No customers match your search.',
                  style: const TextStyle(fontSize: 18),
                ),
              )
                  : ListView.separated(
                itemCount: filteredCustomers.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final customer = filteredCustomers[index];
                  // Efficient key lookup via index
                  final keys = customerBox.keys.toList();
                  final key = keys[customerBox.values.toList().indexOf(customer)];
                  final remainingAmount = customer.totalAmount - customer.paidAmount;

                  return ListTile(
                    title: Text(customer.name),
                    // Removed subtitle showing phone number
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pending: ₹${remainingAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: remainingAmount > 0 ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CustomerDetailScreen(customerKey: key),
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add New Customer',
        child: const Icon(Icons.person_add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
          );
        },
      ),
    );
  }
}
