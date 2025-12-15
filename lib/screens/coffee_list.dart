import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coffee.dart';
import '../services/api_service.dart';
import '../providers/auth_providers.dart';
import 'catalog_screens.dart' show CatalogScreen;
import 'profile_screens.dart';
import 'settings_screen.dart';

class CoffeeListScreen extends StatefulWidget {
  const CoffeeListScreen({super.key});

  @override
  State<CoffeeListScreen> createState() => _CoffeeListScreenState();
}

class _CoffeeListScreenState extends State<CoffeeListScreen>
    with SingleTickerProviderStateMixin {
  Future<List<Coffee>>? _coffeeList;
  String? _token;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Animation controller for staggered card animations
  late final AnimationController _controller;

  // Preference overlay
  bool showPreference = false;

  // Coffee type preferences
  Map<String, bool> coffeePreferences = {
    'Espresso': false,
    'Cappuccino': false,
    'Latte': false,
    'Mocha': false,
    'Americano': false,
  };

  @override
  void initState() {
    super.initState();
    _initializeData();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // start animation after a short delay so UI is ready
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _controller.forward();
    });

    _checkPreferenceShown();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
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
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Provider.of<AuthProvider>(context, listen: false).logout();
    }
  }

  void _showCoffeeDetail(Coffee coffee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1E6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(18),
              child: ListView(
                controller: controller,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.brown.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    coffee.coffeeName ?? "No Coffee",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B6D5C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    coffee.coffeeType ?? "",
                    style: TextStyle(fontSize: 16, color: Colors.brown.shade700),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (coffee.imageUrl != null && coffee.imageUrl!.isNotEmpty)
                        ? Image.network(
                            coffee.imageUrl!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Description",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.brown.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(coffee.description ?? "No description provided."),
                  const SizedBox(height: 12),
                  Text(
                    "Ingredients",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.brown.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(coffee.ingredients ?? "No ingredients provided."),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text("Min Price: ${coffee.minPrice ?? '-'}"),
                      ),
                      Expanded(
                        child: Text("Max Price: ${coffee.maxPrice ?? '-'}"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B6D5C),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Close"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Interval _staggerInterval(int index, {int maxCount = 12}) {
    final step = 0.05;
    final start = (index * step).clamp(0.0, 0.6);
    final end = (start + 0.55).clamp(0.0, 1.0);
    return Interval(start, end, curve: Curves.easeOutBack);
  }

  /// Check if preference popup was already shown
  void _checkPreferenceShown() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('preferenceShown') ?? false;

    if (!seen) {
      // Load saved selections if any
      for (var key in coffeePreferences.keys) {
        coffeePreferences[key] = prefs.getBool('pref_$key') ?? false;
      }

      setState(() {
        showPreference = true;
      });
    }
  }

 Widget _preferenceOverlay() {
  return Stack(
    children: [
      // Background dim
      Container(
        color: Colors.black.withOpacity(0.45),
      ),

      // Skip button (top-right)
      Positioned(
        top: 50,
        right: 30,
        child: GestureDetector(
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('preferenceShown', true);
            setState(() => showPreference = false);
          },
          child: Text(
            "Skip",
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),

      // Card
      Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.88,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    "My Coffee Preferences",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.brown.shade700,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Coffee Type
                Text("Coffee Type",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown.shade700)),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: "e.g. strong, balanced, sweet",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Allowance
                Text("Coffee Allowance (₱)",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown.shade700)),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Temperature Dropdown
                Text("Temperature",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown.shade700)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text("Select Temperature"),
                      items: ["Hot", "Iced", "Warm"]
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {},
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Allergies
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text("Lactose Intolerant"),
                        value: false,
                        onChanged: (v) {},
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text("Nut Allergy"),
                        value: false,
                        onChanged: (v) {},
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Milk Alternative Dropdown (two side by side)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text("Milk Options"),
                            items: ["Soy", "Almond", "Oat", "None"]
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text("Sweetness Level"),
                            items: ["None", "25%", "50%", "100%"]
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B6D5C),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('preferenceShown', true);
                      setState(() => showPreference = false);
                    },
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}


  @override
  Widget build(BuildContext context) {
    final localImages = [
      'assets/images/storage/coffees/affogato.jpg',
      'assets/images/storage/coffees/americano.jpg',
      'assets/images/storage/coffees/breve_coffee.jpg',
      'assets/images/storage/coffees/brown_sugar_latte.jpg',
      'assets/images/storage/coffees/bulletproof_latte.jpg',
      'assets/images/storage/coffees/cafe_au_lait.jpg',
      'assets/images/storage/coffees/cafe_latte.jpg',
      'assets/images/storage/coffees/cappuccino.jpg',
      'assets/images/storage/coffees/caramel_frappe.jpg',
      'assets/images/storage/coffees/caramel-latte.jpg',
      'assets/images/storage/coffees/chocolate_frappe.jpg',
      'assets/images/storage/coffees/chocolate_frappuccino.jpg',
      'assets/images/storage/coffees/cinnamon_dolce_latte.jpg',
      'assets/images/storage/coffees/coconut_sugar_latte.jpg',
      'assets/images/storage/coffees/cold_brew.jpg',
      'assets/images/storage/coffees/cortado.jpg',
      'assets/images/storage/coffees/dirty_chai_latte.jpg',
      'assets/images/storage/coffees/drip_coffee.jpg',
      'assets/images/storage/coffees/dulce_de_leche_latte.jpg',
      'assets/images/storage/coffees/espresso_con_panna.jpg',
      'assets/images/storage/coffees/espresso.jpg',
      'assets/images/storage/coffees/flat_white.jpg',
      'assets/images/storage/coffees/hazelnut_latte.jpg',
      'assets/images/storage/coffees/iced_caramel_macchiato.jpg',
      'assets/images/storage/coffees/iced_honey_oatmilk_latte.jpg',
      'assets/images/storage/coffees/icedmatcha.webp',
      'assets/images/storage/coffees/japanese_iced_coffee.jpg',
      'assets/images/storage/coffees/java_chip_frappuccino.jpg',
      'assets/images/storage/coffees/kapeng_barako.png',
      'assets/images/storage/coffees/latte.png',
      'assets/images/storage/coffees/long_black.jpg',
      'assets/images/storage/coffees/macapuno_latte.jpg',
      'assets/images/storage/coffees/macchiato.jpg',
      'assets/images/storage/coffees/maple_latte.jpg',
      'assets/images/storage/coffees/matcha_pandan_latte.jpg',
      'assets/images/storage/coffees/mocha_frappuccino.jpg',
      'assets/images/storage/coffees/mocha.jpg',
      'assets/images/storage/coffees/muscovado_latte.jpg',
      'assets/images/storage/coffees/piccolo_latte.jpg',
      'assets/images/storage/coffees/raspberry_mocha.jpg',
      'assets/images/storage/coffees/red_eye_coffee.jpg',
      'assets/images/storage/coffees/ristretto.jpg',
      'assets/images/storage/coffees/salted_caramel_latte.jpg',
      'assets/images/storage/coffees/spanish_latte.jpg',
      'assets/images/storage/coffees/sweet_corn_latte.jpg',
      'assets/images/storage/coffees/toasted_coconut_mocha.jpg',
      'assets/images/storage/coffees/ube_latte.jpg',
      'assets/images/storage/coffees/vanilla_latte.jpg',
      'assets/images/storage/coffees/vienna_coffee.jpg',
      'assets/images/storage/coffees/white_chocolate_mocha.jpg',
    
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        title: const Text(
          'Coffee List',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          )
        ],
      ),
      body: Stack(
        children: [
          _token == null
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<Coffee>>(
                  future: _coffeeList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No coffees found"));
                    }

                    final coffees = snapshot.data!;
                    final filtered = coffees.where((coffee) {
                      final q = _searchQuery.toLowerCase();
                      return (coffee.coffeeName ?? "").toLowerCase().contains(q) ||
                          (coffee.coffeeType ?? "").toLowerCase().contains(q);
                    }).toList();

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "Top Recommended Coffee",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Top recommended horizontal list
                          SizedBox(
                            height: 210,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: coffees.length < 3 ? coffees.length : 3,
                              itemBuilder: (context, index) {
                                final coffee = coffees[index];
                                return _AnimatedCoffeeCard(
                                  width: 160,
                                  imageWidget: (errorBuilder) =>
                                      (coffee.imageUrl != null &&
                                              coffee.imageUrl!.isNotEmpty)
                                          ? Image.network(
                                              coffee.imageUrl!,
                                              height: 110,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  errorBuilder(),
                                            )
                                          : Image.asset(
                                              localImages[index % localImages.length],
                                              height: 110,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                  title: coffee.coffeeName ?? "Unknown",
                                  subtitle: coffee.coffeeType ?? "",
                                  onViewPressed: () => _showCoffeeDetail(coffee),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Search bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 4,
                                    offset: const Offset(2, 3),
                                  )
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search coffee...",
                                  icon: Icon(Icons.search, color: Color(0xFF8B6D5C)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "All Coffee",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final coffee = filtered[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF1E6),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.brown.shade200.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: (coffee.imageUrl != null &&
                                              coffee.imageUrl!.isNotEmpty)
                                          ? Image.network(
                                              coffee.imageUrl!,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Image.asset(
                                                localImages[index % localImages.length],
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Image.asset(
                                              localImages[index % localImages.length],
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            coffee.coffeeName ?? "Unknown",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF8B6D5C),
                                            ),
                                          ),
                                          Text(
                                            coffee.coffeeType ?? "",
                                            style: const TextStyle(
                                                color: Color(0xFF8B6D5C)),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            coffee.description ?? "",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(color: Color(0xFF8B6D5C)),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text("Min: ${coffee.minPrice ?? '-'}",
                                                  style: const TextStyle(
                                                      color: Color(0xFF8B6D5C))),
                                              const SizedBox(width: 12),
                                              Text("Max: ${coffee.maxPrice ?? '-'}",
                                                  style: const TextStyle(
                                                      color: Color(0xFF8B6D5C))),
                                              const Spacer(),
                                              _TapAnimatedButton(
                                                label: "View",
                                                onPressed: () =>
                                                    _showCoffeeDetail(coffee),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    );
                  },
                ),
          if (showPreference) _preferenceOverlay(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (i) {
          if (i == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CatalogScreen()));
          } else if (i == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()));
          } else {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.coffee), label: "Catalog"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

/// Animated coffee card
class _AnimatedCoffeeCard extends StatefulWidget {
  final double width;
  final Widget Function(Widget Function()) imageWidget;
  final String title;
  final String subtitle;
  final VoidCallback onViewPressed;

  const _AnimatedCoffeeCard({
    required this.width,
    required this.imageWidget,
    required this.title,
    required this.subtitle,
    required this.onViewPressed,
  });

  @override
  State<_AnimatedCoffeeCard> createState() => _AnimatedCoffeeCardState();
}

class _AnimatedCoffeeCardState extends State<_AnimatedCoffeeCard> {
  double _scale = 1.0;

  void _onTapDown(_) => setState(() => _scale = 0.96);
  void _onTapUp(_) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onViewPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: widget.width,
          margin: const EdgeInsets.only(left: 20, right: 10, bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 6,
                offset: const Offset(2, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.imageWidget(() {
                  return Container(
                    height: 110,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.coffee, size: 36),
                  );
                }),
              ),
              const SizedBox(height: 10),
              Text(widget.title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B6D5C))),
              Text(widget.subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: _TapAnimatedButton(
                  label: "View",
                  onPressed: widget.onViewPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Button that animates on tap
class _TapAnimatedButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _TapAnimatedButton({required this.label, required this.onPressed});

  @override
  State<_TapAnimatedButton> createState() => _TapAnimatedButtonState();
}

class _TapAnimatedButtonState extends State<_TapAnimatedButton> {
  double _scale = 1.0;

  void _onTapDown(_) => setState(() => _scale = 0.95);
  void _onTapUp(_) => setState(() {
        _scale = 1.0;
        widget.onPressed();
      });
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Material(
          color: const Color(0xFF8B6D5C),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Text(
                widget.label,
                style:
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
