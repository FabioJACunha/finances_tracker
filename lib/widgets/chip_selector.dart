import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ChipSelector<T> extends FormField<dynamic> {
  final String label;
  final List<T> items;
  final String Function(T item) labelBuilder;

  /// Optional item that, if selected, represents a 'Global' or 'Select All' state.
  /// When selected, the onChanged/onMultiChanged will be called with null.
  final T? globalItem;

  /// Show "Add new" button (only Category uses this)
  final bool allowAddNew;
  final VoidCallback? onAddNew;

  /// Optional: function to get the color from the item (only needed if using category color)
  final Color Function(T item)? getItemColor;

  /// Optional: function to get the icon from the item
  final IconData Function(T item)? getItemIcon;

  /// Enable multi-selection mode
  final bool multiSelect;

  // Single selection
  ChipSelector({
    super.key,
    required this.label,
    required this.items,
    required this.labelBuilder,
    this.globalItem, // Added
    T? initialValue,
    ValueChanged<T?>? onChanged, // Changed to allow T? (null for global)
    this.allowAddNew = false,
    this.onAddNew,
    this.getItemColor,
    this.getItemIcon,
    super.validator,
    super.onSaved,
  }) : multiSelect = false,
        super(
        // Adjust initialValue if it's the global item to be treated as null externally
        initialValue: initialValue == globalItem ? null : initialValue,
        builder: (FormFieldState<dynamic> state) {
          final palette = currentPalette;
          // The item currently held by the state. This will be T or null.
          final T? currentStateValue = state.value as T?;

          // List of all items including the global one at the start
          final allItems = [
            if (globalItem != null) globalItem,
            ...items,
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: palette.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (allowAddNew && onAddNew != null)
                    TextButton.icon(
                      onPressed: onAddNew,
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text(
                        "Add New",
                        style: TextStyle(fontSize: 13),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: palette.secondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: allItems.map((item) {
                    // Check if the current item is selected.
                    // A null state value means the globalItem is selected.
                    final bool isSelected = (item == currentStateValue) ||
                        (item == globalItem && currentStateValue == null);

                    final Color? itemColor = getItemColor?.call(item);
                    final IconData? itemIcon = getItemIcon?.call(item);

                    final Color borderColor = isSelected
                        ? (itemColor ?? palette.secondary)
                        : palette.bgTerciary;
                    final Color bgColor = isSelected
                        ? palette.terciary
                        : palette.bgTerciary;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          // If the global item is tapped, set state to null and notify with null.
                          final valueToSet = item == globalItem ? null : item;
                          state.didChange(valueToSet);
                          onChanged?.call(valueToSet);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
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
                                  color: itemColor ?? palette.textDark,
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
                                      ? (itemColor ?? palette.secondary)
                                      : palette.textDark,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // SizedBox(
              //   height: 20,
              //   child: state.hasError
              //       ? Padding(
              //     padding: EdgeInsets.only(top: 4),
              //     child: Text(
              //       state.errorText!,
              //       style: const TextStyle(
              //         color: AppColors.red,
              //         fontSize: 12,
              //       ),
              //     ),
              //   )
              //       : null,
              // ),
            ],
          );
        },
      );

  // Multi selection constructor
  ChipSelector.multi({
    super.key,
    required this.label,
    required this.items,
    required this.labelBuilder,
    this.globalItem, // Added
    List<T>? selectedValues,
    ValueChanged<List<T>?>? onMultiChanged, // Changed to allow List<T>? (null for global)
    this.allowAddNew = false,
    this.onAddNew,
    this.getItemColor,
    this.getItemIcon,
    FormFieldValidator<List<T>?>? validator, // Changed to allow List<T>?
    FormFieldSetter<List<T>?>? onSaved, // Changed to allow List<T>?
  }) : multiSelect = true,
        super(
        // If selectedValues is empty, it means 'Global' is selected externally, so use null
        initialValue: (selectedValues == null || selectedValues.isEmpty) ? null : selectedValues,
        validator: validator != null
            ? (value) => validator(value as List<T>?)
            : null,
        onSaved: onSaved != null ? (value) => onSaved(value as List<T>?) : null,
        builder: (FormFieldState<dynamic> state) {
          final palette = currentPalette;
          // currentValues is List<T> or null
          final List<T> currentValues = state.value is List ? state.value as List<T> : [];
          final bool isGlobalSelected = state.value == null || currentValues.isEmpty;

          // List of all items including the global one at the start
          final allItems = [
            if (globalItem != null) globalItem,
            ...items,
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: palette.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (allowAddNew && onAddNew != null)
                    TextButton.icon(
                      onPressed: onAddNew,
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text(
                        "Add New",
                        style: TextStyle(fontSize: 13),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: palette.secondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: allItems.map((item) {
                    // Check if the current item is selected
                    final bool isSelected = (item == globalItem && isGlobalSelected) ||
                        (item != globalItem && currentValues.contains(item));

                    final Color? itemColor = getItemColor?.call(item);
                    final IconData? itemIcon = getItemIcon?.call(item);

                    final Color borderColor = isSelected
                        ? (itemColor ?? palette.secondary)
                        : palette.bgTerciary;
                    final Color bgColor = isSelected
                        ? palette.terciary
                        : palette.bgTerciary;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          List<T>? newValues;

                          if (item == globalItem) {
                            // Global item tapped:
                            // If currently selected (global or others), unselect everything (set to null)
                            // If currently unselected, select it (set to null)
                            // The goal is to toggle between global (null) and non-global (List<T>)
                            newValues = isGlobalSelected ? [] : null; // null = Global, [] = no categories selected
                          } else {
                            // A specific item tapped:
                            final specificValues = List<T>.from(currentValues);
                            if (specificValues.contains(item)) {
                              // Item is selected, unselect it
                              specificValues.remove(item);
                            } else {
                              // Item is unselected, select it
                              specificValues.add(item);
                            }

                            if (specificValues.isEmpty) {
                              // If the list becomes empty, treat it as selecting Global (null)
                              newValues = null;
                            } else {
                              // Specific selection
                              newValues = specificValues;
                            }
                          }

                          state.didChange(newValues);
                          onMultiChanged?.call(newValues);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
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
                                  color: itemColor ?? palette.textDark,
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
                                      ? (itemColor ?? palette.secondary)
                                      : palette.textDark,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // SizedBox(
              //   height: 20,
              //   child: state.hasError
              //       ? Text(
              //     state.errorText!,
              //     style: const TextStyle(
              //       color: AppColors.red,
              //       fontSize: 12,
              //     ),
              //   )
              //       : null,
              // ),
            ],
          );
        },
      );
}