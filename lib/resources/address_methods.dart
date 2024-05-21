import 'package:cloud_firestore/cloud_firestore.dart';

class AddressMethods {
  Future<String> addNewAddress(
    String userUID,
    Map<String, dynamic> newAddress,
  ) async {
    String res = "Some error occured";
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userUID);

      //DEFAULT ADDRESS IF FIRST
      await docRef.get().then((userMap) {
        if (userMap['addressList'] == null) {
          docRef.update({
            'address':
                "${newAddress['label']}: ${newAddress['address']}${newAddress['landmark'] == '' ? '' : ', ${newAddress['landmark']}'}",
            'defaultAddress': 0,
          });
        } else if (userMap['addressList'].length == 0) {
          docRef.update({
            'address':
                "${newAddress['label']}: ${newAddress['address']}${newAddress['landmark'] == '' ? '' : ', ${newAddress['landmark']}'}",
            'defaultAddress': 0,
          });
        }
      });

      await docRef.update({
        'addressList': FieldValue.arrayUnion([newAddress])
      });

      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> updateAddress(
    String userUID,
    int indexToUpdate,
    Map<String, dynamic> newData,
  ) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userUID);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        return "Document does not exist";
      }

      final data = docSnapshot.data();
      if (!(data!.containsKey('addressList'))) {
        return "address field not found";
      }

      List<dynamic> addresses = List<dynamic>.from(data['addressList']);
      if (indexToUpdate < 0 || indexToUpdate >= addresses.length) {
        return "Index out of range";
      }

      addresses[indexToUpdate] = newData;
      await docRef.update({'addressList': addresses});
      if (indexToUpdate == data['defaultAddress']) {
        docRef.update({
          'address':
              "${newData['label']}: ${newData['address']}${newData['landmark'] == '' ? '' : ', ${newData['landmark']}'}",
        });
      }
      return "success";
    } catch (e) {
      print("Error updating address: $e");
      return "Some error occurred";
    }
  }

  Future<String> deleteAddressItem(
    String userUID,
    int indexToRemove,
  ) async {
    String res = "Some error occurred";
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userUID);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data!.containsKey('addressList')) {
          List<dynamic> addresses = List<dynamic>.from(data['addressList']);
          if (indexToRemove == data['defaultAddress']) {
            docRef.update({'defaultAddress': null, 'address': null});
          } else if (indexToRemove < data['defaultAddress']) {
            docRef.update({'defaultAddress': data['defaultAddress'] - 1});
          }
          if (indexToRemove >= 0 && indexToRemove < addresses.length) {
            addresses.removeAt(indexToRemove);
            await docRef.update({'addressList': addresses});
            res = "success";
          } else {
            res = "Index out of range";
          }
        } else {
          res = "address field not found";
        }
      } else {
        res = "Document does not exist";
      }
    } catch (e) {
      res = "Error: $e";
    }

    return res;
  }
}
