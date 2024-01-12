import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //SIGN UP USER
  Future<String> signUpUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    String res = "Some error occured";
    try {
      if (name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty && password.isNotEmpty) {
        //REGISTER USER
        UserCredential cred =
            await _auth.createUserWithEmailAndPassword(email: email, password: password);

        await _firestore.collection('users').doc(cred.user!.uid).set({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
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
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(uid).get();

      if (snapshot.exists) {
        // Get username and email directly from the DocumentSnapshot
        String? name = snapshot.get('name');
        String? email = snapshot.get('email');
        Map<String, dynamic> userData = {
          'name': name,
          'email': email,
        };
        return userData;
      } else {
        return null; // Document does not exist
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
        res = "success";
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
  
  //FIRST STEP SEND OTP AND GET VERIFICATION ID
  
  //SECOND STEP VERIFY OTP WITH OTP AND VERIFICATION ID 
  
  //THIRD STEP IF VERIFIED THEN NAVIGATE USER TO MAIN SCREEN IF PHONE NUMBER ALREADY EXIST 
  //IF NOT EXIST THEN TAKE INPUT THEIR USERNAME ALSO

  
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
}
