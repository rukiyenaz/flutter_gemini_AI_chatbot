import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/features/auth/domain/entities/app_user.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepository{
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  @override
  Future<AppUser?> getCurrentUser() async{
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null){
      return null;
    }
     
     return AppUser(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? "",
      email: firebaseUser.email ?? "",
    );
  }

  @override
  Future<void> resetPassword(String email) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }

  @override
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    try{
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      //create user
      AppUser user = AppUser(
        id: userCredential.user!.uid,
        name: "",
        email: email,
      );
      return user;
    }
    catch(e){
      print(e.toString());
      return null;
    }
    
  }

  @override
  Future<void> signOut() async{
    try{
      await _firebaseAuth.signOut();
    }
    catch(e){
      print(e.toString());
    }
  }

  @override
  Future<AppUser?> signUpWithEmailAndPassword(String name,String email, String password) async{
    try{
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      //create user
      AppUser user = AppUser(
        id: userCredential.user!.uid,
        name: name,
        email: email,
      );
      return user;
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }
  
}