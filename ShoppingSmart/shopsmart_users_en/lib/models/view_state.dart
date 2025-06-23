/// Enum representing different states of a view
enum ViewStateStatus { initial, loading, loadingMore, loaded, error, empty }

/// A general-purpose class to manage UI state
class ViewState<T> {
  final ViewStateStatus status;
  final T? data;
  final String? message;
  final List<String>? errors;
  final bool isRefreshing;

  const ViewState({
    this.status = ViewStateStatus.initial,
    this.data,
    this.message,
    this.errors,
    this.isRefreshing = false,
  });

  /// Create an initial state
  factory ViewState.initial() => ViewState<T>(status: ViewStateStatus.initial);

  /// Create a loading state
  factory ViewState.loading() => ViewState<T>(status: ViewStateStatus.loading);

  /// Create a loading more state (for pagination)
  factory ViewState.loadingMore(T data) =>
      ViewState<T>(status: ViewStateStatus.loadingMore, data: data);

  /// Create a refreshing state
  factory ViewState.refreshing(T data) => ViewState<T>(
    status: ViewStateStatus.loading,
    data: data,
    isRefreshing: true,
  );

  /// Create a loaded state with data
  factory ViewState.loaded(T data) =>
      ViewState<T>(status: ViewStateStatus.loaded, data: data);

  /// Create an empty state
  factory ViewState.empty([String? message]) => ViewState<T>(
    status: ViewStateStatus.empty,
    message: message ?? 'No data found',
  );

  /// Create an error state
  factory ViewState.error(String message, [List<String>? errors]) =>
      ViewState<T>(
        status: ViewStateStatus.error,
        message: message,
        errors: errors,
      );

  /// Check if the view state is loading
  bool get isLoading => status == ViewStateStatus.loading;

  /// Check if the view state is loading more
  bool get isLoadingMore => status == ViewStateStatus.loadingMore;

  /// Check if the view state has an error
  bool get hasError => status == ViewStateStatus.error;

  /// Check if the view state is empty
  bool get isEmpty => status == ViewStateStatus.empty;

  /// Create a copy of this state with some properties changed
  ViewState<T> copyWith({
    ViewStateStatus? status,
    T? data,
    String? message,
    List<String>? errors,
    bool? isRefreshing,
  }) {
    return ViewState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      message: message ?? this.message,
      errors: errors ?? this.errors,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
