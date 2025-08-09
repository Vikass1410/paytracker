import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({Key? key}) : super(key: key);

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _mobileController = TextEditingController();

  final _nameFocus = FocusNode();
  final _mobileFocus = FocusNode();
  final _amountFocus = FocusNode();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _totalAmountController.dispose();
    _mobileController.dispose();
    _nameFocus.dispose();
    _mobileFocus.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final box = Hive.box<Customer>('customers');

      final newCustomer = Customer(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim().isEmpty ? null : _mobileController.text.trim(),
        totalAmount: double.parse(_totalAmountController.text.trim()),
        paidAmount: 0.0,
        paymentHistory: [],
      );

      await box.add(newCustomer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer added successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving customer: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final pattern = RegExp(r'^\+?[\d\s-]{7,15}$'); // basic phone pattern
    if (!pattern.hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Customer'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              shadowColor: isDark ? Colors.tealAccent.shade700 : Colors.grey.shade300,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Customer Name',
                          hintText: 'Enter full name',
                          suffixIcon: _nameController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _nameController.clear();
                              setState(() {});
                            },
                          )
                              : null,
                        ),
                        validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Please enter a name' : null,
                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_mobileFocus),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _mobileController,
                        focusNode: _mobileFocus,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number (optional)',
                          hintText: '+91 ***** *****',
                          suffixIcon: _mobileController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _mobileController.clear();
                              setState(() {});
                            },
                          )
                              : null,
                        ),
                        validator: _validateMobile,
                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_amountFocus),
                        onChanged: (_) => setState(() {}),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\s]')),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _totalAmountController,
                        focusNode: _amountFocus,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Total Amount',
                          hintText: 'Amount in INR',
                          prefixText: '₹ ',
                          suffixIcon: _totalAmountController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _totalAmountController.clear();
                              setState(() {});
                            },
                          )
                              : null,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the total amount';
                          }
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null || parsed <= 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                        onChanged: (_) => setState(() {}),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: isDark ? Colors.tealAccent.shade700 : Colors.teal,
                          ),
                          onPressed: _isSaving ? null : _saveCustomer,
                          child: _isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            'Save Customer',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
