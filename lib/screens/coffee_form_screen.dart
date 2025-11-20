import 'package:flutter/material.dart';
import '../models/coffee.dart';
import '../services/api_service.dart';

class CoffeeFormScreen extends StatefulWidget {
  final Coffee? coffee; // null = add, not null = edit
  const CoffeeFormScreen({super.key, this.coffee});

  @override
  State<CoffeeFormScreen> createState() => _CoffeeFormScreenState();
}

class _CoffeeFormScreenState extends State<CoffeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // populate fields if editing
    if (widget.coffee != null) {
      _nameController.text = widget.coffee!.coffeeName ?? '';
      _typeController.text = widget.coffee!.coffeeType ?? '';
      _descController.text = widget.coffee!.description ??  '';
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coffee == null ? 'Add Coffee' : 'Edit Coffee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Coffee Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter coffee name' : null,
                ),
                TextFormField(
                  controller: _typeController,
                  decoration: const InputDecoration(labelText: 'Coffee Type'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter coffee type' : null,
                ),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter description' : null,
                ),
                const SizedBox(height: 20),
                _isSaving
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveCoffee,
                        child: Text(widget.coffee == null ? 'Save' : 'Update'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveCoffee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final coffee = Coffee(
      id: widget.coffee?.id,
      coffeeName: _nameController.text,  // keep ID if updating
      coffeeType: _typeController.text,
      description: _descController.text,
    );

    try {
      if (widget.coffee == null) {
        await ApiService.createCoffee(coffee);
      } else {
        await ApiService.updateCoffee(coffee.id!.toString(), coffee);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
