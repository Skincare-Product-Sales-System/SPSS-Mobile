import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/consts/app_constants.dart';
import 'package:shopsmart_users_en/widgets/products/latest_arrival.dart';
import 'package:shopsmart_users_en/widgets/products/category_widget.dart';
import 'package:shopsmart_users_en/widgets/blog_section.dart';

import '../providers/products_provider.dart';
import '../providers/categories_provider.dart';
import '../services/assets_manager.dart';
import '../services/api_service.dart';
import '../widgets/app_name_text.dart';
import '../widgets/title_text.dart';
import '../screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productsProvider = Provider.of<ProductsProvider>(
        context,
        listen: false,
      );
      final categoriesProvider = Provider.of<CategoriesProvider>(
        context,
        listen: false,
      );

      // Load categories first
      if (categoriesProvider.getCategories.isEmpty) {
        categoriesProvider.loadCategories();
      }

      // Load best sellers for arrival section
      if (productsProvider.getProducts.isEmpty) {
        productsProvider.loadBestSellers(refresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.shoppingCart),
        ),
        title: const AppNameTextWidget(fontSize: 20),
        actions: [
          Consumer<ProductsProvider>(
            builder: (context, productsProvider, child) {
              if (productsProvider.errorMessage != null) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed:
                      () => productsProvider.loadBestSellers(refresh: true),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ProductsProvider>(
        builder: (context, productsProvider, child) {
          if (productsProvider.isLoading &&
              productsProvider.getProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productsProvider.errorMessage != null &&
              productsProvider.getProducts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Connection Error',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${productsProvider.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Troubleshooting:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text('• Make sure your API server is running'),
                          Text(
                            '• Check if http://localhost:5041/api/products works in browser',
                          ),
                          Text(
                            '• For Android emulator: API should be accessible at 10.0.2.2:5041',
                          ),
                          Text('• Check console for detailed error logs'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          () => productsProvider.loadBestSellers(refresh: true),
                      child: const Text('Retry Connection'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () async {
                        // Test API connection
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Testing API connection...'),
                          ),
                        );

                        final testResult = await ApiService.testConnection();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(testResult.message),
                              backgroundColor:
                                  testResult.success
                                      ? Colors.green
                                      : Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      child: const Text('Test API Connection'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final categoriesProvider = Provider.of<CategoriesProvider>(
                context,
                listen: false,
              );
              await Future.wait([
                categoriesProvider.refreshCategories(),
                productsProvider.loadBestSellers(refresh: true),
              ]);
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),

                  // Banner Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      height: size.height * 0.25,
                      child: ClipRRect(
                        child: Swiper(
                          autoplay: true,
                          itemBuilder: (BuildContext context, int index) {
                            return Image.asset(
                              AppConstants.bannersImage[index],
                              fit: BoxFit.fill,
                            );
                          },
                          itemCount: AppConstants.bannersImage.length,
                          pagination: const SwiperPagination(
                            builder: DotSwiperPaginationBuilder(
                              activeColor: Colors.red,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Categories Section (moved to top)
                  const CategorySection(),
                  const SizedBox(height: 20),

                  // Best Sellers section (moved below categories)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TitlesTextWidget(label: "Best Sellers"),
                        if (productsProvider.getProducts.isNotEmpty)
                          Text(
                            '${productsProvider.getProducts.length > 10 ? 10 : productsProvider.getProducts.length} products',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15.0),

                  if (productsProvider.getProducts.isEmpty)
                    SizedBox(
                      height: size.height * 0.25,
                      child: const Center(child: Text('No products available')),
                    )
                  else
                    SizedBox(
                      height: size.height * 0.25,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            productsProvider.getProducts.length > 10
                                ? 10
                                : productsProvider.getProducts.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: size.width * 0.45,
                            child: ChangeNotifierProvider.value(
                              value: productsProvider.getProducts[index],
                              child: const LatestArrivalProductsWidget(),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 20.0),

                  // All Products Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TitlesTextWidget(label: "All Products"),
                        Row(
                          children: [
                            if (productsProvider.getProducts.isNotEmpty)
                              Text(
                                '${productsProvider.getProducts.length > 10 ? 10 : productsProvider.getProducts.length} of ${productsProvider.totalCount}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  SearchScreen.routeName,
                                  arguments: "All",
                                );
                              },
                              child: const Text(
                                'See All',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15.0),

                  if (productsProvider.getProducts.isEmpty)
                    SizedBox(
                      height: size.height * 0.3,
                      child: const Center(child: Text('No products available')),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.85,
                            ),
                        itemCount:
                            productsProvider.getProducts.length > 10
                                ? 10
                                : productsProvider.getProducts.length,
                        itemBuilder: (context, index) {
                          return ChangeNotifierProvider.value(
                            value: productsProvider.getProducts[index],
                            child: const LatestArrivalProductsWidget(),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 20.0),

                  // Blog Section
                  const BlogSection(),

                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
