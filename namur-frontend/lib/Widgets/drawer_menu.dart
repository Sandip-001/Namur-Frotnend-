import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/account_screen.dart';
import '../screens/language_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/my_bookings_screen.dart';
import '../screens/notification_screen.dart';
// import '../screens/more_details_screen.dart';
import '../screens/contactus_screen.dart';
import '../screens/about_us_screen.dart';
import '../screens/new_add_screen.dart';
import '../screens/profile_screen.dart';
import '../seller_profile_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  /// 🔹 Reusable compact drawer item
  Widget drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.green,
  }) {
    return ListTile(
      // visualDensity: const VisualDensity(vertical: -2),
      // contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: color, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              drawerItem(
                icon: Icons.home,
                title: "home_label".tr(),
                onTap: () => _navigateTo(context, const HomeScreen()),
              ),
              drawerItem(
                icon: Icons.inventory,
                title: "my_ads".tr(),
                onTap: () => _navigateTo(context, const SellerProfileScreen()),
              ),
              drawerItem(
                icon: Icons.favorite_outline,
                title: "wishlist".tr(),
                onTap: () => _navigateTo(context, const WishlistScreen()),
              ),
              drawerItem(
                icon: Icons.add_box,
                title: "new_ads".tr(),
                onTap: () => _navigateTo(context, const NewAddsScreen()),
              ),
              drawerItem(
                icon: Icons.mail,
                title: "inbox".tr(),
                onTap: () => _navigateTo(context, const NotificationScreen()),
              ),
              drawerItem(
                icon: Icons.person,
                title: "my_account_label".tr(),
                onTap: () => _navigateTo(context, const AccountScreen()),
              ),
              drawerItem(
                icon: Icons.event,
                title: "my_bookings".tr(),
                onTap: () => _navigateTo(context, const MyBookingsScreen()),
              ),
              ExpansionTile(
                leading: const Icon(
                  Icons.settings,
                  color: Colors.green,
                  size: 20,
                ),
                title: Text("settings".tr(), style: const TextStyle(fontSize: 14)),
                childrenPadding: const EdgeInsets.only(left: 20),
                children: [
                  drawerItem(
                    icon: Icons.edit,
                    title: "edit_profile".tr(),
                    onTap: () => _navigateTo(context, const ProfileScreen()),
                  ),
                  drawerItem(
                    icon: Icons.language,
                    title: "language_change".tr(),
                    onTap: () =>
                        _navigateTo(context, const LanguageSelectionScreen()),
                  ),
                  drawerItem(
                    icon: Icons.delete,
                    title: "delete_account".tr(),
                    color: Colors.red,
                    onTap: () async {
                      final auth = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );

                      final rootNavigator = Navigator.of(
                        context,
                        rootNavigator: true,
                      );

                      Navigator.pop(context);

                      final confirm = await showDialog<bool>(
                        context: rootNavigator.context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text("delete_account_title".tr()),
                          content: Text(
                            "delete_account_message".tr(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(false),
                              child: Text("cancel".tr()),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              onPressed: () => Navigator.of(dialogContext).pop(true),
                              child: Text("delete".tr()),
                            ),
                          ],
                        ),
                      );

                      if (confirm != true) return;

                      final result = await auth.deleteAccount();

                      if (result == DeleteAccountResult.success) {
                        rootNavigator.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => LoginPage()),
                          (_) => false,
                        );
                      } else if (result == DeleteAccountResult.requiresReLogin) {
                        ScaffoldMessenger.maybeOf(rootNavigator.context)?.showSnackBar(
                          SnackBar(
                            content: Text("relogin_and_retry_delete".tr()),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.maybeOf(rootNavigator.context)?.showSnackBar(
                          SnackBar(
                            content: Text("failed_delete_account".tr()),
                          ),
                        );
                      }
                    },
                  ),
                  drawerItem(
                    icon: Icons.info,
                    title: "about_us_title".tr(),
                    onTap: () => _navigateTo(context, const AboutUsScreen()),
                  ),
                ],
              ),
              drawerItem(
                icon: Icons.contact_mail,
                title: "contact_us".tr(),
                onTap: () => _navigateTo(context, const ContactUsPage()),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  'version: 1.0.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              drawerItem(
                icon: Icons.logout,
                title: "logout".tr(),
                color: Colors.red,
                onTap: () async {
                  Navigator.pop(context);

                  final auth = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await auth.logout();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                    (_) => false,
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
