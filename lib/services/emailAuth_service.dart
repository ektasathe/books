

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thrift_books/screens/location_screen.dart';

class EmailAuthentication{

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<DocumentSnapshot> getAdminCredential({email,password,isLog,context})async{
    DocumentSnapshot _result = await users.doc(email).get();

    if(isLog) {
      //direct login
      emailLogin(email, password,context);
    }else{
      //if register
      if(_result.exists){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An account already exist'),
          ),
        );
      }else{
        //register a new user
        emailRegister(email,password,context);
      }
    }

    return _result;
  }
  emailLogin(email,password,context)async{
    //login with already registered email
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      if(userCredential.user.uid != null){
        Navigator.pushReplacementNamed(context, LocationScreen.id);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user found for that email.'),
          ),
        );

      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong password provided for that user.'),
          ),
        );

      }
    }

  }
  emailRegister(email,password,context)async{
    //register as a new user
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      if(userCredential.user.uid != null){
        //login success. Add user data to firestore
        return users.doc(userCredential.user.email).set({
          'uid' : userCredential.user.uid,
          'mobile' : null,
          'email' : userCredential.user.email
        }).then((value) {
          Navigator.pushReplacementNamed(context, LocationScreen.id);
        }).catchError((onError){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add user.'),
            ),
          );
        });
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The password provided is too weak.'),
          ),
        );

      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The account already exists for that email.'),
          ),
        );

      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error occurred'),
        ),
      );
    }

  }

}