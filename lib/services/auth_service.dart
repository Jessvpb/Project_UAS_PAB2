import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    String role = 'user',
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'phoneNumber': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'role': role,
        });
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', value);
  }

  Future<bool> isRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('remember_me') ?? false;
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remember_me');
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<void> toggleFavorite(String uid, String productId) async {
    final favoriteRef = _firestore.collection('users').doc(uid).collection('favorites').doc(productId);
    final doc = await favoriteRef.get();
    if (doc.exists) {
      await favoriteRef.delete();
    } else {
      await favoriteRef.set({'productId': productId, 'addedAt': FieldValue.serverTimestamp()});
    }
  }

  Future<bool> isFavorite(String uid, String productId) async {
    final doc = await _firestore.collection('users').doc(uid).collection('favorites').doc(productId).get();
    return doc.exists;
  }

  Future<void> addToCart(String uid, String productId, int quantity) async {
    final cartRef = _firestore.collection('users').doc(uid).collection('cart').doc(productId);
    await cartRef.set({
      'productId': productId,
      'quantity': quantity,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCartQuantity(String uid, String productId, int quantity) async {
    final cartRef = _firestore.collection('users').doc(uid).collection('cart').doc(productId);
    await cartRef.update({'quantity': quantity});
  }

  Future<void> removeFromCart(String uid, String productId) async {
    final cartRef = _firestore.collection('users').doc(uid).collection('cart').doc(productId);
    await cartRef.delete();
  }

  Future<List<Map<String, dynamic>>> getCartItems(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> placeOrder(String uid, List<Map<String, dynamic>> cartItems, String address, String paymentMethod) async {
    final orderRef = _firestore.collection('orders').doc();
    double total = 0;
    for (var item in cartItems) {
      final productDoc = await _firestore.collection('aki_products').doc(item['productId']).get();
      if (productDoc.exists) {
        final price = productDoc.data()?['price'] ?? 0;
        total += price * item['quantity'];
      }
    }
    await orderRef.set({
      'userId': uid,
      'items': cartItems,
      'status': 'pending',
      'orderDate': FieldValue.serverTimestamp(),
      'total': total,
      'address': address,
      'paymentMethod': paymentMethod,
    });
    final batch = _firestore.batch();
    final cartSnapshot = await _firestore.collection('users').doc(uid).collection('cart').get();
    for (var doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> addReview(String productId, int rating, String comment, String userId, double latitude, double longitude) async {
    await _firestore.collection('reviews').doc('$productId-$userId').set({
      'productId': productId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getReviews(String productId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}