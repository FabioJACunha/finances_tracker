import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../l10n/app_localizations.dart'; // Import localization

class CustomTextFormField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final TextEditingController? controller;
  final TextStyle? style;
  final int? maxLength;
  final InputDecoration? decoration;

  const CustomTextFormField({
    super.key,
    required this.label,
    this.initialValue,
    this.validator,
    this.onSaved,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.controller,
    this.style,
    this.maxLength,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final palette = currentPalette;
    final loc = AppLocalizations.of(context)!; // Get localization

    // Determine the default hint text using localization
    final String defaultHintText = loc.fieldEnter(label.toLowerCase());

    // Default minimal-height decoration
    final defaultDecoration = InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.zero,
      border: const UnderlineInputBorder(),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: palette.terciary),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: palette.secondary, width: 2),
      ),
      hintStyle: TextStyle(color: palette.textMuted),
    );

    // Merge user decoration with defaults
    final mergedDecoration = defaultDecoration.copyWith(
      // Use the provided hintText, or the localized default if none is provided
      hintText: decoration?.hintText ?? defaultHintText,
      hintStyle: decoration?.hintStyle ?? defaultDecoration.hintStyle,
      helperText: decoration?.helperText,
      helperStyle: decoration?.helperStyle,
      helperMaxLines: decoration?.helperMaxLines,
      prefixIcon: decoration?.prefixIcon,
      suffixIcon: decoration?.suffixIcon,
      enabledBorder:
          decoration?.enabledBorder ?? defaultDecoration.enabledBorder,
      focusedBorder:
          decoration?.focusedBorder ?? defaultDecoration.focusedBorder,
      contentPadding:
          decoration?.contentPadding ?? defaultDecoration.contentPadding,
      isDense: decoration?.isDense ?? defaultDecoration.isDense,
      fillColor: decoration?.fillColor ?? defaultDecoration.fillColor,
      filled: decoration?.filled ?? defaultDecoration.filled,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          // Assumed to be already localized by the caller (e.g., loc.fieldTitle)
          style: TextStyle(
            color: palette.textDark,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: initialValue,
          validator: validator,
          onSaved: onSaved,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          controller: controller,
          style: style ?? TextStyle(color: palette.textDark),
          maxLength: maxLength,
          decoration: mergedDecoration,
          textAlignVertical: TextAlignVertical.bottom,
        ),
      ],
    );
  }
}
