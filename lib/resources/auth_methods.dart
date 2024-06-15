import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //SIGNIN WITH GOOGLE

  Future<String> signInWithGoogle() async {
    String res = 'Some error occured';
    final GoogleSignInAccount? googleUser;
    try {
      googleUser = await GoogleSignIn().signIn();
    } on Exception catch (e) {
      return e.toString();
    }

    if (googleUser != null) {
      try {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        final User? user = userCredential.user;

        if (user != null) {
          String? token;
          final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
          token = await firebaseMessaging.getToken();
          //LOG IN
          if (await FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((snap) => snap.exists)) {
            await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
              {'fcmToken': token},
            );
            return 'success';
          }

          //SIGN UP
          final String? displayName = user.displayName;
          final String email = user.email ?? '';
          final String? phoneNumber = user.phoneNumber;

          final userData = {
            'name': displayName,
            'email': email,
            'phone': phoneNumber,
            'addressList': [],
            'fcmToken': token,
          };

          final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

          await userRef.set(userData, SetOptions(merge: true));
        }
        res = 'success';
      } on Exception catch (e) {
        return e.toString();
      }
    } else {
      return 'not selected';
    }
    return res;
  }

  //SIGN UP USER
  Future<String> signUpUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    String res = "Some error occured";
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    try {
      if (name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty && password.isNotEmpty) {
        //REGISTER USER
        UserCredential? cred;
        String? token;
        try {
          cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
          token = await firebaseMessaging.getToken();
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            try {
              cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
              token = await firebaseMessaging.getToken();
            } on FirebaseAuthException catch (e) {
              return e.message ?? e.code;
            }
          } else {
            return e.message ?? e.toString();
          }
        }

        await _firestore.collection('users').doc(cred.user!.uid).set({
          'name': name,
          'email': email,
          'phone': '+91$phone',
          'password': password,
          'addressList': [],
          'fcmToken': token,
        });
        res = "success";
      } else {
        res = "Please enter all fields";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //GET USER NAME AND EMAIL BY USING UID
  //FOR FIRST LOGIN
  //GETTING USER DATA FROM DATABASE USING THEIR UID . WE CAN GET THEIR UID AS A RESPONSE OF THEIR SUCCESSFULL LOGIN
  //FOR AUTO LOGIN
  //IF WE WILL APPLY AUTO LOGIN METHOD THEN GENERATE TOKEN USING THEIR UID DURING FIRST LOGIN AND STORE TOKEN
  //IN THEIR LOCAL STORAGE SO THAT NO NEED FOR LOGIN AGAIN AND AGAIN AUTHENTICATE USER BY THAT TOKEN ALSO GET
  //UID FROM TOKEN IF TOKEN EXPERIED THEN NEED TO LOGIN AGAIN AND REGENRATE TOKENS
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('users').doc(uid).get();

      if (snapshot.exists) {
        // Get username and email directly from the DocumentSnapshot
        // String? name = snapshot.get('name');
        // String? email = snapshot.get('email');
        // String? phone = snapshot.get('phone');
        // String? password = snapshot.get('password');
        // String? address = snapshot.data()!['address'] ?? 'Add Address';
        // List<Map<String, dynamic>> addressList = [{}];
        // if (snapshot.data()!['addressList'] != null) {
        //   addressList = List<Map<String, dynamic>>.from(snapshot.data()!['addressList']);
        // }
        // print(addressList);
        Map<String, dynamic> userData = snapshot.data()!;
        return userData;
      } else {
        return null;
        // Document does not exist
      }
    } catch (error) {
      print('Getting error during fetching data: $error');
      return null;
    }
  }

  //LOGIN USER
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        if (await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get()
            .then((snap) => snap.exists)) {
          String? token = await FirebaseMessaging.instance.getToken();
          await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).update(
            {'fcmToken': token},
          );
          res = "success";
        } else {
          return 'Please Sign Up first';
        }
      } else {
        res = "Please enter all fields";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //LOGOUT USER
  Future<String> logoutUser() async {
    String res = 'Some error occured';
    try {
      await _auth.signOut();
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // HERE THE CONCEPT OF PHONE OTP VERIFICATION
  // phoneNumber format should be in this form = '+916667778885'
  Future<String> sendOtp(String phoneNumber) async {
    String verifyId = '';
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String autoVerificationId) {
          // Handle the automatic code retrieval timeout
          //this method will be autometically called when time limit exeed 1 minute
          //in ui write a code here to resend otp
          //and give a dynamic button here resend otp named and on press resendOtp call this same function again()
          print("Auto Retrieval Timeout");
        },
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Handle the verification completed event
          //in android this will be called autometically no need to enter otp to user
          //this worked in android only. if u want user android user enter otp , then remove this function
          print("Verification Completed");
          await FirebaseAuth.instance.signInWithCredential(credential);
          //navigate user to main screen
          print("User signed in");
        },
        verificationFailed: (FirebaseAuthException e) {
          // Handle the verification failed event
          //wrong phone no or SMS quota has been exceeded.
          print("Verification Failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          // Handle the code sent event
          //verification id that we are getting here store in a variable and use when verifyOtp() function called
          print("Code Sent: $verificationId");
          //now show here otp screen to user
          verifyId = verificationId;
        },
      );
    } catch (e) {
      print("Error: $e");
    }
    return verifyId;
  }
  //FIRST STEP SEND OTP AND GET VERIFICATION ID

  //otp screen function
  // by upper function we will get an verification id and now navigate to otp screen with
  //give varification id to otp screen
  //now navigate to the otp screen with otp verificationId
  Future<void> verifyOtp(String otp, String verificationId) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      //here navigate user to the main home screen on success
      print("User signed in");
    } catch (e) {
      //show in ui wrong otp
      print("Error: $e");
    }
  }
  //SECOND STEP VERIFY OTP WITH OTP AND VERIFICATION ID

