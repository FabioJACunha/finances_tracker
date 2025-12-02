import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

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

  /// Hide the label text above the chips
  final bool hideLabel;

  final bool secondaryBg;

  // Single selection
  ChipSelector({
    super.key,
    required this.label,
    required this.items,
    required this.labelBuilder,
    this.globalItem,
    T? initialValue,
    ValueChanged<T?>? onChanged,
    this.allowAddNew = false,
    this.onAddNew,
    this.getItemColor,
    this.getItemIcon,
    this.hideLabel = false,
    this.secondaryBg = false,
    super.validator,
    super.onSaved,
  }) : multiSelect = false,
       super(
         initialValue: initialValue == globalItem ? null : initialValue,
         builder: (FormFieldState<dynamic> state) {
           final palette = currentPalette;
           final T? currentStateValue = state.value as T?;
           final loc = AppLocalizations.of(state.context)!;

           final allItems = [if (globalItem != null) globalItem, ...items];

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               if (!hideLabel)
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
                         label: Text(
                           loc.buttonAddNew,
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
               if (!hideLabel) const SizedBox(height: 4),
               SingleChildScrollView(
                 scrollDirection: Axis.horizontal,
                 child: Row(
                   children: allItems.map((item) {
                     final bool isSelected =
                         (item == currentStateValue) ||
                         (item == globalItem && currentStateValue == null);

                     final Color? itemColor = getItemColor?.call(item);
                     final IconData? itemIcon = getItemIcon?.call(item);

                     final Color bgColor = isSelected
                         ? palette.terciary
                         : (secondaryBg
                               ? palette.bgPrimary
                               : palette.bgTerciary);

                     return Padding(
                       padding: const EdgeInsets.only(right: 8),
                       child: InkWell(
                         borderRadius: BorderRadius.circular(20),
                         onTap: () {
                           final valueToSet = item == globalItem ? null : item;
                           state.didChange(valueToSet);
                           onChanged?.call(valueToSet);
                         },
                         child: Container(
                           padding: const EdgeInsets.symmetric(
                             horizontal: 16,
                             vertical: 10,
                           ),
                           decoration: BoxDecoration(
                             color: bgColor,
                             borderRadius: BorderRadius.circular(20),
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               if (itemIcon != null) ...[
                                 Icon(
                                   itemIcon,
                                   size: 16,
                                   color: itemColor ?? palette.textDark,
                                 ),
                                 const SizedBox(width: 6),
                               ],
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
    this.globalItem,
    List<T>? selectedValues,
    ValueChanged<List<T>?>? onMultiChanged,
    this.allowAddNew = false,
    this.onAddNew,
    this.getItemColor,
    this.getItemIcon,
    this.hideLabel = false,
    this.secondaryBg = false,
    FormFieldValidator<List<T>?>? validator,
    FormFieldSetter<List<T>?>? onSaved,
  }) : multiSelect = true,
       super(
         initialValue: (selectedValues == null || selectedValues.isEmpty)
             ? null
             : selectedValues,
         validator: validator != null
             ? (value) => validator(value as List<T>?)
             : null,
         onSaved: onSaved != null
             ? (value) => onSaved(value as List<T>?)
             : null,
         builder: (FormFieldState<dynamic> state) {
           final palette = currentPalette;
           final List<T> currentValues = state.value is List
               ? state.value as List<T>
               : [];
           final bool isGlobalSelected =
               state.value == null || currentValues.isEmpty;
           final loc = AppLocalizations.of(state.context)!;
           final allItems = [if (globalItem != null) globalItem, ...items];

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               if (!hideLabel)
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
                         label: Text(
                           loc.buttonAddNew,
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
               if (!hideLabel) const SizedBox(height: 4),
               SingleChildScrollView(
                 scrollDirection: Axis.horizontal,
                 child: Row(
                   children: allItems.map((item) {
                     final bool isSelected =
                         (item == globalItem && isGlobalSelected) ||
                         (item != globalItem && currentValues.contains(item));

                     final Color? itemColor = getItemColor?.call(item);
                     final IconData? itemIcon = getItemIcon?.call(item);

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
                             newValues = isGlobalSelected ? [] : null;
                           } else {
                             final specificValues = List<T>.from(currentValues);
                             if (specificValues.contains(item)) {
                               specificValues.remove(item);
                             } else {
                               specificValues.add(item);
                             }

                             if (specificValues.isEmpty) {
                               newValues = null;
                             } else {
                               newValues = specificValues;
                             }
                           }

                           state.didChange(newValues);
                           onMultiChanged?.call(newValues);
                         },
                         child: Container(
                           padding: const EdgeInsets.symmetric(
                             horizontal: 16,
                             vertical: 10,
                           ),
                           decoration: BoxDecoration(
                             color: bgColor,
                             borderRadius: BorderRadius.circular(20),
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               if (itemIcon != null) ...[
                                 Icon(
                                   itemIcon,
                                   size: 16,
                                   color: itemColor ?? palette.textDark,
                                 ),
                                 const SizedBox(width: 6),
                               ],
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
             ],
           );
         },
       );
}
