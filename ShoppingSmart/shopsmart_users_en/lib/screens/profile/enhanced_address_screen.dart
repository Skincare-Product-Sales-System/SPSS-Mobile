import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter/services.dart';

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
                              ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return const LinearGradient(
                                    colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  _isEditing ? 'Chỉnh sửa địa chỉ' : 'Thêm địa chỉ mới',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Colors.white, // Sẽ được che bởi gradient
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setModalState(() {
                                    _isSaving = false;
                                  });
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close, color: Color(0xFF8F5CFF)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildAddressTextField(_customerNameController, 'Tên người nhận'),
                          const SizedBox(height: 16),
                          _buildAddressTextField(_phoneController, 'Số điện thoại', keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)]),
                          if (_phoneController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    RegExp(r'^0\d{9,10}$').hasMatch(_phoneController.text.trim()) ? Icons.check_circle : Icons.cancel,
                                    color: RegExp(r'^0\d{9,10}$').hasMatch(_phoneController.text.trim()) ? Colors.green : Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    RegExp(r'^0\d{9,10}$').hasMatch(_phoneController.text.trim()) ? 'Số điện thoại hợp lệ' : 'Số điện thoại phải có 10 hoặc 11 chữ số',
                                    style: TextStyle(
                                      color: RegExp(r'^0\d{9,10}$').hasMatch(_phoneController.text.trim()) ? Colors.green : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          _buildAddressTextField(_streetNumberController, 'Số nhà'),
                          const SizedBox(height: 16),
                          _buildAddressTextField(_addressLine1Controller, 'Địa chỉ 1'),
                          const SizedBox(height: 16),
                          _buildAddressTextField(_addressLine2Controller, 'Địa chỉ 2 (tùy chọn)'),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildAddressTextField(_wardController, 'Phường/Xã')),
                              const SizedBox(width: 16),
                              Expanded(child: _buildAddressTextField(_cityController, 'Quận/Huyện')),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildAddressTextField(_provinceController, 'Tỉnh/Thành phố')),
                              const SizedBox(width: 16),
                              Expanded(child: _buildAddressTextField(_postcodeController, 'Mã bưu điện')),
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
                                activeColor: const Color(0xFF8F5CFF),
                              ),
                              const Text('Đặt làm địa chỉ mặc định', style: TextStyle(color: Color(0xFF8F5CFF), fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(16)),
                              ),
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : () => _saveAddress(setModalState),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: _isSaving
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                        _isEditing ? 'Cập nhật' : 'Lưu địa chỉ',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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

  Widget _buildAddressTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFBCA7FF), fontWeight: FontWeight.w500),
        hintText: label,
        hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 16),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBCA7FF), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF8F5CFF), width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: (value) {
        if ((label != 'Địa chỉ 2 (tùy chọn)') && (value == null || value.isEmpty)) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },
    );
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
          (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Color(0xFF8F5CFF), Colors.red],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'Xác nhận xóa',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn có chắc chắn muốn xóa địa chỉ này?',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF8F5CFF), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Hủy', style: TextStyle(color: Color(0xFF8F5CFF), fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red, Color(0xFFFF8A65)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              final viewModel = Provider.of<EnhancedProfileViewModel>(context, listen: false);
                              try {
                                final result = await viewModel.userRepository.deleteAddress(addressId);
                                if (result.success) {
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
                                      content: Text('Lỗi: ${result.message}'),
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text('Địa chỉ của tôi'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
          ),
        ),
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
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddressForm(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressModel address) {
    if (address.isDefault) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(2.2),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildAddressCardContent(context, address),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildAddressCardContent(context, address),
      );
    }
  }

  Widget _buildAddressCardContent(BuildContext context, AddressModel address) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(IconlyBold.location, size: 20, color: Color(0xFF8F5CFF)),
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
              const Icon(IconlyLight.profile, size: 20, color: Color(0xFF8F5CFF)),
              const SizedBox(width: 8),
              Text(address.customerName),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(IconlyLight.call, size: 20, color: Color(0xFF8F5CFF)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBCA7FF).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF8F5CFF)),
                  ),
                  child: const Text(
                    'Mặc định',
                    style: TextStyle(
                      color: Color(0xFF8F5CFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                OutlinedButton(
                  onPressed: () => _setAsDefault(address.id),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF8F5CFF), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  ),
                  child: const Text('Đặt làm mặc định', style: TextStyle(color: Color(0xFF8F5CFF), fontWeight: FontWeight.bold)),
                ),
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF8F5CFF), Color(0xFFBCA7FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: IconButton(
                      onPressed: () => _showAddressForm(context, address: address),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      tooltip: 'Sửa',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () => _deleteAddress(address.id),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Xóa',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
