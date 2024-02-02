import 'package:customer_app/utils/colors.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  final Map<String, dynamic> snap;
  const MenuScreen({super.key, required this.snap});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    final menuWidth = MediaQuery.of(context).size.width * 0.955;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 2,
            shadowColor: lightGrey,
            floating: true,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.search,
                    size: 26,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                height: 130,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Text(
                        widget.snap['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        '  North-Indian ∘ Veg/Non-Veg 🥬',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            ]),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: 0.5,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 1,
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 180,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          alignment: Alignment.topLeft,
                          // color: lightGreen,
                          width: menuWidth * 0.63,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Align(
                                alignment: Alignment(-1.02, -1),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.crop_square_sharp,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    Icon(Icons.circle, color: Colors.red, size: 7),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                widget.snap['foodlist'][index]['NAME'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                          // color: Colors.green,
                          width: menuWidth * 0.37,
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.network(
                                  'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8YnVyZ2VyfGVufDB8fDB8fHww',
                                  height: 120,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              childCount: widget.snap['foodlist'].length,
            ),
          ),
        ],
      ),
    );
  }
}
