import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/pages/menu_page.dart';
import 'package:customer_app/screens/global_search_screen.dart';
import 'package:customer_app/utils/colors.dart';
import 'package:customer_app/utils/utils.dart';
import 'package:flutter/material.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('restaurants')
            .where('legit', isEqualTo: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                toolbarHeight: 45,
                backgroundColor: lightGrey.withOpacity(0),
                automaticallyImplyLeading: false,
                elevation: 8,
                // shadowColor: lightGrey,
                floating: true,
                flexibleSpace: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) => const GlobalSearchScreen()),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(8),
                    height: 45,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: appBarGreen.withOpacity(0.6),
                          width: 1.4,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: parrotGreen,
                          size: 20,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          'Restaurants and Dishes...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            wordSpacing: 0.5,
                            letterSpacing: 0.3,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          height: 0.5,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          color: secondaryGreen,
                        ),
                      ),
                      const Text(
                        'RESTAURANTS',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: secondaryGreen,
                          letterSpacing: 8,
                          fontSize: 16,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: 0.8,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          color: secondaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    String symbol =
                        snapshot.data!.docs[index].data()['type'].contains('Veg/Non-Veg')
                            ? '🥬🍖'
                            : '🥬';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: InkWell(
                        onTap: () {
                          if (snapshot.data!.docs[index].data()['open']) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuScreen(
                                  snap: snapshot.data!.docs[index].data(),
                                ),
                              ),
                            );
                          } else {
                            showSnackBar('This restaurant is closed', context);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 12,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          height: 280,
                          width: MediaQuery.of(context).size.width,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                                  width: MediaQuery.of(context).size.width,
                                  // height: 200,
                                  fit: BoxFit.contain,
                                  cacheWidth: (MediaQuery.of(context).size.width *
                                          MediaQuery.of(context).devicePixelRatio)
                                      .round(),
                                  color: snapshot.data!.docs[index].data()['open']
                                      ? null
                                      : Colors.grey,
                                  colorBlendMode: BlendMode.hue,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Material(
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(12),
                                  ),
                                  elevation: 8,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(12),
                                      ),
                                    ),
                                    height: 60,
                                    alignment: const Alignment(-0.92, 0.81),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          // alignment: const Alignment(-0.92, 0.81),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            snapshot.data!.docs[index].data()['name'],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          // alignment: const Alignment(-0.88, 0.89),
                                          padding: const EdgeInsets.only(bottom: 8.6, left: 12),

                                          child: Text(
                                            '${snapshot.data!.docs[index].data()['type']} $symbol',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: snapshot.data!.docs.length,
                ),
              ),
            ],
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}
