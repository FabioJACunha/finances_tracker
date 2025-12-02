import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../features/categories/category_screen.dart';
import '../features/accounts/accounts_screen.dart';
import '../features/preferences/preferences_screen.dart';
import '../l10n/app_localizations.dart'; // Import localization

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
    final palette = currentPalette;
    final loc = AppLocalizations.of(context)!; // Get localization

    showModalBottomSheet(
      context: context,
      // Use palette colors for the modal background
      backgroundColor: palette.bgTerciary,
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
            color: palette.bgPrimary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Icon(
                      Icons.category_outlined,
                      color: palette.textDark,
                    ),
                    title: Text(
                      loc.settingsCategories, // Localized
                      style: TextStyle(color: palette.textDark),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      // Assuming CategoryScreen exists, otherwise this will fail
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CategoryScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.account_balance_outlined,
                      color: palette.textDark,
                    ),
                    title: Text(
                      loc.settingsAccounts, // Localized
                      style: TextStyle(color: palette.textDark),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      // Assuming AccountsScreen exists, otherwise this will fail
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AccountsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.tune, color: palette.textDark),
                    title: Text(
                      loc.settingsPreferences, // Localized
                      style: TextStyle(color: palette.textDark),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PreferencesScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.info_outline, color: palette.textDark),
                    title: Text(
                      loc.settingsAbout, // Localized
                      style: TextStyle(color: palette.textDark),
                    ),
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
    // We access the current palette directly, relying on the
    // parent MaterialApp (or similar) to rebuild when the palette changes.
    final palette = currentPalette;

    return AppBar(
      backgroundColor: palette.bgPrimary,
      scrolledUnderElevation: 0.0,
      surfaceTintColor: Colors.transparent,
      title: Text(title, style: TextStyle(color: palette.textDark)),
      titleSpacing: 0,
      leading: leading,
      actions: [
        if (extraActions != null) ...extraActions!,
        IconButton(
          icon: Icon(Icons.menu, color: palette.textDark),
          onPressed: () => _openSettings(context),
        ),
      ],
    );
  }
}
