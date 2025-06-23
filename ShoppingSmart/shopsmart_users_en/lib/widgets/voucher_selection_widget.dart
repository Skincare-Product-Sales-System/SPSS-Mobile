import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/voucher_model.dart';
import '../services/api_service.dart';
import '../services/currency_formatter.dart';

class VoucherSelectionWidget extends StatefulWidget {
  final double orderTotal;
  final VoucherModel? selectedVoucher;
  final Function(VoucherModel?) onVoucherSelected;

  const VoucherSelectionWidget({
    super.key,
    required this.orderTotal,
    this.selectedVoucher,
    required this.onVoucherSelected,
  });

  @override
  State<VoucherSelectionWidget> createState() => _VoucherSelectionWidgetState();
}

class _VoucherSelectionWidgetState extends State<VoucherSelectionWidget> {
  final TextEditingController _voucherCodeController = TextEditingController();
  List<VoucherModel> _vouchers = [];
  bool _isLoading = false;
  bool _isValidating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
    if (widget.selectedVoucher != null) {
      _voucherCodeController.text = widget.selectedVoucher!.code;
    }
  }

  @override
  void dispose() {
    _voucherCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadVouchers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getVouchers(
        pageNumber: 1,
        pageSize: 20,
        status: 'Active',
      );

      if (response.success && response.data != null) {
        setState(() {
          _vouchers =
              response.data!.items
                  .where(
                    (voucher) => voucher.canApplyToOrder(widget.orderTotal),
                  )
                  .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load vouchers';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _validateVoucherCode() async {
    final code = _voucherCodeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isValidating = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.validateVoucher(code);

      if (response.success && response.data != null) {
        final voucher = response.data!;
        if (voucher.canApplyToOrder(widget.orderTotal)) {
          widget.onVoucherSelected(voucher);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Voucher "${voucher.code}" applied successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _errorMessage =
                'Voucher requires minimum order of ${CurrencyFormatter.formatVND(voucher.minimumOrderValue)}';
          });
        }
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Invalid voucher code';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildVoucherCodeInput() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.local_offer,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Enter Voucher Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _voucherCodeController,
                  decoration: InputDecoration(
                    hintText: 'Enter voucher code',
                    prefixIcon: const Icon(Icons.confirmation_number),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => _validateVoucherCode(),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isValidating ? null : _validateVoucherCode,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child:
                      _isValidating
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Apply'),
                ),
              ),
            ],
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoucherItem(VoucherModel voucher) {
    final isSelected = widget.selectedVoucher?.id == voucher.id;
    final discount = voucher.calculateDiscount(widget.orderTotal);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isSelected
                  ? [
                    Theme.of(context).primaryColor.withOpacity(0.8),
                    Theme.of(context).primaryColor,
                  ]
                  : [Theme.of(context).cardColor, Theme.of(context).cardColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            isSelected
                ? null
                : Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
        boxShadow: [
          BoxShadow(
            color:
                isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isSelected) {
              widget.onVoucherSelected(null);
            } else {
              widget.onVoucherSelected(voucher);
            }
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        voucher.code,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.orange[700],
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Theme.of(context).primaryColor,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  voucher.description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.percent,
                      size: 18,
                      color:
                          isSelected
                              ? Colors.white.withOpacity(0.9)
                              : Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${voucher.discountRate}% OFF',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            isSelected
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Save ${CurrencyFormatter.formatVND(discount)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected
                                ? Colors.white.withOpacity(0.9)
                                : Colors.green[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Colors.white.withOpacity(0.1)
                            : Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850]
                            : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            size: 16,
                            color:
                                isSelected
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Min. order: ${CurrencyFormatter.formatVND(voucher.minimumOrderValue)}',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isSelected
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color:
                                isSelected
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Valid until ${_formatDate(voucher.endDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isSelected
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Select Voucher',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildVoucherCodeInput(),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    )
                  else if (_vouchers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.local_offer_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No available vouchers',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(children: _vouchers.map(_buildVoucherItem).toList()),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show voucher selection bottom sheet
void showVoucherSelection({
  required BuildContext context,
  required double orderTotal,
  VoucherModel? selectedVoucher,
  required Function(VoucherModel?) onVoucherSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: VoucherSelectionWidget(
            orderTotal: orderTotal,
            selectedVoucher: selectedVoucher,
            onVoucherSelected: onVoucherSelected,
          ),
        ),
  );
}
