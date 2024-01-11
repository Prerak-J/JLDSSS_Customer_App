import 'package:customer_app/utils/colors.dart';
import 'package:flutter/material.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          pinned: true,
          // bottom: const PreferredSize(
          //   preferredSize: Size.fromHeight(-10),
          //   child: SizedBox(),
          // ),
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 5),
            child: SearchBar(
              padding: const MaterialStatePropertyAll(
                EdgeInsets.symmetric(
                  horizontal: 16,
                ),
              ),
              leading: const Icon(Icons.search),
              hintText: 'Restaurants or dishes',
              hintStyle: const MaterialStatePropertyAll(
                TextStyle(fontStyle: FontStyle.italic, wordSpacing: 0.5),
              ),
              constraints: const BoxConstraints(minHeight: 100),
              controller: _searchController,
              shadowColor: const MaterialStatePropertyAll(lightGrey),
              side: MaterialStatePropertyAll(
                BorderSide(
                  color: parrotGreen.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: lightGreen,
                  ),
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                ),
              );
            },
            childCount: 20,
          ),
        )
      ],
    );
  }
}
