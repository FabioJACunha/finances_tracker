import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/database.dart';
import '../../theme/app_colors.dart';
import '../../providers/services_provider.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custom_app_bar.dart';
import '../../l10n/app_localizations.dart'; // REQUIRED IMPORT

class CategoryFormScreen extends ConsumerStatefulWidget {
  final Category? categoryToEdit;

  const CategoryFormScreen({this.categoryToEdit, super.key});

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late IconData _selectedIcon;
  late Color _selectedColor;
  late CategoryUsageType _usageType;
  final palette = currentPalette;

  bool get isEditing => widget.categoryToEdit != null;

  // Popular material icons for categories
  // KEYS KEPT AS IDENTIFIERS, TRANSLATED IN _showIconPicker
  static const Map<String, List<IconData>> categorizedIcons = {
    "Essentials & Household": [
      Icons.home,
      Icons.chair,
      Icons.shopping_cart,
      Icons.cleaning_services,
      Icons.local_laundry_service,
    ],
    "Food & Drinks": [
      Icons.restaurant,
      Icons.local_cafe,
      Icons.liquor,
      Icons.icecream,
    ],
    "Transport": [
      Icons.directions_car,
      Icons.local_gas_station,
      Icons.train,
      Icons.pedal_bike,
    ],
    "Utilities & Bills": [
      Icons.electric_bolt,
      Icons.water_drop,
      Icons.wifi,
      Icons.sim_card,
      Icons.fireplace,
    ],
    "Health & Personal": [
      Icons.local_hospital,
      Icons.fitness_center,
      Icons.spa,
      Icons.brush,
    ],
    "Finance & Work": [
      Icons.attach_money,
      Icons.savings,
      Icons.credit_card,
      Icons.account_balance,
      Icons.trending_up,
      Icons.work,
      Icons.business_center,
    ],
    "Entertainment & Lifestyle": [
      Icons.movie,
      Icons.music_note,
      Icons.sports_soccer,
      Icons.videogame_asset,
      Icons.palette,
    ],
    "Shopping & Gifts": [Icons.shopping_bag, Icons.card_giftcard, Icons.watch],
    "Travel & Experiences": [Icons.flight_takeoff, Icons.hotel, Icons.luggage],
    "Family & Kids": [Icons.child_friendly, Icons.cake, Icons.pets],
    "Education & Learning": [Icons.school, Icons.menu_book],
    "Tech & Subscriptions": [
      Icons.phone_android,
      Icons.subscriptions,
      Icons.security,
    ],
  };

