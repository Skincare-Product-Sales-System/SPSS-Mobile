import 'package:flutter/material.dart';
import '../models/voucher_model.dart';
import '../services/currency_formatter.dart';
import '../widgets/voucher_selection_widget.dart';

class VoucherCardWidget extends StatelessWidget {
  final double orderTotal;
  final VoucherModel? selectedVoucher;
  final Function(VoucherModel?) onVoucherChanged;

  const VoucherCardWidget({
    Key? key,
    required this.orderTotal,
    this.selectedVoucher,
    required this.onVoucherChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasVoucher = selectedVoucher != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              hasVoucher
                  ? Theme.of(context).primaryColor.withOpacity(0.3)
                  : Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color:
                hasVoucher
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showVoucherSelection(
              context: context,
              orderTotal: orderTotal,
              selectedVoucher: selectedVoucher,
              onVoucherSelected: onVoucherChanged,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                hasVoucher
                    ? _buildSelectedVoucherView(context)
                    : _buildSelectVoucherView(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectVoucherView(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.local_offer, color: Colors.orange[700], size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Áp dụng mã giảm giá',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Chạm để chọn và tiết kiệm',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
      ],
    );
  }

  Widget _buildSelectedVoucherView(BuildContext context) {
    final discount = selectedVoucher!.calculateDiscount(orderTotal);

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.8),
                    Theme.of(context).primaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_offer,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          selectedVoucher!.code,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green[600],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedVoucher!.description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Tiết kiệm',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  CurrencyFormatter.formatVND(discount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]!.withOpacity(0.5)
                    : Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.savings, size: 16, color: Colors.green[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Giảm ${selectedVoucher!.discountRate}% • Đơn tối thiểu ${CurrencyFormatter.formatVND(selectedVoucher!.minimumOrderValue)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onVoucherChanged(null),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
