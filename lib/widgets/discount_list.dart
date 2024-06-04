import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:flutter/material.dart';

class DiscountList extends StatefulWidget {
  final List<Map<String, dynamic>> discountList;
  final double grdTotal;

  const DiscountList({
    super.key,
    required this.discountList,
    required this.grdTotal,
  });

  @override
  State<DiscountList> createState() => _DiscountListState();
}

class _DiscountListState extends State<DiscountList> {
  @override
  Widget build(BuildContext context) {
    if (widget.discountList.isEmpty) {
      return const Center(
        child: Text('No Available Coupons :('),
      );
    }
    // Sort the discountList in descending order of the 'discount' field
    widget.discountList.sort((a, b) => b['discount'].compareTo(a['discount']));

    return ListView.builder(
      // physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.discountList.length,
      itemBuilder: (context, index) {
        final coupon = widget.discountList[index];

        // Skip disabled coupons
        if (!coupon['enabled']) {
          return Container();
        }

        // Check if the grdTotal is less than the coupon's min_price
        final isMinPriceExceeded = widget.grdTotal >= coupon['min_price'];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            borderRadius: BorderRadius.circular(12),
            elevation: 6,
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                coupon['name'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${coupon['discount']}% off up to ${coupon['limit'].toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: parrotGreen,
                    ),
                  ),
                  Text(
                    'on orders above ${coupon['min_price'].toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: isMinPriceExceeded ? Colors.blue[800] : Colors.red[800],
                    ),
                  ),
                ],
              ),
              trailing: InkWell(
                onTap: () {
                  isMinPriceExceeded ? Navigator.pop(context, coupon) : showSnackBar('Coupon not eligible', context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: parrotGreen,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: const Text(
                    'APPLY',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              enabled: isMinPriceExceeded,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              tileColor: isMinPriceExceeded ? const Color.fromARGB(255, 218, 255, 198) : Colors.grey[200],
            ),
          ),
        );
      },
    );
  }
}