  static const List<Color> _availableColors = [
    Color(0xFFE57373), // Warm Soft Red
    Color(0xFFF48FB1), // Gentle Pink
    Color(0xFFCE93D8), // Soft Purple
    Color(0xFFB39DDB), // Soft Deep Purple
    Color(0xFF9FA8DA), // Soft Indigo
    Color(0xFF90CAF9), // Soft Blue
    Color(0xFF81D4FA), // Soft Light Blue
    Color(0xFF80DEEA), // Soft Cyan
    Color(0xFF80CBC4), // Soft Teal
    Color(0xFFA5D6A7), // Soft Green
    Color(0xFFC5E1A5), // Soft Light Green
    Color(0xFFE6EE9C), // Soft Lime
    Color(0xFFFFF59D), // Soft Yellow
    Color(0xFFFFE082), // Soft Amber
    Color(0xFFFFCC80), // Soft Orange
    Color(0xFFFFAB91), // Soft Deep Orange
    Color(0xFFBCAAA4), // Soft Brown
    Color(0xFFEEEEEE), // Soft Grey
    Color(0xFFB0BEC5), // Soft Blue Grey
  ];

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final category = widget.categoryToEdit!;
      _name = category.name;
      _selectedIcon = IconData(
        category.iconCodePoint,
        fontFamily: 'MaterialIcons',
      );
      _selectedColor = Color(category.colorValue);
      _usageType = category.usageType;
    } else {
      _name = '';
      _selectedIcon = Icons.question_mark_outlined;
      _selectedColor = _availableColors[0];
      _usageType = CategoryUsageType.both;
    }
  }

  void _submit() async {
    final loc = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final categoryService = ref.read(categoryServiceProvider);

      if (isEditing) {
        await categoryService.updateCategory(
          id: widget.categoryToEdit!.id,
          newName: _name,
          newIcon: _selectedIcon,
          newColor: _selectedColor,
          newUsageType: _usageType,
        );
      } else {
        await categoryService.createCategory(
          name: _name,
          icon: _selectedIcon,
          color: _selectedColor,
          usageType: _usageType,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? loc.categoryUpdatedSuccess : loc.categoryCreatedSuccess,
            style: TextStyle(color: palette.green),
          ),
          backgroundColor: palette.bgGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.errorGeneral(e.toString()),
            style: TextStyle(color: palette.red),
          ),
          backgroundColor: palette.bgRed,
        ),
      );
    }
  }

  // Helper to get localized icon group name
  String _getLocalizedIconGroupName(String groupKey, AppLocalizations loc) {
    return switch (groupKey) {
      "Essentials & Household" => loc.categoryGroupEssentials,
      "Food & Drinks" => loc.categoryGroupFood,
      "Transport" => loc.categoryGroupTransport,
      "Utilities & Bills" => loc.categoryGroupUtilities,
      "Health & Personal" => loc.categoryGroupHealth,
      "Finance & Work" => loc.categoryGroupFinance,
      "Entertainment & Lifestyle" => loc.categoryGroupEntertainment,
      "Shopping & Gifts" => loc.categoryGroupShopping,
      "Travel & Experiences" => loc.categoryGroupTravel,
      "Family & Kids" => loc.categoryGroupFamily,
      "Education & Learning" => loc.categoryGroupEducation,
      "Tech & Subscriptions" => loc.categoryGroupTech,
      _ => groupKey, // Fallback
    };
  }

  void _showIconPicker() {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.selectIconTitle,
              style: TextStyle(
                color: palette.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: categorizedIcons.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _getLocalizedIconGroupName(entry.key, loc),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: palette.textDark,
                          ),
                        ),
                      ),
                      GridView.count(
                        crossAxisCount: 6,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: entry.value.map((icon) {
                          final isSelected =
                              icon.codePoint == _selectedIcon.codePoint;

                          return InkWell(
                            onTap: () {
                              setState(() => _selectedIcon = icon);
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? palette.primary
                                    : palette.bgTerciary,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? Border.all(
                                        color: palette.secondary,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Icon(
                                icon,
                                size: 28,
                                color: isSelected
                                    ? palette.textDark
                                    : palette.secondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker() {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.selectColorTitle,
              style: TextStyle(
                color: palette.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                final isSelected =
                    color.toARGB32() == _selectedColor.toARGB32();

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: palette.textDark, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCategory() async {
    final loc = AppLocalizations.of(context)!;
    if (!mounted || widget.categoryToEdit == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.bgPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          loc.categoryDeleteTitle,
          style: TextStyle(color: palette.textDark),
        ),
        content: Text(
          loc.categoryDeleteConfirmation(widget.categoryToEdit!.name),
          style: TextStyle(color: palette.textDark),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: palette.textDark,
              backgroundColor: palette.primary,
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: palette.red,
              backgroundColor: palette.bgRed,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(loc.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final categoryService = ref.read(categoryServiceProvider);
      await categoryService.deleteCategory(widget.categoryToEdit!.id);

      if (!mounted) return;

      Navigator.of(context).pop(); // Close the form

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.categoryDeletedSuccess(widget.categoryToEdit!.name),
            style: TextStyle(color: palette.green),
          ),
          backgroundColor: palette.bgGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.errorGeneral(e.toString()),
            style: TextStyle(color: palette.red),
          ),
          backgroundColor: palette.bgRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final palette = currentPalette;

    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? loc.editCategoryTitle : loc.createCategoryTitle,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        extraActions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: palette.textMuted),
              onPressed: _deleteCategory,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 80,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name field
                CustomTextFormField(
                  initialValue: _name,
                  maxLength: 20,
                  label: loc.fieldTitle,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return loc.validationEnterTitle;
                    }
                    return null;
                  },
                  onSaved: (val) => _name = val!.trim(),
                ),
                const SizedBox(height: 16),

                // Icon and Color selectors side by side
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon selector
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.categoryIconLabel,
                            style: TextStyle(
                              color: palette.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: _showIconPicker,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: palette.bgTerciary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _selectedIcon,
                                    color: _selectedColor,
                                    size: 32,
                                  ),
                                  const Spacer(),
                                  Text(
                                    loc.actionChange,
                                    style: TextStyle(color: palette.textDark),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: palette.textDark,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Color selector
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.categoryColorLabel,
                            style: TextStyle(
                              color: palette.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: _showColorPicker,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: palette.bgTerciary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: _selectedColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    loc.actionChange,
                                    style: TextStyle(color: palette.textDark),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: palette.textDark,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Usage type selector
                Text(
                  loc.categoryUsageTypeTitle,
                  style: TextStyle(
                    color: palette.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                RadioGroup<CategoryUsageType>(
                  groupValue: _usageType,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _usageType = val;
                      });
                    }
                  },
                  child: Column(
                    children: CategoryUsageType.values.map((type) {
                      String label;
                      String description;
                      IconData icon;

                      switch (type) {
                        case CategoryUsageType.expense:
                          label = loc.usageTypeExpenseLabel;
                          description = loc.usageTypeExpenseDesc;
                          icon = Icons.remove_circle_outline;
                          break;
                        case CategoryUsageType.income:
                          label = loc.usageTypeIncomeLabel;
                          description = loc.usageTypeIncomeDesc;
                          icon = Icons.add_circle_outline;
                          break;
                        case CategoryUsageType.both:
                          label = loc.usageTypeBothLabel;
                          description = loc.usageTypeBothDesc;
                          icon = Icons.swap_horiz;
                          break;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: _usageType == type
                              ? palette.terciary
                              : palette.bgTerciary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: RadioListTile<CategoryUsageType>(
                          value: type,
                          title: Row(
                            children: [
                              Icon(
                                icon,
                                color: _usageType == type
                                    ? palette.secondary
                                    : palette.textDark,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                label,
                                style: TextStyle(
                                  color: _usageType == type
                                      ? palette.secondary
                                      : palette.textDark,
                                  fontWeight: _usageType == type
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            description,
                            style: TextStyle(
                              color: _usageType == type
                                  ? palette.secondary
                                  : palette.textDark,
                              fontSize: 12,
                            ),
                          ),
                          activeColor: palette.secondary,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: Icon(isEditing ? Icons.save : Icons.add),
                      label: Text(
                        isEditing
                            ? loc.actionSaveChanges
                            : loc.actionAddCategory,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primary,
                        foregroundColor: palette.textDark,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
