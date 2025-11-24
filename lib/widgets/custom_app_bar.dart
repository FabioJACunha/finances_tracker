import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../features/categories/category_screen.dart';

typedef SettingsBuilder = Widget Function(BuildContext context);

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget leading; // mandatory
  final List<Widget>? extraActions;
  final SettingsBuilder? settingsBuilder;

  /// [leading] is required (your screen icon).
  /// [settingsBuilder] can provide a custom settings content; otherwise a simple default list is shown.
  const CustomAppBar({
    super.key,
    required this.title,
    required this.leading,
    this.extraActions,
    this.settingsBuilder,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _openSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgTerciary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        if (settingsBuilder != null) {
          return settingsBuilder!(ctx);
        }

        // Default settings content — simple list of options
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: const Text('Categories'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CategoryScreen()),
                      );
                      // Add navigation or callback as needed
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.tune),
                    title: const Text('Preferences'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      // Add navigation or callback as needed
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      // Add navigation or callback as needed
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgPrimary,
      scrolledUnderElevation: 0.0,
      surfaceTintColor: Colors.transparent,
      title: Text(title, style: const TextStyle(color: AppColors.textDark)),
      titleSpacing: 0,
      leading: leading,
      actions: [
        if (extraActions != null) ...extraActions!,
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings, color: AppColors.textDark),
          onPressed: () => _openSettings(context),
        ),
      ],
    );
  }
}
