import 'dart:math' as math;

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../consts/app_constants.dart';
import '../providers/enhanced_home_view_model.dart';
import '../providers/home_state.dart';
import '../screens/mvvm_screen_template.dart';
import '../screens/simple_search_screen.dart';
import '../services/api_service.dart';
import '../services/assets_manager.dart';
import '../widgets/app_name_text.dart';
import '../widgets/blog_section.dart';
import '../widgets/products/latest_arrival.dart';
import '../widgets/title_text.dart';

/// Màn hình Home cải tiến sử dụng kiến trúc MVVM
class EnhancedHomeScreen extends StatelessWidget {
  const EnhancedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MvvmScreenTemplate<EnhancedHomeViewModel, HomeState>(
      title: 'Trang chủ',
      onInit: (viewModel) => viewModel.initializeHomeData(),
      isLoading:
          (viewModel) => viewModel.isLoading && viewModel.bestSellers.isEmpty,
      isEmpty:
          (viewModel) =>
              viewModel.bestSellers.isEmpty &&
              !viewModel.isLoading &&
              !viewModel.hasError,
      getErrorMessage: (viewModel) => viewModel.errorMessage,
      onRefresh: (viewModel) => viewModel.refreshAllData(),
      buildAppBar: (context, viewModel) => _buildAppBar(context, viewModel),
      buildContent: (context, viewModel) => _buildContent(context, viewModel),
      buildError:
          (context, viewModel, errorMessage) =>
              _buildError(context, viewModel, errorMessage),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    EnhancedHomeViewModel viewModel,
  ) {
    return AppBar(
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
        if (viewModel.hasError)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.refreshAllData(),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, EnhancedHomeViewModel viewModel) {
    Size size = MediaQuery.of(context).size;

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshAllData(),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, size: 40),
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

            // // Categories Section
            // _buildCategorySection(context, viewModel),
            // const SizedBox(height: 20),

            // Best Sellers section
            _buildBestSellersSection(context, viewModel),
            const SizedBox(height: 15.0),

            // Best Sellers Products
            _buildBestSellersProducts(context, viewModel, size),

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

            // All Products Grid
            _buildAllProductsGrid(context, viewModel, size),

            const SizedBox(height: 20.0),

            // Blog Section
            const BlogSection(),

            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildBestSellersSection(
    BuildContext context,
    EnhancedHomeViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const TitlesTextWidget(label: "Bán Chạy Nhất"),
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
    );
  }

  Widget _buildBestSellersProducts(
    BuildContext context,
    EnhancedHomeViewModel viewModel,
    Size size,
  ) {
    if (viewModel.isLoadingBestSellers && viewModel.bestSellers.isEmpty) {
      return SizedBox(
        height: 200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.bestSellers.isEmpty) {
      return SizedBox(
        height: size.height * 0.25,
        child: const Center(child: Text('Không có sản phẩm')),
      );
    }

    return SizedBox(
      height: 330,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        scrollDirection: Axis.horizontal,
        itemCount:
            viewModel.bestSellers.length > 10
                ? 10
                : viewModel.bestSellers.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              width: 200,
              child: ChangeNotifierProvider.value(
                value: viewModel.bestSellers[index],
                child: const LatestArrivalProductsWidget(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllProductsGrid(
    BuildContext context,
    EnhancedHomeViewModel viewModel,
    Size size,
  ) {
    if (viewModel.isLoadingBestSellers && viewModel.bestSellers.isEmpty) {
      return SizedBox(
        height: 200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.bestSellers.isEmpty) {
      return SizedBox(
        height: size.height * 0.3,
        child: const Center(child: Text('Không có sản phẩm')),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 15,
          childAspectRatio: 0.65,
        ),
        itemCount:
            viewModel.bestSellers.length > 10
                ? 10
                : viewModel.bestSellers.length,
        itemBuilder: (context, index) {
          return ChangeNotifierProvider.value(
            value: viewModel.bestSellers[index],
            child: const LatestArrivalProductsWidget(),
          );
        },
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    EnhancedHomeViewModel viewModel,
    String? errorMessage,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Lỗi Kết Nối',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Đã xảy ra lỗi không xác định',
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
              child: const Column(
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
              onPressed: () => viewModel.refreshAllData(),
              child: const Text('Thử Kết Nối Lại'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                // Test API connection
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang kiểm tra kết nối API...')),
                );

                final testResult = await ApiService.testConnection();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        testResult.message ?? 'Kết nối API không thành công',
                      ),
                      backgroundColor:
                          testResult.success ? Colors.green : Colors.red,
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
}
