import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ChipSelector<T> extends StatelessWidget {
  final String label;
  final List<T> items;

  // Single selection
  final T? selectedValue;
  final ValueChanged<T>? onChanged;

  // Multi selection
  final List<T>? selectedValues;
  final ValueChanged<List<T>>? onMultiChanged;

  final String Function(T item) labelBuilder;

  /// Show "Add new" button (only Category uses this)
  final bool allowAddNew;
  final VoidCallback? onAddNew;

  /// Optional: function to get the color from the item (only needed if using category color)
  final Color Function(T item)? getItemColor;

  /// Optional: function to get the icon from the item
  final IconData Function(T item)? getItemIcon;

  /// Enable multi-selection mode
  final bool multiSelect;

  const ChipSelector({
    super.key,
    required this.label,
    required this.items,
    required this.labelBuilder,
    this.selectedValue,
    this.onChanged,
    this.selectedValues,
    this.onMultiChanged,
    this.allowAddNew = false,
    this.onAddNew,
    this.getItemColor,
    this.getItemIcon,
    this.multiSelect = false,
  }) : assert(
         // Multi-select requires all three parameters
         (multiSelect && selectedValues != null && onMultiChanged != null) ||
             // Single-select only requires onChanged (selectedValue is optional as T?)
             (!multiSelect && onChanged != null),
         'Must provide either (multiSelect=true + selectedValues + onMultiChanged) or (onChanged)',
       );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (allowAddNew && onAddNew != null)
                TextButton.icon(
                  onPressed: onAddNew,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text("Add New", style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.secondary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: items.map((item) {
              final bool isSelected = multiSelect
                  ? (selectedValues?.contains(item) ?? false)
                  : (item == selectedValue);

              final Color? itemColor = getItemColor?.call(item);
              final IconData? itemIcon = getItemIcon?.call(item);

              final Color borderColor = isSelected
                  ? (itemColor ?? AppColors.secondary)
                  : AppColors.bgTerciary;
              final Color bgColor = isSelected
                  ? (itemColor ?? AppColors.terciary)
                  : AppColors.bgTerciary;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (multiSelect) {
                      final currentSelected = List<T>.from(
                        selectedValues ?? [],
                      );
                      if (currentSelected.contains(item)) {
                        currentSelected.remove(item);
                      } else {
                        currentSelected.add(item);
                      }
                      onMultiChanged?.call(currentSelected);
                    } else {
                      onChanged?.call(item);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(width: 2, color: borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Optional icon
                        if (itemIcon != null) ...[
                          Icon(
                            itemIcon,
                            size: 16,
                            color: isSelected
                                ? (itemColor ?? AppColors.secondary)
                                : AppColors.textDark,
                          ),
                          const SizedBox(width: 6),
                        ],
                        // Optional color indicator
                        if (itemColor != null && itemIcon == null) ...[
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: itemColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        // Label
                        Text(
                          labelBuilder(item),
                          style: TextStyle(
                            color: isSelected
                                ? (itemColor ?? AppColors.secondary)
                                : AppColors.textDark,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        // Checkmark for multi-select
                        if (multiSelect && isSelected) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: itemColor ?? AppColors.secondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
