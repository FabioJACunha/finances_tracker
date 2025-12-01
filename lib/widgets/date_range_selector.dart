import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/date_range_selection.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart'; // New Import

class DateRangeSelector extends StatelessWidget {
  final DateRangeSelection currentRange;
  final ValueChanged<DateRangeSelection> onRangeChanged;
  final String? label;
  final bool showIcon;
  final bool isIconOnly;

  const DateRangeSelector({
    super.key,
    required this.currentRange,
    required this.onRangeChanged,
    this.label,
    this.showIcon = true,
    this.isIconOnly = false,
  });

  Future<void> _pickDateRange(BuildContext context) async {
    final palette = currentPalette;

    // Configuration for the calendar_date_picker2 dialog
    final config = CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.range,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      selectedDayHighlightColor: palette.secondary,
      weekdayLabelTextStyle: TextStyle(color: palette.textDark),
      dayTextStyle: TextStyle(color: palette.textDark),
      yearTextStyle: TextStyle(color: palette.textDark),
      controlsTextStyle: TextStyle(
        color: palette.textDark,
        fontWeight: FontWeight.w500,
      ),
      buttonPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      okButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: palette.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Confirm',
          style: TextStyle(
            color: palette.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      cancelButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: palette.terciary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Cancel',
          style: TextStyle(
            color: palette.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 16.0;

    // Show the new date range picker dialog
    final List<DateTime?>? pickedDates = await showCalendarDatePicker2Dialog(
      context: context,
      config: config,
      dialogSize: Size(screenWidth - (horizontalPadding * 2), 450),
      // Initial value is a list containing the start and end dates
      value: [currentRange.start, currentRange.end],
      borderRadius: BorderRadius.circular(8),
      dialogBackgroundColor: palette.bgPrimary,
    );

    // Handle the result from the picker
    if (pickedDates != null && pickedDates.length == 2) {
      final start = pickedDates.first;
      final end = pickedDates.last;

      if (start != null && end != null) {
        // IMPORTANT: Adjust the end date to be the very end of the selected day (23:59:59.999...)
        // This is a common and robust pattern to ensure all data from the final day is included.
        final inclusiveEnd = DateUtils.dateOnly(end)
            .add(const Duration(days: 1))
            .subtract(const Duration(microseconds: 1));

        onRangeChanged(
          DateRangeSelection(
            start: start,
            end: inclusiveEnd,
            type: DateRangeType.custom,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = currentPalette;

    // Icon-only mode requested
    if (isIconOnly) {
      return IconButton(
        icon: Icon(Icons.calendar_today_outlined, color: palette.textDark, size: 20),
        onPressed: () => _pickDateRange(context),
        padding: EdgeInsets.zero,
        splashRadius: 24,
      );
    }

    // Default full selector mode
    return GestureDetector(
      onTap: () => _pickDateRange(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: palette.secondary, width: 2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (label != null) ...[
                  Text(
                    label!,
                    style: TextStyle(
                      color: palette.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  '${DateFormat('d MMM y').format(currentRange.start)} - ${DateFormat('d MMM y').format(currentRange.end)}',
                  style: TextStyle(
                    color: palette.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            if (showIcon)
              Icon(Icons.calendar_today_outlined, color: palette.textDark, size: 18),
          ],
        ),
      ),
    );
  }
}