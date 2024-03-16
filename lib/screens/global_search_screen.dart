import 'package:customer_app/utils/colors.dart';
import 'package:flutter/material.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  bool selected = false;
  List<String> restaurants = [
    'Jaluk',
    'Apanjon',
    'New Bela',
    'Maa Anpurnaaaaaaaaaa',
    'KFC',
    'Jaluk',
    'Apanjon',
    'New Bela',
    'Maa Anpurnaaaaaaaaaa',
    'KFC',
    'Jaluk',
    'Apanjon',
    'New Bela',
    'Maa Anpurnaaaaaaaaaa',
    'KFC',
    'Jaluk',
    'Apanjon',
    'New Bela',
    'Maa Anpurnaaaaaaaaaa',
    'KFC',
  ];

  List<String> dishes = [
    'Chicken',
    'Maggie',
    'Popcorn',
    'Rice',
    'Paneer Chilli',
    'Chicken',
    'Maggie',
    'Popcorn',
    'Rice',
    'Paneer Chilli',
    'Chicken',
    'Maggie',
    'Popcorn',
    'Rice',
    'Paneer Chilli',
    'Chicken',
    'Maggie',
    'Popcorn',
    'Rice',
    'Paneer Chilli',
    'Chicken',
    'Maggie',
    'Popcorn',
    'Rice',
    'Paneer Chilli',
    'Chicken',
    'Maggie',
    'Popcorn',
    'Rice',
    'Paneer Chilli',
    'Chicken',
    'Maggie',
    'Popcorn',
    'Rice',
    'Paneer Chilli',
  ];

  List<String> filteredRestaurants = [];
  List<String> filteredDishes = [];

  void filterSearchResults(String query) {
    filteredRestaurants.clear();
    filteredDishes.clear();
    if (query.isNotEmpty) {
      for (var restaurant in restaurants) {
        if (restaurant.toLowerCase().contains(query.toLowerCase())) {
          filteredRestaurants.add(restaurant);
        }
      }
      for (var dish in dishes) {
        if (dish.toLowerCase().contains(query.toLowerCase())) {
          filteredDishes.add(dish);
        }
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    restaurants.sort();
    dishes.sort();
    selected = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leadingWidth: 26,
        title: TextField(
          onChanged: (value) {
            filterSearchResults(value);
          },
          decoration: const InputDecoration(
            hintText: 'Search...',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: (() => setState(() {
                          selected = false;
                        })),
                    child: Text(
                      'Restaurants',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: !selected ? parrotGreen : Colors.black,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (() => setState(() {
                          selected = true;
                        })),
                    child: Text(
                      'Dishes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: selected ? parrotGreen : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    !selected
                        ? ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: filteredRestaurants.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  const Divider(
                                    indent: 12,
                                    endIndent: 12,
                                  ),
                                  ListTile(
                                    dense: true,
                                    title: Text(
                                      filteredRestaurants[index],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                                    // tileColor: lightGrey.withGreen(255),
                                  ),
                                ],
                              );
                            },
                          )
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: filteredDishes.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  const Divider(
                                    indent: 12,
                                    endIndent: 12,
                                  ),
                                  ListTile(
                                    dense: true,
                                    title: Text(
                                      filteredDishes[index],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                                    // tileColor: lightGrey.withGreen(255),
                                  ),
                                ],
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
