import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStream => _auth.authStateChanges();

  static Future<UserCredential?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<void> saveUserProfile({
    required String goal,
    required String level,
    required String hoursPerDay,
    String? name,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'goal': goal,
      'level': level,
      'hoursPerDay': hoursPerDay,
      'name': name ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'streak': 1,
      'lastActiveDate': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }


  static Future<void> updateGoalAndLevel({
    required String goal,
    required String level,
    required String hoursPerDay,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'goal': goal,
      'level': level,
      'hoursPerDay': hoursPerDay,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> resetRoadmap() async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'roadmap': FieldValue.delete(),
      'completedTopics': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> saveRoadmap(List<Map<String, dynamic>> roadmap) async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'roadmap': roadmap,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
  static Future<List<Map<String, dynamic>>?> getRoadmap() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null || data['roadmap'] == null) return null;

    final rawList = data['roadmap'] as List;
    return rawList.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      if (map['tags'] != null) {
        map['tags'] = List<String>.from((map['tags'] as List).map((e) => e.toString()));
      }
      return map;
    }).toList();
  }

  static Future<void> saveProgress({
    required int completedTopics,
    required List<Map<String, dynamic>> roadmap,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'completedTopics': completedTopics,
      'roadmap': roadmap,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<int> getCompletedTopics() async {
    final uid = currentUser?.uid;
    if (uid == null) return 0;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['completedTopics'] ?? 0;
  }

  static Future<int> updateStreak() async {
    final uid = currentUser?.uid;
    if (uid == null) return 1;
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return 1;

    final lastActive = data['lastActiveDate'] as String?;
    int streak = data['streak'] ?? 1;

    if (lastActive != null) {
      final last = DateTime.parse(lastActive);
      final now = DateTime.now();
      final diff = now.difference(last).inDays;
      if (diff == 1) {
        streak++;
      } else if (diff > 1) {
        streak = 1;
      }
    }

    await _db.collection('users').doc(uid).set({
      'streak': streak,
      'lastActiveDate': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    return streak;
  }
}