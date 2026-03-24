import 'package:flutter/material.dart';
import 'package:the_namur_frontend/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Widgets/custom_appbar.dart';
import '../Widgets/drawer_menu.dart';
import 'notification_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imageUrl = prefs.getString("profile_image_url");

    if (mounted) {
      setState(() {
        profileImageUrl = imageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "My Account", showBack: true),
      drawer: DrawerMenu(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ✅ PROFILE IMAGE FROM SHARED PREFERENCES
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? Image.network(
                        profileImageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/app_logo.png',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/app_logo.png',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),

              const SizedBox(height: 20),

              // Cart and Profile Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _iconButton(
                    icon: Icons.shopping_cart,
                    label: 'Cart',
                    color: Colors.green.shade200,
                    onTap: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coming Soon!'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _iconButton(
                    icon: Icons.person,
                    label: 'Profile',
                    color: Colors.green.shade200,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Option List
              _menuTile(
                context,
                icon: Icons.notifications,
                color: Colors.purple,
                title: "Notification",
                screen: const NotificationScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Reusable Buttons ---
  Widget _iconButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 90,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black87),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required Widget screen,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        radius: 22,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}

// ---------------- QUICK ACTION ITEM ----------------
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.green),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
/*import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "My Account",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------- PROFILE CARD ----------------
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                  )
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Pruthvi Raj PG",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "East Chitradurga Dist",
                          style:
                          TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ---------------- STATS ROW ----------------
            Row(
              children: [
                _statBox("Posts", "0", Colors.blue.shade100),
                const SizedBox(width: 8),
                _statBox("Coll Msg", "8", Colors.green.shade100),
                const SizedBox(width: 8),
                _statBox("Views", "89", Colors.red.shade100),
              ],
            ),

            const SizedBox(height: 16),

            // ---------------- QUICK ACTIONS ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _QuickAction(icon: Icons.person, label: "Profile"),
                _QuickAction(icon: Icons.location_on, label: "Address"),
                _QuickAction(icon: Icons.message, label: "Message"),
                _QuickAction(icon: Icons.shopping_bag, label: "Orders"),
              ],
            ),

            const SizedBox(height: 24),

            // ---------------- MENU LIST ----------------
            _menuTile(Icons.notifications, "Notification"),
            _menuTile(Icons.bookmark, "Saved Items"),
            _menuTile(Icons.call, "Whatsapp Group"),
            _menuTile(Icons.support_agent, "Contact Us"),
          ],
        ),
      ),
    );
  }

  // ---------------- WIDGETS ----------------

  static Widget _statBox(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  static Widget _menuTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500)),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
    );
  }
}

// ---------------- QUICK ACTION ITEM ----------------
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickAction({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.green),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
*/