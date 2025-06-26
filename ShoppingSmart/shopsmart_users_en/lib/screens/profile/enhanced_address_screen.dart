import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconly/iconly.dart';

import '../../models/address_model.dart';
import '../../models/api_response_model.dart';
import '../../models/view_state.dart';
import '../../providers/enhanced_profile_view_model.dart';
import '../../widgets/title_text.dart';

class EnhancedAddressScreen extends StatefulWidget {
  static const routeName = '/enhanced-address';
  const EnhancedAddressScreen({super.key});

  @override
  State<EnhancedAddressScreen> createState() => _EnhancedAddressScreenState();
}

class _EnhancedAddressScreenState extends State<EnhancedAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  bool _isDefault = false;
  bool _isEditing = false;
  String? _editingAddressId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Fetch addresses when the screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EnhancedProfileViewModel>(
        context,
        listen: false,
      ).fetchAddresses();
    });
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneController.dispose();
    _streetNumberController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _wardController.dispose();
    _postcodeController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _customerNameController.clear();
    _phoneController.clear();
    _streetNumberController.clear();
    _addressLine1Controller.clear();
    _addressLine2Controller.clear();
    _cityController.clear();
    _wardController.clear();
    _postcodeController.clear();
    _provinceController.clear();
    _isDefault = false;
    _isEditing = false;
    _editingAddressId = null;
  }

  void _showAddressForm(BuildContext context, {AddressModel? address}) {
    // Reset form state
    _resetForm();

    if (address != null) {
      // Phân tách địa chỉ thành các thành phần
      _customerNameController.text = address.customerName;
      _phoneController.text = address.phoneNumber;
      _streetNumberController.text = address.streetNumber;
      _addressLine1Controller.text = address.addressLine1;
      _addressLine2Controller.text = address.addressLine2;
      _cityController.text = address.city;
      _wardController.text = address.ward;
      _postcodeController.text = address.postCode;
      _provinceController.text = address.province;
      _isDefault = address.isDefault;
      _isEditing = true;
      _editingAddressId = address.id;
    }

    // Reset saving state when modal is opened
    setState(() {
      _isSaving = false;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TitlesTextWidget(
                                label:
                                    _isEditing
                                        ? 'Chỉnh sửa địa chỉ'
                                        : 'Thêm địa chỉ mới',
                              ),
                              IconButton(
                                onPressed: () {
                                  // Reset saving state when modal is closed
                                  setState(() {
                                    _isSaving = false;
                                  });
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _customerNameController,
                            decoration: const InputDecoration(
                              labelText: 'Tên người nhận',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tên người nhận';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Số điện thoại',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập số điện thoại';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _streetNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Số nhà',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập số nhà';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _addressLine1Controller,
                            decoration: const InputDecoration(
                              labelText: 'Địa chỉ 1',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập địa chỉ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _addressLine2Controller,
                            decoration: const InputDecoration(
                              labelText: 'Địa chỉ 2 (tùy chọn)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _wardController,
                                  decoration: const InputDecoration(
                                    labelText: 'Phường/Xã',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập phường/xã';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _cityController,
                                  decoration: const InputDecoration(
                                    labelText: 'Quận/Huyện',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập quận/huyện';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _provinceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Tỉnh/Thành phố',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập tỉnh/thành phố';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _postcodeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Mã bưu điện',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Checkbox(
                                value: _isDefault,
                                onChanged: (value) {
                                  setModalState(() {
                                    _isDefault = value ?? false;
                                  });
                                },
                              ),
                              const Text('Đặt làm địa chỉ mặc định'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  _isSaving
                                      ? null
                                      : () => _saveAddress(setModalState),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  _isSaving
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : Text(
                                        _isEditing ? 'Cập nhật' : 'Lưu địa chỉ',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    ).then((_) {
      // Ensure saving state is reset when modal is closed
      setState(() {
        _isSaving = false;
      });
    });
  }

  void _saveAddress(StateSetter setModalState) async {
    if (_formKey.currentState!.validate()) {
      setModalState(() {
        _isSaving = true;
      });

      final viewModel = Provider.of<EnhancedProfileViewModel>(
        context,
        listen: false,
      );

      try {
        // Tạo đối tượng AddressModel từ dữ liệu form
        final addressModel = AddressModel(
          id: _isEditing && _editingAddressId != null ? _editingAddressId! : '',
          customerName: _customerNameController.text,
          phoneNumber: _phoneController.text,
          streetNumber: _streetNumberController.text,
          addressLine1: _addressLine1Controller.text,
          addressLine2: _addressLine2Controller.text,
          city: _cityController.text,
          ward: _wardController.text,
          province: _provinceController.text,
          postCode: _postcodeController.text,
          isDefault: _isDefault,
          countryId: 1, // Default to Vietnam with ID 1
          countryName: 'Việt Nam', // Default country name
        );

        // Debug: In ra dữ liệu gửi đi
        print('AddressModel JSON: ${addressModel.toJson()}');

        ApiResponse<AddressModel> result;
        if (_isEditing && _editingAddressId != null) {
          // Cập nhật địa chỉ hiện có
          result = await viewModel.userRepository.updateAddress(addressModel);
        } else {
          // Thêm địa chỉ mới
          result = await viewModel.userRepository.addAddress(addressModel);
        }

        // Đảm bảo reset trạng thái loading ngay cả khi có lỗi
        if (mounted) {
          setModalState(() {
            _isSaving = false;
          });
        }

        if (result.success) {
          // Refresh danh sách địa chỉ
          await viewModel.fetchAddresses();

          // Đóng modal và hiển thị thông báo
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditing
                      ? 'Cập nhật địa chỉ thành công'
                      : 'Thêm địa chỉ mới thành công',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Hiển thị thông báo lỗi chi tiết hơn
          final errorDetails =
              result.errors != null && result.errors!.isNotEmpty
                  ? '\n${result.errors!.join('\n')}'
                  : '';

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Lỗi: ${result.message ?? 'Không xác định'}$errorDetails',
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } catch (e) {
        // Đảm bảo reset trạng thái loading khi có exception
        if (mounted) {
          setModalState(() {
            _isSaving = false;
          });

          // Hiển thị lỗi chi tiết hơn
          print('Exception when saving address: $e');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xảy ra lỗi: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  void _deleteAddress(String addressId) async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc chắn muốn xóa địa chỉ này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);

                  final viewModel = Provider.of<EnhancedProfileViewModel>(
                    context,
                    listen: false,
                  );

                  try {
                    final result = await viewModel.userRepository.deleteAddress(
                      addressId,
                    );
                    if (result.success) {
                      // Refresh danh sách địa chỉ
                      await viewModel.fetchAddresses();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Địa chỉ đã được xóa'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi: ${result.message}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã xảy ra lỗi: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _setAsDefault(String addressId) async {
    final viewModel = Provider.of<EnhancedProfileViewModel>(
      context,
      listen: false,
    );

    try {
      final result = await viewModel.userRepository.setDefaultAddress(
        addressId,
      );
      if (result.success) {
        // Refresh danh sách địa chỉ
        await viewModel.fetchAddresses();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt địa chỉ làm mặc định thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatAddress(AddressModel address) {
    List<String> parts = [];

    if (address.streetNumber.isNotEmpty) {
      parts.add(address.streetNumber);
    }

    if (address.addressLine1.isNotEmpty) {
      parts.add(address.addressLine1);
    }

    if (address.ward.isNotEmpty) {
      parts.add(address.ward);
    }

    if (address.city.isNotEmpty) {
      parts.add(address.city);
    }

    if (address.province.isNotEmpty) {
      parts.add(address.province);
    }

    return parts.join(', ');
  }

  Widget _buildAddressCard(BuildContext context, AddressModel address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              address.isDefault
                  ? Theme.of(context).primaryColor
                  : Colors.grey.withOpacity(0.2),
          width: address.isDefault ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(IconlyBold.location, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatAddress(address),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(IconlyLight.profile, size: 20),
                const SizedBox(width: 8),
                Text(address.customerName),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(IconlyLight.call, size: 20),
                const SizedBox(width: 8),
                Text(address.phoneNumber),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    child: Text(
                      'Mặc định',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => _setAsDefault(address.id),
                    child: const Text('Đặt làm mặc định'),
                  ),
                Row(
                  children: [
                    IconButton(
                      onPressed:
                          () => _showAddressForm(context, address: address),
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                    ),
                    IconButton(
                      onPressed: () => _deleteAddress(address.id),
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Địa chỉ của tôi'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<EnhancedProfileViewModel>(
        builder: (context, viewModel, child) {
          // Load addresses from ViewModel
          final addresses = viewModel.addresses;
          final isLoading =
              viewModel.state.addresses.status == ViewStateStatus.loading;
          final errorMessage = viewModel.state.addresses.message;

          // Show loading indicator while fetching data
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error message if there's an error
          if (errorMessage != null && addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Đã xảy ra lỗi',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(errorMessage, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.fetchAddresses();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(IconlyLight.location, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Bạn chưa có địa chỉ nào',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thêm địa chỉ để tiện cho việc mua sắm',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddressForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm địa chỉ mới'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return _buildAddressCard(context, address);
                },
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () => _showAddressForm(context),
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
