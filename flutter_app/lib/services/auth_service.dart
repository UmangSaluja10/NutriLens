import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db   = FirebaseFirestore.instance;

  static Stream<User?> get authStateChanges =>
      _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;
  static String? get currentUid => _auth.currentUser?.uid;

  static Future<UserProfile> signUp({
    required String email,
    required String password,
    required String name,
    required String gender,          // ← NEW
    required double heightCm,
    required double weightKg,
    required String bodyType,
    required String activityLevel,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final uid = cred.user!.uid;

    final temp = UserProfile(
      uid: uid,
      name: name,
      email: email,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      bodyType: bodyType,
      activityLevel: activityLevel,
    );

    // Auto-set protein limit from recommendation
    final profile =
        temp.copyWith(dailyProteinLimit: temp.recommendedProtein);

    await _db
        .collection('users')
        .doc(uid)
        .set(profile.toFirestore());
    return profile;
  }

  static Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return getUserProfile(cred.user!.uid);
  }

  static Future<void> signOut() async => _auth.signOut();

  static Future<UserProfile> getUserProfile(String uid) async {
    final doc =
        await _db.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('Profile not found');
    return UserProfile.fromFirestore(doc.data()!, uid);
  }

  static Future<void> updateProfile(UserProfile profile) async {
    await _db
        .collection('users')
        .doc(profile.uid)
        .update(profile.toFirestore());
  }
}