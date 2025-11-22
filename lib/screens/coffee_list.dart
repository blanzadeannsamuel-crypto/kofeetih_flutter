import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coffee.dart';
import '../services/api_service.dart';
import 'coffee_form_screen.dart';

class CoffeeListScreen extends StatefulWidget {
  const CoffeeListScreen({super.key});

  @override
  State<CoffeeListScreen> createState() => _CoffeeListScreenState();
}

class _CoffeeListScreenState extends State<CoffeeListScreen> {
  late Future<List<Coffee>>? _coffeeList;
  String? _token;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    await _getToken();
    _refreshCoffees();
  }

  Future<void> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  void _refreshCoffees() {
    if (_token == null) return;
    setState(() {
      _coffeeList = ApiService.getCoffees(token: _token!);
    });

    print("coffee list refreshed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coffee List')),
      
      body: _token == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Coffee>>(
              future: _coffeeList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No coffees found'));
                }

                final coffees = snapshot.data!;
                return ListView.builder(
                  itemCount: coffees.length,
                  itemBuilder: (context, index) {
                    final coffee = coffees[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                      title: Text(coffee.coffeeName?? 'No Coffee'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(coffee.coffeeType ?? 'No coffee Type'),
                            const SizedBox(height: 4),
                            Text(coffee.description ?? 'No Description'),
                            const SizedBox(height: 4),
                            Text(coffee.ingredients ?? 'No ingredients'),
                            const SizedBox(height: 4),
                            Text('Min Price: ${coffee.minPrice?.toString() ?? 'N/A'}'),
                            const SizedBox(height: 4),
                            Text('Max Price: ${coffee.maxPrice?.toString() ?? 'N/A'}'),
                          ],
                        ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CoffeeFormScreen(coffee: coffee),
                                ),
                              );
                              if (updated == true) _refreshCoffees();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: Text(
                                      'Are you sure you want to delete "${coffee.coffeeName}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ApiService.deleteCoffee(coffee.id!.toString(), _token!);
                                _refreshCoffees();
                              }
                            },
                          ),
                        ],
                      ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CoffeeFormScreen()),
          );
          if (added == true) _refreshCoffees();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
