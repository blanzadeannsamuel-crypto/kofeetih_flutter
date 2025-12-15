import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coffee.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String displayName = "coffee";
  String email = "user@example.com";

  late TextEditingController _displayNameController;

  List<Coffee> coffees = [];
  bool isLoading = true;
  String token = '';

  final Color accentBrown = const Color(0xFFB58C6E);

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: displayName);
    loadUserData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');

    if (storedToken == null || storedToken.isEmpty) {
      if (!mounted) return;
      setState(() => isLoading = false);
      return;
    }

    token = storedToken;
    displayName = prefs.getString('displayName') ?? 'coffee';
    email = prefs.getString('email') ?? 'user@example.com';

    _displayNameController.text = displayName;

    await fetchCoffees();
  }

  Future<void> fetchCoffees() async {
    try {
      final allCoffees = await ApiService.getCoffees(token: token);
      if (!mounted) return;
      setState(() {
        coffees = allCoffees;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load coffees: ${e.toString()}')),
      );
    }
  }

  void saveDisplayName() async {
    final name = _displayNameController.text.trim();
    if (name.isEmpty || name == displayName) return;

    setState(() => displayName = name);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("displayName", displayName);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Display name saved')),
    );
  }

  Widget buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: accentBrown, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: Text(
          "$displayName's Profile",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8F0), Color(0xFFD8A47F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 70),

                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: accentBrown.withOpacity(0.3),
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Cards
                    buildInfoCard(
                      icon: Icons.person,
                      label: "Display Name",
                      value: displayName,
                    ),
                    const SizedBox(height: 12),

                    buildInfoCard(
                      icon: Icons.email,
                      label: "Email",
                      value: email,
                    ),

                    const SizedBox(height: 20),

                    // Editable field
                    TextField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText: "Update Display Name",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: accentBrown),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Save button
                    ElevatedButton(
                      onPressed: saveDisplayName,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Save"),
                    ),

                    const SizedBox(height: 10),

                    // My Preferences
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/preference");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("My Preferences"),
                    ),
                  ],
                ),
              ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/settings');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.coffee),
            label: "Catalog",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
