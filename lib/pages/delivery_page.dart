import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/widgets/text_field_input.dart';
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Column(
        children: [
          TextFieldInput(
            icon: const Icon(
              Icons.search,
              color: appBarGreen,
            ),
            textEditingController: _searchController,
            hintText: 'Search for a restaurant or a dish',
            textInputType: TextInputType.text,
          ),
          const SizedBox(height: 250,),
          const Center(child: Text('HOOOOMMEEE SCREEEENNN'),),
        ],
      ),
    );
  }
}
