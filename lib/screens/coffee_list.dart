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
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set Your Preferences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Choose your favorite coffee types:'),
            const SizedBox(height: 16),
            ...coffeePreferences.keys.map((type) {
              return CheckboxListTile(
                title: Text(type),
                value: coffeePreferences[type],
                onChanged: (val) {
                  setState(() {
                    coffeePreferences[type] = val ?? false;
                  });
                },
              );
            }).toList(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('preferenceShown', true);
                    setState(() {
                      showPreference = false;
                    });
                  },
                  child: const Text('Skip'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B6D5C),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('preferenceShown', true);
                    for (var entry in coffeePreferences.entries) {
                      await prefs.setBool('pref_${entry.key}', entry.value);
                    }
                    setState(() {
                      showPreference = false;
                    });
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localImages = [
      'assets/images/default_coffee.jpg',
      'assets/images/espresso.jpg',
      'assets/images/mocha.jpg',
      'assets/images/cappuccino.jpg',
      'assets/images/americano.jpg',
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
