import 'package:cloud_firestore/cloud_firestore.dart';

class SearchMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, String>> getAllRestaurantData() async {
    Map<String, String> restaurantData = {};

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('restaurants').where('legit', isEqualTo: true).get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        restaurantData[data['name']] = doc.id;
      }
    } catch (e) {
      print("Error retrieving restaurant data: $e");
    }

    return restaurantData;
  }

  Future<List<Map<String, dynamic>>> getFoodItems(String restaurantId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> restaurantDoc =
          await _firestore.collection('restaurants').doc(restaurantId).get();
      print('filtered ${restaurantDoc.exists}');

      if (restaurantDoc.exists) {
        print('filtered ${restaurantDoc.exists} again');
        List<Map<String, dynamic>> foodList = List.from(restaurantDoc.data()!['foodlist']);
        print('filtered ${foodList.length}');
        return foodList;
      } else {
        print("Restaurant document not found for ID: $restaurantId");
        return [];
      }
    } catch (e) {
      print("Error retrieving food items: $e");
      return [];
    }
  }
}
