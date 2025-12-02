import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../locale/app_locale.dart'; // Locale management
import '../../l10n/app_localizations.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // Use a local state variable to hold the currently selected palette
  // This will be initialized with the global state.
  AppPalette _selectedPalette = currentPalette;

  void _selectPalette(AppPalette palette) {
    if (_selectedPalette != palette) {
      setState(() {
        _selectedPalette = palette;
      });
      // Update the global state management
      setAppPalette(palette);
    }
  }

  Widget _buildPaletteTile(AppPalette palette) {
    // Check if the tile's palette matches the locally selected state
    final isSelected = _selectedPalette == palette;

    return ListTile(
      title: Text(
        palette.name,
        style: TextStyle(
          color: currentPalette.textDark,
        ), // Use dynamic text color
      ),
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: palette.primary, // Use primary color for the swatch
      ),
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: currentPalette.textDark,
            ) // Use textDark for the checkmark
          : null,
      onTap: () => _selectPalette(palette),
      tileColor: isSelected ? currentPalette.bgTerciary : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
    );
  }

  Widget _buildLanguageSwitcher(AppPalette palette, AppLocalizations loc) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: currentLocaleNotifier,
      builder: (context, currentLocale, child) {
        if (currentLocale == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              loc.language,
              style: TextStyle(fontSize: 22, color: palette.textDark),
            ),
            const SizedBox(height: 12),

            ...L10n.all.map((locale) {
              final isSelected = locale == currentLocale;

              final languageName = switch (locale.languageCode) {
                'en' => 'English',
                'pt' => 'Português',
                _ => locale.languageCode.toUpperCase(),
              };

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  title: Text(
                    languageName,
                    style: TextStyle(color: palette.textDark),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: palette.textDark)
                      : null,
                  onTap: () => setAppLocale(locale),
                  tileColor: isSelected ? palette.bgTerciary : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the global theme changes to rebuild the screen if it changes externally
    return ValueListenableBuilder<AppPalette>(
      valueListenable: currentPaletteNotifier,
      builder: (context, palette, child) {
        // Ensure the local state is synchronized when the global state changes (e.g., when the app first loads)
        _selectedPalette = palette;

        // Get localizations instance
        final loc = AppLocalizations.of(context)!;

        return Scaffold(
          appBar: CustomAppBar(
            // Use localization for the title
            title: loc.preferences, // <--- Update hardcoded string
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: palette.textDark),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          backgroundColor: palette.bgPrimary,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  // Use localization for the title
                  loc.colorTheme, // <--- Update hardcoded string
                  style: TextStyle(fontSize: 22, color: palette.textDark),
                ),
                const SizedBox(height: 12),
                // Map over the list of available palettes to build the tiles
                ...availablePalettes.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildPaletteTile(p),
                  ),
                ),

                // LANGUAGE SWITCHER: Placed after the color scheme
                _buildLanguageSwitcher(palette, loc),
              ],
            ),
          ),
        );
      },
    );
  }
}
