import 'package:customer_app/utils/colors.dart';
import 'package:flutter/material.dart';

Future<dynamic> showModalSheet(BuildContext context) {
  return showModalBottomSheet(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(12),
      ),
    ),
    isDismissible: false,
    elevation: 0,
    context: context,
    builder: (context) => InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        color: tealColor,
        width: double.infinity,
        height: 40,
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '2 Item(s) added to cart',
                style: TextStyle(color: Colors.white),
              ),
              Icon(
                Icons.arrow_circle_right_rounded,
                color: parrotGreen,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
