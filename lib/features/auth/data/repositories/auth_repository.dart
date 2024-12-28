// lib/features/auth/data/repositories/auth_repository.dart
import 'package:atomicoat_17th_version/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<UserModel> registerUser(
      String email, String password, String name, String machineSerial) async {
    // First verify machine exists and is active
    final machineQuery = await _firestore
        .collection('machines')
        .where('serialNumber', isEqualTo: machineSerial)
        .where('status', isEqualTo: 'active')
        .get();

    if (machineQuery.docs.isEmpty) {
      throw Exception('Invalid or inactive machine serial number');
    }

    final machineId = machineQuery.docs.first.id;

    // Create auth user
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Create user document
    final user = UserModel(
      id: userCredential.user!.uid,
      email: email,
      name: name,
      role: UserRole.user,
      status: UserStatus.pending,
      machineId: machineId,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.id).set(user.toJson());

    return user;
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        return await getUserData(userCredential.user!.uid);
      }
      return null;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  Future<void> approveUser(String userId, UserRole assignedRole) async {
    final batch = _firestore.batch();

    final userRef = _firestore.collection('users').doc(userId);
    batch.update(userRef, {
      'status': UserStatus.active.toString().split('.').last,
      'role': assignedRole.toString().split('.').last
    });

    final userDoc = await userRef.get();
    final machineId = userDoc.data()?['machineId'];

    final machineRef = _firestore.collection('machines').doc(machineId);
    batch.update(machineRef, {
      'authorizedUsers': FieldValue.arrayUnion([userId])
    });

    await batch.commit();
  }
}
