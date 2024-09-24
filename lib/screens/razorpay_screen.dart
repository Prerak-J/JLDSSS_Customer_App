import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayScreen extends StatefulWidget {
  final Razorpay razorpay;
  final double amount;
  // final String orderId;
  const RazorpayScreen({
    super.key,
    required this.razorpay,
    required this.amount,
    // required this.orderId,
  });

  @override
  State<RazorpayScreen> createState() => _RazorpayScreenState();
}

class _RazorpayScreenState extends State<RazorpayScreen> {
  late Future<Map<String, dynamic>> _transactionFuture;

  @override
  void initState() {
    super.initState();
    _transactionFuture = _processTransaction();
  }

  Future<Map<String, dynamic>> _processTransaction() async {
    var options = {
      'key': 'rzp_test_e1rYx5jgmMSsij',
      'amount': (widget.amount * 100),
      'name': 'JLDSSS',
      'description': 'JLDSSS Food Order',
      'prefill': {
        'contact': '8871286285',
        'email': 'prerakjha4102@gmail.com',
      },
      'external': {
        'wallets': ['paytm', 'googlepay', 'phonepe']
      }
    };

    try {
      widget.razorpay.open(options);
      // This will be resolved when the payment is completed
      return await _awaitPaymentCompletion();
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> _awaitPaymentCompletion() {
    return Future.any([
      _paymentSuccessEvent(),
      _paymentErrorEvent(),
    ]);
  }

  Future<Map<String, dynamic>> _paymentSuccessEvent() {
    Completer<Map<String, dynamic>> completer = Completer();
    widget.razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) async {
      completer.complete({'success': true, 'message': 'Payment successful: ${response.paymentId}'});
      try {
        await FirebaseFirestore.instance.collection('payments').add({
          'paymentId': response.paymentId,
          'orderId': response.orderId,
          'signature': response.signature,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'success',
        });
      } catch (e) {
        print('Error saving to Firebase: $e');
      }
    });
    return completer.future;
  }

  Future<Map<String, dynamic>> _paymentErrorEvent() {
    Completer<Map<String, dynamic>> completer = Completer();
    widget.razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) async {
      completer.complete({'success': false, 'message': 'Payment failed: ${response.message}'});
      try {
        await FirebaseFirestore.instance.collection('payments').add({
          'errorCode': response.code,
          'errorMessage': response.message,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'failed',
        });
      } catch (e) {
        print('Error saving to Firebase: $e');
      }
    });
    return completer.future;
  }

  // Future<Map<String, dynamic>> _externalWalletEvent() {
  //   Completer<Map<String, dynamic>> completer = Completer();
  //   widget.razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
  //     completer.complete({'success': false, 'message': 'External wallet selected: ${response.walletName}'});
  //   });
  //   return completer.future;
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button
      child: Scaffold(
        body: Center(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _transactionFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Processing payment. Please do not go back or refresh the page.'),
                  ],
                );
              } else if (snapshot.hasData) {
                // Return to previous page with result
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pop(context, snapshot.data);
                });
                return Container();
              } else {
                return const Text('An error occurred');
              }
            },
          ),
        ),
      ),
    );
  }
}
