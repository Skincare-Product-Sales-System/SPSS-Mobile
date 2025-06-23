import 'dart:math' as math;

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users_en/consts/app_constants.dart';
import 'package:shopsmart_users_en/widgets/products/latest_arrival.dart';
import 'package:shopsmart_users_en/widgets/products/category_widget.dart';
import 'package:shopsmart_users_en/widgets/blog_section.dart';
import 'package:shopsmart_users_en/screens/simple_search_screen.dart';

import '../providers/products_provider.dart';
import '../providers/categories_provider.dart';
import '../services/assets_manager.dart';
import '../services/api_service.dart';
import '../widgets/app_name_text.dart';
import '../widgets/title_text.dart';

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
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, SimpleSearchScreen.routeName);
            },
          ),
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
                      'Lỗi Kết Nối',
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
                            'Khắc phục sự cố:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text('• Đảm bảo máy chủ API đang chạy'),
                          Text(
                            '• Kiểm tra xem http://localhost:5041/api/products hoạt động trong trình duyệt',
                          ),
                          Text(
                            '• Đối với máy ảo Android: API nên được truy cập tại 10.0.2.2:5041',
                          ),
                          Text(
                            '• Kiểm tra bảng điều khiển để biết nhật ký lỗi chi tiết',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          () => productsProvider.loadBestSellers(refresh: true),
                      child: const Text('Thử Kết Nối Lại'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () async {
                        // Test API connection
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đang kiểm tra kết nối API...'),
                          ),
                        );

                        final testResult = await ApiService.testConnection();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                testResult.message ??
                                    'Kết nối API không thành công',
                              ),
                              backgroundColor:
                                  testResult.success
                                      ? Colors.green
                                      : Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      child: const Text('Kiểm Tra Kết Nối API'),
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
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          size: 40,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Lỗi: ${error.toString().substring(0, math.min(error.toString().length, 50))}',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
                  Consumer<CategoriesProvider>(
                    builder: (context, categoriesProvider, child) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TitlesTextWidget(
                              label:
                                  categoriesProvider.selectedCategoryId != null
                                      ? "Sản phẩm trong ${categoriesProvider.getSelectedCategoryName()}"
                                      : "Bán Chạy Nhất",
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  SimpleSearchScreen.routeName,
                                  arguments:
                                      categoriesProvider.selectedCategoryId !=
                                              null
                                          ? categoriesProvider
                                              .getSelectedCategoryName()
                                          : "Tất Cả",
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
                      );
                    },
                  ),
                  const SizedBox(height: 15.0),

                  if (productsProvider.getProducts.isEmpty)
                    SizedBox(
                      height: size.height * 0.25,
                      child: const Center(child: Text('Không có sản phẩm')),
                    )
                  else
                    SizedBox(
                      height: 330,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            productsProvider.getProducts.length > 10
                                ? 10
                                : productsProvider.getProducts.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: SizedBox(
                              width: 200,
                              child: ChangeNotifierProvider.value(
                                value: productsProvider.getProducts[index],
                                child: const LatestArrivalProductsWidget(),
                              ),
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
                        const TitlesTextWidget(label: "Tất Cả Sản Phẩm"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              SimpleSearchScreen.routeName,
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
                  const SizedBox(height: 15.0),

                  if (productsProvider.getProducts.isEmpty)
                    SizedBox(
                      height: size.height * 0.3,
                      child: const Center(child: Text('Không có sản phẩm')),
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
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 15,
                              childAspectRatio: 0.65,
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
