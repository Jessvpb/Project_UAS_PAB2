import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:akiflash/services/auth_service.dart';
import 'package:geolocator/geolocator.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isLoading = false;
  String? errorMessage;
  bool rememberMe = false;

  void setRememberMe(bool value) {
    rememberMe = value;
    _authService.saveRememberMe(value);
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    String role = 'user',
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.registerWithEmail(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
        role: role,
      );
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.loginWithEmail(email, password);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> checkLoginStatus() async {
    final user = _authService.getCurrentUser();
    final rememberMe = await _authService.isRememberMe();
    return user != null && rememberMe;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      return await _authService.getUserData(user.uid);
    }
    return null;
  }

  User? getCurrentUser() {
    return _authService.getCurrentUser();
  }

  Future<void> updateUserData({
    required String name,
    required String phoneNumber,
  }) async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      await _authService.updateUserData(user.uid, {
        'name': name,
        'phoneNumber': phoneNumber,
      });
    }
  }

  Future<bool> isAdmin() async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      final userData = await getUserData();
      return userData?['role'] == 'admin' ?? false;
    }
    return false;
  }

  Future<void> toggleFavorite(String productId) async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      await _authService.toggleFavorite(user.uid, productId);
      notifyListeners();
    }
  }

  Future<bool> isFavorite(String productId) async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      return await _authService.isFavorite(user.uid, productId);
    }
    return false;
  }

  Future<void> addToCart(String productId, int quantity) async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      await _authService.addToCart(user.uid, productId, quantity);
      notifyListeners();
    }
  }

  Future<void> updateCartQuantity(String productId, int quantity) async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      await _authService.updateCartQuantity(user.uid, productId, quantity);
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String productId) async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      await _authService.removeFromCart(user.uid, productId);
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      return await _authService.getCartItems(user.uid);
    }
    return [];
  }

  Future<void> placeOrder(
    String address,
    String paymentMethod, {
    required String phoneNumber,
    String? notes,
  }) async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      final cartItems = await getCartItems();
      await _authService.placeOrder(
        user.uid,
        cartItems,
        address,
        paymentMethod,
      );
      notifyListeners();
    }
  }

  Future<void> addReview(
    String productId,
    int rating,
    String comment,
    double latitude,
    double longitude,
  ) async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      await _authService.addReview(
        productId,
        rating,
        comment,
        user.uid,
        latitude,
        longitude,
      );
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getReviews(String productId) async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      return await _authService.getReviews(productId);
    }
    return [];
  }

  Future<Position> getCurrentLocation() async {
    return await _authService.getCurrentLocation();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
