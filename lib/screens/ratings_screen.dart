import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:flutter/material.dart';

class RatingsScreen extends StatefulWidget {
  final Map<String, dynamic> orderSnap;
  final Map<String, dynamic> partnerSnap;
  final Map<String, dynamic> restaurantSnap;
  const RatingsScreen({
    super.key,
    required this.orderSnap,
    required this.partnerSnap,
    required this.restaurantSnap,
  });

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  double restaurantRating = 0.0;
  double deliveryPartnerRating = 0.0;
  bool _isLoading = false;

  void submitRating() async {
    setState(() {
      _isLoading = true;
    });
    String res = 'Some error occured';
    try {
      await FirebaseFirestore.instance.collection('restaurants').doc(widget.restaurantSnap['resUid']).update(
        {
          'rating': widget.restaurantSnap.containsKey('rating')
              ? (restaurantRating + widget.restaurantSnap['rating']) / 2
              : restaurantRating,
        },
      );
      await FirebaseFirestore.instance.collection('partners').doc(widget.partnerSnap['uid']).update(
        {
          'rating': widget.partnerSnap.containsKey('rating')
              ? (deliveryPartnerRating + widget.partnerSnap['rating']) / 2
              : deliveryPartnerRating,
        },
      );
      res = 'success';
    } on FirebaseException catch (e) {
      res = e.message ?? e.toString();
    }
    setState(() {
      _isLoading = false;
    });
    if (mounted) {
      if (res != 'success') {
        showSnackBar(res, context);
      } else {
        showSnackBar('Rating Submitted', context);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.orderSnap.isEmpty || widget.partnerSnap.isEmpty || widget.restaurantSnap.isEmpty) && mounted) {
      Navigator.pop(context);
    }
    return _isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('Rate Your Experience'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Rate the Restaurant',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  RatingBar(
                    initialRating: restaurantRating,
                    onRatingUpdate: (rating) {
                      setState(() {
                        restaurantRating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 32.0),
                  const Text(
                    'Rate the Delivery Partner',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  RatingBar(
                    initialRating: deliveryPartnerRating,
                    onRatingUpdate: (rating) {
                      setState(() {
                        deliveryPartnerRating = rating;
                      });
                    },
                  ),
                ],
              ),
            ),
            persistentFooterButtons: (deliveryPartnerRating == 0.0 || restaurantRating == 0.0)
                ? [Container()]
                : [
                    Center(
                      child: InkWell(
                        onTap: submitRating,
                        child: AnimatedContainer(
                          width: MediaQuery.of(context).size.width * 0.96,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: tealColor.withGreen(45),
                          ),
                          duration: Durations.extralong1,
                          child: const Text(
                            'Submit Rating',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
          );
  }
}

class RatingBar extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingUpdate;

  const RatingBar({
    super.key,
    required this.initialRating,
    required this.onRatingUpdate,
  });

  @override
  State<RatingBar> createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => IconButton(
          icon: Icon(
            _rating > index ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 36.0,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1.0;
            });
            widget.onRatingUpdate(_rating);
          },
        ),
      ),
    );
  }
}
