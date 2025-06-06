import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../providers/categories_provider.dart';
import '../../providers/products_provider.dart';
import '../../screens/search_screen.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final bool? navigateToSearch; // Optional parameter to control navigation

  const CategoryWidget({
    super.key,
    required this.category,
    this.isSelected = false,
    this.navigateToSearch,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final categoriesProvider = Provider.of<CategoriesProvider>(
          context,
          listen: false,
        );
        final productsProvider = Provider.of<ProductsProvider>(
          context,
          listen: false,
        );

        // Toggle selection
        if (isSelected) {
          categoriesProvider.clearSelection();
          // Load all products when no category is selected
          productsProvider.loadProducts(refresh: true);
        } else {
          categoriesProvider.selectCategory(category.id);

          // Only load products if category has an ID
          if (category.id.isNotEmpty) {
            // Load products for this category
            productsProvider.loadProductsByCategory(
              categoryId: category.id,
              refresh: true,
            );
          } else {
            // This is the "All" category
            productsProvider.loadProducts(refresh: true);
          }
        }

        // Navigate to search screen only if navigateToSearch is true
        if (navigateToSearch == true) {
          Navigator.pushNamed(
            context,
            SearchScreen.routeName,
            arguments: isSelected ? "Tất Cả" : category.categoryName,
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                      Theme.of(context).primaryColor.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : LinearGradient(
                    colors: [
                      Theme.of(context).cardColor,
                      Theme.of(context).cardColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.8)
                    : Theme.of(context).dividerColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.25)
                      : Theme.of(context).shadowColor.withOpacity(0.1),
              spreadRadius: isSelected ? 2 : 1,
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 3 : 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(right: 6),
                child: Icon(Icons.check_circle, size: 16, color: Colors.white),
              ),
            Text(
              category.categoryName,
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  final bool? navigateToSearch; // Optional parameter for navigation

  const CategorySection({super.key, this.navigateToSearch});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriesProvider>(
      builder: (context, categoriesProvider, child) {
        if (categoriesProvider.isLoading) {
          return SizedBox(
            height: 45,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (categoriesProvider.errorMessage != null) {
          return SizedBox(
            height: 45,
            child: Center(
              child: Text(
                'Error loading categories',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        }

        if (categoriesProvider.getMainCategories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Danh Mục",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (navigateToSearch != true)
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          SearchScreen.routeName,
                          arguments: "Tất Cả",
                        );
                      },
                      child: Text(
                        'Xem Tất Cả',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount:
                    categoriesProvider.getMainCategories.length +
                    1, // +1 for "All" option
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // "All Categories" option
                    return CategoryWidget(
                      category: CategoryModel(
                        id: '',
                        categoryName: 'Tất Cả',
                        children: [],
                      ),
                      isSelected: categoriesProvider.selectedCategoryId == null,
                      navigateToSearch: navigateToSearch,
                    );
                  }

                  final category =
                      categoriesProvider.getMainCategories[index - 1];
                  return CategoryWidget(
                    category: category,
                    isSelected:
                        categoriesProvider.selectedCategoryId == category.id,
                    navigateToSearch: navigateToSearch,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
