import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ChipSelector<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? selectedValue;
  final String Function(T item) labelBuilder;
  final ValueChanged<T> onChanged;

  /// Show "Add new" button (only Category uses this)
  final bool allowAddNew;
  final VoidCallback? onAddNew;

  /// Optional: function to get the color from the item (only needed if using category color)
  final Color Function(T item)? getItemColor;

  const ChipSelector({
    super.key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.labelBuilder,
    required this.onChanged,
    this.allowAddNew = false,
    this.onAddNew,
    this.getItemColor,
  });

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
          child: Row(
            children: items.map((item) {
              final bool isSelected = item == selectedValue;
              final Color borderColor = isSelected
                  ? (getItemColor != null
                  ? getItemColor!(item)
                  : AppColors.terciary)
                  : AppColors.bgTerciary;
              final Color bgColor = isSelected
                  ? (getItemColor != null
                  ? AppColors.bgTerciary
                  : AppColors.terciary)
                  : AppColors.bgTerciary;

              return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onChanged(item),
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
                      child: Text(
                        labelBuilder(item),
                        style: TextStyle(
                          color: isSelected ? (getItemColor != null
                              ? getItemColor!(item) : AppColors.secondary) : AppColors.textDark,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          ),
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
