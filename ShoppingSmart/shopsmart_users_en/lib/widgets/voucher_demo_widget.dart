import 'package:flutter/material.dart';
import '../models/voucher_model.dart';
import '../services/currency_formatter.dart';
import '../widgets/voucher_card_widget.dart';

class VoucherDemoWidget extends StatefulWidget {
  const VoucherDemoWidget({Key? key}) : super(key: key);

  @override
  State<VoucherDemoWidget> createState() => _VoucherDemoWidgetState();
}

class _VoucherDemoWidgetState extends State<VoucherDemoWidget> {
  VoucherModel? selectedVoucher;
  double orderTotal = 600000; // Sample order total

  void _onVoucherChanged(VoucherModel? voucher) {
    setState(() {
      selectedVoucher = voucher;
    });
  }

  double get discountAmount {
    return selectedVoucher?.calculateDiscount(orderTotal) ?? 0;
  }

  double get finalTotal {
    return orderTotal - discountAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary Card
          Container(
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
                        Icons.receipt_long,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Voucher Demo - Order Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSummaryRow(
                  'Subtotal',
                  CurrencyFormatter.formatVND(orderTotal),
                ),
                if (selectedVoucher != null) ...[
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Discount (${selectedVoucher!.code})',
                    '-${CurrencyFormatter.formatVND(discountAmount)}',
                    isDiscount: true,
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  'Total',
                  CurrencyFormatter.formatVND(finalTotal),
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Voucher Card
          VoucherCardWidget(
            orderTotal: orderTotal,
            selectedVoucher: selectedVoucher,
            onVoucherChanged: _onVoucherChanged,
          ),
          const SizedBox(height: 16),
          // Order Total Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Test Different Order Amounts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Order Total: ${CurrencyFormatter.formatVND(orderTotal)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildAmountChip(200000),
                    _buildAmountChip(500000),
                    _buildAmountChip(800000),
                    _buildAmountChip(1000000),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color:
                isDiscount
                    ? Colors.green
                    : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color:
                isDiscount
                    ? Colors.green
                    : isTotal
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountChip(double amount) {
    final isSelected = orderTotal == amount;

    return FilterChip(
      label: Text(CurrencyFormatter.formatVND(amount)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            orderTotal = amount;
            // Reset voucher if it can't be applied to new amount
            if (selectedVoucher != null &&
                !selectedVoucher!.canApplyToOrder(amount)) {
              selectedVoucher = null;
            }
          });
        }
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : null,
        fontWeight: isSelected ? FontWeight.w600 : null,
      ),
    );
  }
}
