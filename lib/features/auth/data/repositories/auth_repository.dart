// lib/features/auth/data/repositories/auth_repository.dart
import 'package:atomicoat_17th_version/core/utils/logger.dart';
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
      AppLogger.debug('Fetching user data for uid: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        AppLogger.warning('No document exists for uid: $uid');
        return null;
      }

      final data = doc.data();
      if (data == null) {
        AppLogger.warning('Document data is null for uid: $uid');
        return null;
      }

      AppLogger.debug('Raw user data: $data');
      return UserModel(
        id: doc.id,
        email: data['email'] as String,
        name: data['name'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == (data['role'] as String? ?? 'user'),
          orElse: () => UserRole.user,
        ),
        status: UserStatus.values.firstWhere(
          (e) => e.toString().split('.').last == (data['status'] as String? ?? 'pending'),
          orElse: () => UserStatus.pending,
        ),
        machineId: data['machineId'] as String,
        createdAt: data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error getting user data', e, stackTrace);
      return null;
    }
  }

  Future<UserModel> registerUser(
      String email, String password, String name, String machineSerial) async {
    try {
      AppLogger.info('Starting user registration for email: $email');
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
      AppLogger.debug('Found machine with ID: $machineId');

      // Create user document with proper data types
      final userData = {
        'email': email,
        'name': name,
        'role': UserRole.user.toString().split('.').last,
        'status': UserStatus.pending.toString().split('.').last,
        'machineId': machineId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user account');
      }

      AppLogger.debug('Created auth user with uid: ${userCredential.user!.uid}');

      // Update the user document with the auth UID
      userData['id'] = userCredential.user!.uid;

      AppLogger.debug('Creating user document with data: $userData');
      await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);
      AppLogger.info('User document created successfully');

      // Get the created document to return the proper UserModel
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        throw Exception('Failed to create user document');
      }

      final data = userDoc.data();
      if (data == null) {
        throw Exception('User document is empty');
      }

      AppLogger.debug('Retrieved user document data: $data');
      // Ensure all required fields are present
      final userModel = UserModel(
        id: userDoc.id,
        email: data['email'] as String,
        name: data['name'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == (data['role'] as String? ?? 'user'),
          orElse: () => UserRole.user,
        ),
        status: UserStatus.values.firstWhere(
          (e) => e.toString().split('.').last == (data['status'] as String? ?? 'pending'),
          orElse: () => UserStatus.pending,
        ),
        machineId: data['machineId'] as String,
        createdAt: data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );

      AppLogger.debug('Created UserModel: ${userModel.toJson()}');
      return userModel;
    } catch (e, stackTrace) {
      AppLogger.error('Error during registration', e, stackTrace);
      rethrow;
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      AppLogger.info('Attempting to sign in user: $email');

      // First try to sign in
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        AppLogger.warning('Sign in successful but no user returned');
        return null;
      }

      AppLogger.debug('User signed in successfully, fetching user data');

      // Then fetch the user data
      final userData = await getUserData(userCredential.user!.uid);
      if (userData == null) {
        AppLogger.warning('User document not found for uid: ${userCredential.user!.uid}');
        // Sign out the user since we don't have their data
        await _auth.signOut();
        throw Exception('User data not found. Please contact support.');
      }

      AppLogger.info('User signed in and data retrieved successfully');
      return userData;
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Firebase Auth Error during sign in', e, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Error signing in', e, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      AppLogger.info('Signing out user');
      await _auth.signOut();
      AppLogger.info('User signed out successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error signing out', e, stackTrace);
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
