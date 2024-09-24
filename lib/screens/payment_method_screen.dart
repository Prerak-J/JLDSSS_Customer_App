// import 'dart:async';

// import 'package:customer_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';

class PaymentOptionsScreen extends StatefulWidget {
  final double amount;

  const PaymentOptionsScreen({super.key, required this.amount});

  @override
  State<PaymentOptionsScreen> createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  bool _isLoading = false;

  void handleUpiResponse(UpiResponse response) {
    if (response.status == UpiPaymentStatus.SUCCESS) {
      print('Transaction successful');
      // showSnackBar('Transaction Successful', context);
      Navigator.pop(context, true);
      // Proceed with order completion
    } else if (response.status == UpiPaymentStatus.SUBMITTED) {
      print('Transaction submitted');
      setState(() {
        _isLoading = true;
      });
      // Timer.periodic(const Duration(seconds: 3), (timer) {
      //   handleUpiResponse(response);
      // });
      // Handle submitted status
    } else {
      print('Transaction failed');
      Navigator.pop(context, false);
      // Handle failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Options')),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Processing payment...'),
                  ),
                ],
              ),
            )
          : ListView(
              children: [
                PaymentOption(
                  title: 'Cash on Delivery',
                  icon: Icons.money,
                  onTap: () => handleCashOnDelivery(context),
                ),
                PaymentOption(
                  title: 'Google Pay',
                  icon: Icons.account_balance_wallet,
                  onTap: () => handleUpiPayment(UpiApp.googlePay),
                ),
                PaymentOption(
                  title: 'PhonePe',
                  icon: Icons.phone_android,
                  onTap: () => handleUpiPayment(UpiApp.phonePe),
                ),
                PaymentOption(
                  title: 'Paytm',
                  icon: Icons.payment,
                  onTap: () => handleUpiPayment(UpiApp.paytm),
                ),
              ],
            ),
    );
  }

  void handleCashOnDelivery(BuildContext context) {
    // Implement cash on delivery logic
    Navigator.pop(context, true);
  }

  void handleUpiPayment(UpiApp app) async {
    UpiIndia upiIndia = UpiIndia();
    setState(() {
      _isLoading = true;
    });
    UpiResponse response = await upiIndia.startTransaction(
      app: app,
      receiverUpiId: "prerakjha4102@oksbi",
      receiverName: 'Merchant Name',
      transactionRefId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      transactionNote: 'Payment for order',
      amount: widget.amount,
    );
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    // Handle the response
    handleUpiResponse(response);
  }
}

class PaymentOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const PaymentOption({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
