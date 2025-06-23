import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_cart_view_model.dart';
import '../providers/enhanced_profile_view_model.dart';
import '../providers/profile_state.dart';
import '../providers/theme_provider.dart';
import '../screens/auth/enhanced_change_password.dart';
import '../screens/auth/enhanced_login.dart';
import '../screens/inner_screen/enhanced_viewed_recently.dart';
import '../screens/inner_screen/enhanced_wishlist.dart';
import '../screens/mvvm_screen_template.dart';
import '../screens/orders/enhanced_orders_screen.dart';
import '../screens/profile/enhanced_address_screen.dart';
import '../screens/profile/enhanced_edit_profile_screen.dart';
import '../screens/skin_analysis/enhanced_skin_analysis_history_screen.dart';
import '../screens/user_reviews_screen.dart';
import '../services/assets_manager.dart';
import '../services/my_app_function.dart';
import '../widgets/app_name_text.dart';
import '../widgets/subtitle_text.dart';
import '../widgets/title_text.dart';

/// Màn hình Profile cải tiến sử dụng kiến trúc MVVM
class EnhancedProfileScreen extends StatefulWidget {
  const EnhancedProfileScreen({super.key});

  @override
  State<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends State<EnhancedProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep the state alive when switching tabs

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return MvvmScreenTemplate<EnhancedProfileViewModel, ProfileState>(
      title: 'Hồ sơ',
      onInit: (viewModel) => viewModel.initialize(),
      isLoading: (viewModel) => viewModel.isLoading,
      getErrorMessage: (viewModel) => viewModel.errorMessage,
      buildAppBar: (context, viewModel) => _buildAppBar(context),
      buildContent: (context, viewModel) => _buildContent(context, viewModel),
      buildError: (context, viewModel, errorMessage) {
        // Hiển thị lỗi theo cách thân thiện với người dùng
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Không thể tải thông tin',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  errorMessage ?? 'Đã xảy ra lỗi không xác định',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final viewModel = Provider.of<EnhancedProfileViewModel>(
                    context,
                    listen: false,
                  );
                  viewModel.initialize();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(AssetsManager.shoppingCart),
      ),
      title: const AppNameTextWidget(fontSize: 20),
    );
  }

  Widget _buildContent(
    BuildContext context,
    EnhancedProfileViewModel viewModel,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: !viewModel.isLoggedIn,
            child: const Padding(
              padding: EdgeInsets.all(18.0),
              child: TitlesTextWidget(
                label: "Vui lòng đăng nhập để có quyền truy cập đầy đủ",
              ),
            ),
          ),
          Visibility(
            visible: viewModel.isLoggedIn,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).cardColor,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 3,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
                        ),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitlesTextWidget(
                          label: viewModel.userInfo?.userName ?? "User",
                        ),
                        const SizedBox(height: 6),
                        SubtitleTextWidget(
                          label:
                              viewModel.userInfo?.email ?? "user@example.com",
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                    tooltip: 'Chỉnh sửa hồ sơ',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const EnhancedEditProfileScreen(),
                        ),
                      ).then((needReload) {
                        if (needReload == true) {
                          viewModel.checkLoginStatus();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(thickness: 1),
                const SizedBox(height: 10),
                const TitlesTextWidget(label: "Chung"),
                const SizedBox(height: 10),

                // Hiển thị các mục chung chỉ khi đã đăng nhập
                Visibility(
                  visible: viewModel.isLoggedIn,
                  child: Column(
                    children: [
                      CustomListTile(
                        text: "Tất cả đơn hàng",
                        imagePath:
                            AssetsManager.orderBag, // Biểu tượng túi đơn hàng
                        function: () {
                          Navigator.pushNamed(
                            context,
                            EnhancedOrdersScreen.routeName,
                          );
                        },
                      ),
                      CustomListTile(
                        text: "Danh sách yêu thích",
                        imagePath:
                            AssetsManager
                                .wishlistSvg, // Biểu tượng trái tim yêu thích
                        function: () {
                          Navigator.pushNamed(
                            context,
                            EnhancedWishlistScreen.routeName,
                          );
                        },
                      ),
                      CustomListTile(
                        text: "Đã xem gần đây",
                        imagePath: AssetsManager.recent, // Biểu tượng gần đây
                        function: () {
                          Navigator.pushNamed(
                            context,
                            EnhancedViewedRecentlyScreen.routeName,
                          );
                        },
                      ),
                      CustomListTile(
                        text: "Địa chỉ",
                        imagePath: AssetsManager.address, // Biểu tượng vị trí
                        function: () {
                          Navigator.pushNamed(
                            context,
                            EnhancedAddressScreen.routeName,
                          );
                        },
                      ),
                      CustomListTile(
                        text: "Lịch sử phân tích da",
                        imagePath:
                            AssetsManager
                                .cosmetics, // Biểu tượng mỹ phẩm phù hợp với phân tích da
                        function: () {
                          Navigator.pushNamed(
                            context,
                            EnhancedSkinAnalysisHistoryScreen.routeName,
                          );
                        },
                      ),
                      CustomListTile(
                        text: "Đánh giá của tôi",
                        imagePath:
                            AssetsManager
                                .bagWish, // Biểu tượng đánh giá/bình luận
                        function: () {
                          Navigator.pushNamed(
                            context,
                            EnhancedUserReviewsScreen.routeName,
                          );
                        },
                      ),
                      CustomListTile(
                        text: "Đổi mật khẩu",
                        imagePath: AssetsManager.privacy, // Biểu tượng bảo mật
                        function: () {
                          Navigator.pushNamed(
                            context,
                            EnhancedChangePasswordScreen.routeName,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Hiển thị nút đăng nhập khi chưa đăng nhập
                Visibility(
                  visible: !viewModel.isLoggedIn,
                  child: CustomListTile(
                    text: "Đăng nhập",
                    imagePath: AssetsManager.login,
                    function: () {
                      Navigator.pushNamed(
                        context,
                        EnhancedLoginScreen.routeName,
                      );
                    },
                  ),
                ),

                // Hiển thị nút đăng xuất chỉ khi đã đăng nhập
                Visibility(
                  visible: viewModel.isLoggedIn,
                  child: CustomListTile(
                    text: "Đăng xuất",
                    imagePath: AssetsManager.logout,
                    function: () async {
                      await _showLogoutDialog(context, viewModel);
                    },
                  ),
                ),

                const SizedBox(height: 10),
                const Divider(thickness: 1),
                const SizedBox(height: 10),

                // Phần cài đặt luôn hiển thị
                const TitlesTextWidget(label: "Cài đặt"),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Chế độ tối'),
                  secondary: Icon(
                    themeProvider.getIsDarkTheme
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                  value: themeProvider.getIsDarkTheme,
                  onChanged: (value) {
                    themeProvider.setDarkTheme(themeValue: value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(
    BuildContext context,
    EnhancedProfileViewModel viewModel,
  ) async {
    await MyAppFunctions.showErrorOrWarningDialog(
      context: context,
      subtitle: "Bạn có chắc chắn muốn đăng xuất không?",
      fct: () async {
        // Xóa giỏ hàng cục bộ trước khi đăng xuất
        final cartViewModel = Provider.of<EnhancedCartViewModel>(
          context,
          listen: false,
        );
        await cartViewModel.clearLocalCart();

        // Đăng xuất
        await viewModel.logout();
      },
      isError: false,
    );
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    required this.imagePath,
    required this.text,
    required this.function,
  });
  final String imagePath, text;
  final Function function;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        function();
      },
      title: SubtitleTextWidget(label: text),
      leading: Image.asset(imagePath, height: 34),
      trailing: const Icon(IconlyLight.arrow_right_2),
    );
  }
}
