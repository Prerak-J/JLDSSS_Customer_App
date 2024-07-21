import 'dart:async';

import 'package:customer_app/pages/active_order_page.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:flutter/material.dart';

showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: const Color.fromARGB(255, 186, 252, 145),
      content: Text(
        content,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      duration: const Duration(milliseconds: 3000),
    ),
  );
}

class AnimContainer extends StatefulWidget {
  final String displayStatus;
  const AnimContainer({super.key, required this.displayStatus});

  @override
  State<AnimContainer> createState() => _AnimContainerState();
}

class _AnimContainerState extends State<AnimContainer> {
  List<Color> colors = [
    Colors.greenAccent,
    lightGreen,
    const Color(0xFFAED581),
  ];
  int currentColor = 0;
  Timer timer = Timer(Duration.zero, () {});

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      setState(() {
        currentColor = (currentColor + 1) % 3;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ActiveOrderScreen()),
        ),
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Curves.elasticInOut,
          decoration: BoxDecoration(
            // color: Color.fromARGB(255, 169, 233, 171),
            color: colors[currentColor],
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            border: const Border(
              top: BorderSide(
                color: tealColor,
                width: 2,
              ),
              left: BorderSide(
                color: tealColor,
                width: 0.5,
              ),
              right: BorderSide(
                color: tealColor,
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          width: double.infinity,
          height: 50,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.displayStatus}...',
                  style: const TextStyle(color: appBarGreen, fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Icon(
                  Icons.arrow_circle_right_rounded,
                  color: tealColor.withGreen(45),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
