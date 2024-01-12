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
  Future<void> _sendOtp(String phoneNumber) async {
  try {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      autoRetrievalTimeout: (String autoVerificationId) {
        // Handle the automatic code retrieval timeout
        //this method will be autometically called when time limit exeed 1 minute 
        //in ui write a code here to resend otp
        //and give a dynamic button here send otp named and on press _resendOtp this function will be call
        //make sure verification id updated everywhere
        //make sure u update your verificationId because in _resendOtp() function latest verificationId will be used
        verificationId = autoVerificationId;
        print("Auto Retrieval Timeout");
      },
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Handle the verification completed event
        //in android this will be called autometically no need to enter otp to user
        //this worked in android only. if u want user android user enter otp , then remove this function
        print("Verification Completed");
        await _auth.signInWithCredential(credential);
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
        print("Code Sent: $verificationId");
        //now show here otp screen to user 
        //here we get variable verificationId
      },
    );
  } catch (e) {
    print("Error: $e");
  }
  //FIRST STEP SEND OTP AND GET VERIFICATION ID
    
  //otp screen function
 // by upper function we will get an verification id and now navigate to otp screen with 
  //give varification id to otp screen
  //now navigate to the otp screen with otp verificationId 
Future<void> _verifyOtp(String otp, String verificationId) async {
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
 // on send otp again button clicked(if otp experied)

//FUNCTION TO UPDATE DATA
//send data in form of key value line {
//   'email':abc@getMaxListeners.com,
//   'phone':'phonenumber'
// } to this function
Future<void> updateUserData(String uid, Map<String, dynamic> dataToUpdate) async {
  try {
    await _firestore.collection('users').doc(uid).update(dataToUpdate);
    print('data updated');
  } catch (e) {
    print('Error updating user data: $e');
  }
}


    
Future<void> _resendOtp(verificationId) async {
 //this is new verification id
  if (verificationId.isNotEmpty) {
    try {
      await _auth.resendOtp(
        verificationId: verificationId,  //this is the verification is which we used in otp screen
        timeout: const Duration(seconds: 60),
        codeSent: (String sentVerificationId, int? resendToken) {
          // Handle the code resent event
          print("Code Resent: $sentVerificationId");
          //update verification id
          verificationId = sentVerificationId;
        },
      );
    } catch (e) {
      print("Error: $e");
    }
  }
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
