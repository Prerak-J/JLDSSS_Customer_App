import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/pages/menu_page.dart';
import 'package:customer_app/utils/colors.dart';
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
        stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                scrolledUnderElevation: 5,
                floating: true,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 5),
                  child: SearchBar(
                    shape: MaterialStatePropertyAll(
                      ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    padding: const MaterialStatePropertyAll(
                      EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    leading: const Icon(Icons.search),
                    hintText: 'Restaurants or dishes...',
                    hintStyle: const MaterialStatePropertyAll(
                      TextStyle(fontStyle: FontStyle.italic, wordSpacing: 0.6, letterSpacing: 0.3),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuScreen(snap: snapshot.data!.docs[index].data(),),
                          ),
                        ),
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
                            gradient: const LinearGradient(
                              colors: [lightGreen, lightGreen, Colors.white, Colors.white],
                              stops: [0.0, 0.8, 0.8, 1],
                              end: Alignment.bottomCenter,
                              begin: Alignment.topCenter,
                            ),
                            // color: lightGreen,
                          ),
                          height: 280,
                          width: MediaQuery.of(context).size.width,
                          child: Stack(
                            children: [
                              Container(
                                alignment: const Alignment(-0.92, 0.88),
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
                              const Center(
                                child: Icon(Icons.restaurant_menu),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: snapshot.data!.docs.length,
                ),
              )
            ],
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}
