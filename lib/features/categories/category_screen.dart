import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/categories_provider.dart';
import '../../data/db/database.dart';
import '../../data/db/tables.dart';
import '../../theme/app_colors.dart';
import 'category_form_screen.dart';
import '../../widgets/custom_app_bar.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesListProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Categories',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textDark,
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
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textDark),
      ),
      body: SafeArea(
        child: categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 80,
                      color: AppColors.textDark,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No categories yet",
                      style: TextStyle(color: AppColors.textDark, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tap + to add your first category",
                      style: TextStyle(color: AppColors.textDark, fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
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
              "Error loading categories: $error",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  final Category category;

  const _CategoryCard({required this.category});

  String _getUsageTypeLabel(CategoryUsageType type) {
    switch (type) {
      case CategoryUsageType.expense:
        return "Expenses only";
      case CategoryUsageType.income:
        return "Income only";
      case CategoryUsageType.both:
        return "Both";
    }
  }

  Color _getUsageTypeColor(CategoryUsageType type) {
    switch (type) {
      case CategoryUsageType.expense:
        return Colors.red.shade100;
      case CategoryUsageType.income:
        return Colors.green.shade100;
      case CategoryUsageType.both:
        return Colors.blue.shade100;
    }
  }

  Color _getUsageTypeTextColor(CategoryUsageType type) {
    switch (type) {
      case CategoryUsageType.expense:
        return Colors.red.shade900;
      case CategoryUsageType.income:
        return Colors.green.shade900;
      case CategoryUsageType.both:
        return Colors.blue.shade900;
    }
  }

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          "Delete Category",
          style: TextStyle(color: AppColors.textDark),
        ),
        content: Text(
          "Are you sure you want to delete '${category.name}'? "
          "This action cannot be undone if the category has no transactions.",
          style: const TextStyle(color: AppColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.textDark),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final categoryService = ref.read(categoryServiceProvider);
      await categoryService.deleteCategory(category.id);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Category "${category.name}" deleted successfully',
            style: const TextStyle(color: AppColors.green),
          ),
          backgroundColor: AppColors.bgGreen,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryColor = Color(category.colorValue);
    final categoryIcon = IconData(
      category.iconCodePoint,
      fontFamily: 'MaterialIcons',
    );

    return Card(
      color: AppColors.bgTerciary,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(categoryIcon, color: categoryColor, size: 28),
              ),
              const SizedBox(width: 16),
              // Category info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getUsageTypeColor(category.usageType),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getUsageTypeLabel(category.usageType),
                        style: TextStyle(
                          color: _getUsageTypeTextColor(category.usageType),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textDark),
                color: AppColors.bgPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoryFormScreen(categoryToEdit: category),
                      ),
                    );
                  } else if (value == 'delete') {
                    _deleteCategory(context, ref);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: AppColors.textDark, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Edit',
                          style: TextStyle(color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
