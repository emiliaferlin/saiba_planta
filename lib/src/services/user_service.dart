import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trabalho_final/src/model/user_model.dart';

class UserService {
  final CollectionReference _users = FirebaseFirestore.instance.collection(
    'users',
  );

  Future<UserModel> getUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userDoc = await _users.doc(currentUser?.uid).get();
    return UserModel.fromDocument(userDoc);
  }
}
