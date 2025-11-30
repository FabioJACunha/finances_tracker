import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

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
        style: TextStyle(color: currentPalette.textDark), // Use dynamic text color
      ),
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: palette.primary, // Use primary color for the swatch
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: currentPalette.textDark) // Use textDark for the checkmark
          : null,
      onTap: () => _selectPalette(palette),
      tileColor: isSelected ? currentPalette.bgTerciary : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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

        return Scaffold(
          appBar: CustomAppBar(
            title: 'Preferences',
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
                  "Color Theme",
                  style: TextStyle(fontSize: 22, color: palette.textDark),
                ),
                const SizedBox(height: 12),
                // Map over the list of available palettes to build the tiles
                ...availablePalettes.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildPaletteTile(p),
                )),

                // You can add other preferences here later
              ],
            ),
          ),
        );
      },
    );
  }
}