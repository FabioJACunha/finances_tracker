import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/categories_provider.dart';
import '../../data/db/database.dart';
import '../../theme/app_colors.dart';
import 'category_form_screen.dart';
import '../../widgets/custom_app_bar.dart';
import '../../l10n/app_localizations.dart'; // REQUIRED IMPORT

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!; // USE 'loc'
    final palette = currentPalette;
    final categoriesAsync = ref.watch(categoriesListProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: loc.categoriesTitle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: palette.textDark,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoryFormScreen()),
          );
        },
        backgroundColor: palette.primary,
        child: Icon(Icons.add, color: palette.textDark),
      ),
      body: SafeArea(
        child: categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 80,
                      color: palette.textDark,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.categoriesEmptyTitle,
                      style: TextStyle(color: palette.textDark, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.categoriesEmptySubtitle,
                      style: TextStyle(color: palette.textDark, fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _CategoryCard(category: category);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              loc.errorLoadingCategories(error.toString()),
              style: TextStyle(color: palette.red),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  final Category category;
  final palette = currentPalette;

  _CategoryCard({required this.category});

  String _getUsageTypeLabel(CategoryUsageType type, AppLocalizations loc) {
    switch (type) {
      case CategoryUsageType.expense:
        return loc.usageTypeExpenseLabel;
      case CategoryUsageType.income:
        return loc.usageTypeIncomeLabel;
      case CategoryUsageType.both:
        return loc.usageTypeBothLabel;
    }
  }

  Color _getUsageTypeTextColor(CategoryUsageType type) {
    switch (type) {
      case CategoryUsageType.expense:
        return palette.red;
      case CategoryUsageType.income:
        return palette.green;
      case CategoryUsageType.both:
        return palette.textMuted;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!; // USE 'loc'
    final categoryColor = Color(category.colorValue);
    final categoryIcon = IconData(
      category.iconCodePoint,
      fontFamily: 'MaterialIcons',
    );

    return Card(
      color: palette.bgTerciary,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CategoryFormScreen(categoryToEdit: category),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon with colored background
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: palette.bgPrimary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: palette.primary, width: 2),
                ),
                child: Icon(categoryIcon, color: categoryColor, size: 24),
              ),
              const SizedBox(width: 16),
              // Category info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        color: palette.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getUsageTypeLabel(category.usageType, loc), // USED 'loc'
                      style: TextStyle(
                        color: _getUsageTypeTextColor(category.usageType),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit, color: palette.textDark), // Use dynamic color
            ],
          ),
        ),
      ),
    );
  }
}
