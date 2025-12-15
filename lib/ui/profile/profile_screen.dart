import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/theme_controller.dart';
import '../../model/auth/login_model.dart';
import '../../utils/color_app.dart';
import '../../utils/my_shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final UserModel user = mySharedPreferences.getUserData()!;

    final textTheme = Theme.of(context).textTheme;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor:
                    ColorApp.primary.withValues(alpha: 0.15),
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color: ColorApp.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.email,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _roleName(user.roleId),
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Info Cards
            _infoTile(
              context,
              Icons.badge,
              'User ID',
              user.userId.toString(),
            ),
            _infoTile(
              context,
              Icons.perm_identity,
              'Employee ID',
              user.employeeId.toString(),
            ),
            _infoTile(
              context,
              Icons.security,
              'Role ID',
              user.roleId.toString(),
            ),
            _infoTile(
              context,
              Icons.email,
              'Email',
              user.email,
            ),

            const SizedBox(height: 8),

            // 🔹 Settings Section
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 🌗 Dark Mode
                  Obx(() {
                    final isDark = themeController.isDark.value;

                    return ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16),
                      leading: _leadingIcon(
                        context,
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        Colors.blueGrey,
                      ),
                      title: Text(
                        'Dark Mode',
                        style: textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        isDark
                            ? 'Dark theme enabled'
                            : 'Light theme enabled',
                        style: textTheme.bodySmall,
                      ),
                      trailing: Switch(
                        value: isDark,
                        onChanged: themeController.toggleTheme,
                      ),
                    );
                  }),

                  const Divider(height: 1, indent: 72),

                  // 🚪 Logout
                  ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    leading: _leadingIcon(
                      context,
                      Icons.logout_rounded,
                      Colors.red,
                    ),
                    title: Text(
                      'Logout',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      'Sign out from your account',
                      style: textTheme.bodySmall,
                    ),
                    trailing:
                    const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Info Tile
  Widget _infoTile(
      BuildContext context,
      IconData icon,
      String title,
      String value,
      ) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: ColorApp.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _leadingIcon(
      BuildContext context,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // mySharedPreferences.clear();
              // Get.offAll(() => LoginScreen());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _roleName(int roleId) {
    switch (roleId) {
      case 1:
        return 'Admin';
      case 2:
        return 'Technician';
      case 3:
        return 'Engineer';
      default:
        return 'User';
    }
  }
}
