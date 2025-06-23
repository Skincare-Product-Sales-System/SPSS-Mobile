import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/loading_widget.dart';
import '../providers/base_view_model.dart';

/// Màn hình mẫu theo kiến trúc MVVM
///
/// T là kiểu của ViewModel, kế thừa từ BaseViewModel
/// S là kiểu của State sử dụng trong ViewModel
class MvvmScreenTemplate<T extends BaseViewModel<S>, S> extends StatefulWidget {
  final String title;
  final Widget Function(BuildContext, T) buildContent;
  final Widget Function(BuildContext, T)? buildAppBar;
  final Widget Function(BuildContext, T)? buildBottomBar;
  final Widget Function(BuildContext, T)? buildFloatingActionButton;
  final Widget Function(BuildContext, T, String?)? buildError;
  final Widget Function(BuildContext, T)? buildEmpty;
  final Widget Function(BuildContext, T)? buildLoading;
  final bool Function(T)? isLoading;
  final bool Function(T)? isEmpty;
  final String? Function(T)? getErrorMessage;
  final Future<void> Function(T)? onRefresh;
  final void Function(T)? onInit;

  const MvvmScreenTemplate({
    super.key,
    required this.title,
    required this.buildContent,
    this.buildAppBar,
    this.buildBottomBar,
    this.buildFloatingActionButton,
    this.buildError,
    this.buildEmpty,
    this.buildLoading,
    this.isLoading,
    this.isEmpty,
    this.getErrorMessage,
    this.onRefresh,
    this.onInit,
  });

  @override
  State<MvvmScreenTemplate<T, S>> createState() =>
      _MvvmScreenTemplateState<T, S>();
}

class _MvvmScreenTemplateState<T extends BaseViewModel<S>, S>
    extends State<MvvmScreenTemplate<T, S>> {
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    // Sử dụng addPostFrameCallback để tránh gọi setState trong quá trình build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isInit && mounted) {
        final viewModel = Provider.of<T>(context, listen: false);
        if (widget.onInit != null) {
          widget.onInit!(viewModel);
        }
        _isInit = false;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (context, viewModel, child) {
        // Xác định trạng thái màn hình
        final bool isLoading = widget.isLoading?.call(viewModel) ?? false;
        final bool isEmpty = widget.isEmpty?.call(viewModel) ?? false;
        final String? errorMessage = widget.getErrorMessage?.call(viewModel);

        // Xây dựng nội dung chính dựa trên trạng thái
        Widget content;
        if (isLoading) {
          content =
              widget.buildLoading?.call(context, viewModel) ??
              const Center(child: LoadingWidget());
        } else if (errorMessage != null) {
          content =
              widget.buildError?.call(context, viewModel, errorMessage) ??
              _buildDefaultError(context, errorMessage, viewModel);
        } else if (isEmpty) {
          content =
              widget.buildEmpty?.call(context, viewModel) ??
              _buildDefaultEmpty(context);
        } else {
          content = widget.buildContent(context, viewModel);
        }

        // Xây dựng AppBar tùy chỉnh hoặc mặc định
        final appBar =
            widget.buildAppBar?.call(context, viewModel) ??
            AppBar(title: Text(widget.title), elevation: 0);

        // Xây dựng Scaffold với các thành phần tùy chỉnh
        return Scaffold(
          appBar: appBar as PreferredSizeWidget?,
          body:
              widget.onRefresh != null
                  ? RefreshIndicator(
                    onRefresh: () => widget.onRefresh!(viewModel),
                    child: content,
                  )
                  : content,
          bottomNavigationBar: widget.buildBottomBar?.call(context, viewModel),
          floatingActionButton: widget.buildFloatingActionButton?.call(
            context,
            viewModel,
          ),
        );
      },
    );
  }

  // Widget lỗi mặc định
  Widget _buildDefaultError(
    BuildContext context,
    String errorMessage,
    T viewModel,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.red),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.onRefresh != null)
            ElevatedButton(
              onPressed: () => widget.onRefresh!(viewModel),
              child: const Text('Thử lại'),
            ),
        ],
      ),
    );
  }

  // Widget trống mặc định
  Widget _buildDefaultEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, color: Colors.grey, size: 60),
          const SizedBox(height: 16),
          Text(
            'Không có dữ liệu',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (widget.onRefresh != null)
            ElevatedButton(
              onPressed:
                  () =>
                      widget.onRefresh!(Provider.of<T>(context, listen: false)),
              child: const Text('Làm mới'),
            ),
        ],
      ),
    );
  }
}

// Đã di chuyển BaseViewModel sang lib/providers/base_view_model.dart

/// Ví dụ cụ thể về cách triển khai
/// 
/// ```dart
/// class ProductsScreen extends MvvmScreenTemplate<EnhancedProductsViewModel> {
///   const ProductsScreen({Key? key}) : super(key: key);
/// 
///   @override
///   PreferredSizeWidget buildAppBar(BuildContext context) {
///     return AppBar(title: const Text('Sản phẩm'));
///   }
/// 
///   @override
///   Widget buildEmptyView(BuildContext context) {
///     return const Center(child: Text('Không có sản phẩm nào'));
///   }
/// 
///   @override
///   Widget buildContentView(BuildContext context) {
///     final vm = context.watch<EnhancedProductsViewModel>();
///     return ListView.builder(
///       itemCount: vm.products.length,
///       itemBuilder: (context, index) => ProductItem(product: vm.products[index]),
///     );
///   }
/// 
///   @override
///   bool isLoading(BuildContext context) => context.read<EnhancedProductsViewModel>().isLoading;
/// 
///   @override
///   bool hasError(BuildContext context) => context.read<EnhancedProductsViewModel>().hasError;
/// 
///   @override
///   String? getErrorMessage(BuildContext context) => context.read<EnhancedProductsViewModel>().errorMessage;
/// 
///   @override
///   bool isEmpty(BuildContext context) => context.read<EnhancedProductsViewModel>().products.isEmpty;
/// 
///   @override
///   void onRetry(BuildContext context) {
///     context.read<EnhancedProductsViewModel>().loadProducts(refresh: true);
///   }
/// }
/// ``` 