//FUNCTION TO UPDATE DATA
//send data in form of key value line {
//   'email':abc@getMaxListeners.com,
//   'phone':'phonenumber'
// } to this function
  Future<String> updateUserData(String uid, Map<String, dynamic> dataToUpdate) async {
    String res = 'Some error occured';
    try {
      await _firestore.collection('users').doc(uid).update(dataToUpdate);
      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //DELETE USER
  Future<String> deleteUser(
      // required String email,
      // required String password,
      ) async {
    String res = 'Some error occured';
    try {
      User? curr = _auth.currentUser!;
      await curr.delete();
      await _firestore.collection('users').doc(curr.uid).delete();
      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //PLACE ORDER
  Future<String> addActiveOrder({
    required String resName,
    required List<String> orders,
    required List<String> prices,
    required double total,
    required double grdTotal,
    required double toPay,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String resUid,
    required String resAddress,
    required double gst,
    required double deliveryFee,
    required double platformFee,
    required double latitude,
    required double longitude,
    required Map<String, dynamic> couponApplied,
  }) async {
    String res = 'Some error occured';
    Random rnd = Random();
    int id = rnd.nextInt(900) + 100;
    int adminPin = rnd.nextInt(9000) + 1000;
    int customerPin = rnd.nextInt(9000) + 1000;
    try {
      User? curr = _auth.currentUser!;
      String? uuid = const Uuid().v4();
      DateTime datePlaced = DateTime.now();
      await _firestore.collection('orders').doc(uuid).set({
        'uid': curr.uid,
        'resName': resName,
        'resUid': resUid,
        'orders': orders,
        'prices': prices,
        'total': total,
        'grdTotal': grdTotal,
        'toPay': toPay,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'datePlaced': datePlaced,
        'orderId': uuid,
        'assigned': false,
        'resAddress': resAddress,
        'requested': false,
        'gst': gst,
        'platformFee': platformFee,
        'deliveryFee': deliveryFee,
        'active': true,
        'displayStatus': 'Order Placed',
        'lat': latitude,
        'lng': longitude,
        'OrderId': 'JLD${id.toString()}',
        'AdminPin': adminPin.toString(),
        'CustomerPin': customerPin.toString(),
        'confirmPickup': false,
        'confirmDelivery': false,
        'couponApplied': couponApplied,
        'preparing': false,
      });
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({'activeOrder': true});
      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
