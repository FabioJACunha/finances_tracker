import 'package:flutter/material.dart';
import '../helpers/app_colors.dart';

class SelectFormField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemAsString;
  final ValueChanged<T?> onChanged;

  const SelectFormField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemAsString,
    required this.onChanged,
  });

  void _openDialog(BuildContext context) async {
    final result = await showDialog<T>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 32),
          constraints: BoxConstraints(
            maxWidth: double.infinity,
            minWidth: double.infinity,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 400, // max height for the list
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected = item == value;

                  return Material(
                    color: selected ? AppColors.terciary : AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(8),
                    child: ListTile(
                      title: Text(
                        itemAsString(item),
                        style: TextStyle(
                          color: selected ? AppColors.secondary : AppColors.textDark,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 8,
                      ),
                      onTap: () => Navigator.pop(context, item),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    if (result != null) {
      onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDialog(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
          controller: TextEditingController(
            text: value != null ? itemAsString(value as T) : "",
          ),
          readOnly: true,
          style: TextStyle(color: AppColors.textDark),
        ),
      ),
    );
  }
}
