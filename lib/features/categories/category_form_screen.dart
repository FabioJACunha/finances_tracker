import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/database.dart';
import '../../theme/app_colors.dart';
import '../../providers/services_provider.dart';

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
  static const List<IconData> _availableIcons = [
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.local_gas_station,
    Icons.home,
    Icons.directions_car,
    Icons.phone_android,
    Icons.fitness_center,
    Icons.school,
    Icons.local_hospital,
    Icons.movie,
    Icons.flight,
    Icons.hotel,
    Icons.card_giftcard,
    Icons.pets,
    Icons.build,
    Icons.electric_bolt,
    Icons.water_drop,
    Icons.wifi,
    Icons.sports_soccer,
    Icons.attach_money,
    Icons.savings,
    Icons.credit_card,
    Icons.account_balance,
    Icons.trending_up,
    Icons.work,
    Icons.business_center,
    Icons.shopping_bag,
    Icons.local_cafe,
    Icons.fastfood,
    Icons.local_pizza,
    Icons.liquor,
    Icons.cake,
  ];

  static const List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
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
      _selectedIcon = _availableIcons[0];
      _selectedColor = _availableColors[0];
      _usageType = CategoryUsageType.both;
    }
  }

  void _submit() async {
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
            isEditing
                ? 'Category updated successfully'
                : 'Category added successfully',
            style: const TextStyle(color: AppColors.green),
          ),
          backgroundColor: AppColors.bgGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showIconPicker() {
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
              "Select Icon",
              style: TextStyle(
                color: palette.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final icon = _availableIcons[index];
                  final isSelected = icon.codePoint == _selectedIcon.codePoint;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? palette.primary
                            : palette.bgTerciary,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: palette.secondary, width: 2)
                            : null,
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? palette.textDark
                            : palette.secondary,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker() {
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
              "Select Color",
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

  @override
  Widget build(BuildContext context) {
    final palette = currentPalette;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: palette.bgPrimary,
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? "Edit Category" : "Add Category",
          style: TextStyle(color: palette.textDark),
        ),
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
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(
                    labelText: "Category Name",
                  ),
                  maxLength: 255,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Please enter a category name";
                    }
                    return null;
                  },
                  onSaved: (val) => _name = val!.trim(),
                ),
                const SizedBox(height: 16),

                // Icon selector
                Text(
                  "Icon",
                  style: TextStyle(
                    color: palette.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _showIconPicker,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: palette.bgTerciary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedIcon,
                          color: palette.textDark,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Tap to change icon",
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
                const SizedBox(height: 16),

                // Color selector
                Text(
                  "Color",
                  style: TextStyle(
                    color: palette.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _showColorPicker,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: palette.bgTerciary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Tap to change color",
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
                const SizedBox(height: 16),

                // Usage type selector
                Text(
                  "Usage Type",
                  style: TextStyle(
                    color: palette.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
                          label = "Expenses Only";
                          description =
                              "Can only be used for expense transactions";
                          icon = Icons.remove_circle_outline;
                          break;
                        case CategoryUsageType.income:
                          label = "Income Only";
                          description =
                              "Can only be used for income transactions";
                          icon = Icons.add_circle_outline;
                          break;
                        case CategoryUsageType.both:
                          label = "Both";
                          description =
                              "Can be used for both income and expenses";
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
                      label: Text(isEditing ? "Save Changes" : "Add Category"),
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
