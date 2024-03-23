import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/pages/menu_page.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  final String resName;
  const LoadingScreen({super.key, required this.resName});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isLoading = false;
  Map<String, dynamic> snap = {};
  @override
  void initState() {
    super.initState();
    fetch();
  }

  void fetch() async {
    setState(() {
      _isLoading = true;
    });
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('restaurants').doc(widget.resName).get();
    snap = snapshot.data()!;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
            backgroundColor: Colors.white,
          )
        : MenuScreen(snap: snap);
  }
}
