import 'package:cloud_firestore/cloud_firestore.dart';

class AkiProduct {
  final String id;
  final String name;
  final double price;
  final double? discount;
  final String imageUrl;
  final String description;
  final String type;

  AkiProduct({
    required this.id,
    required this.name,
    required this.price,
    this.discount,
    required this.imageUrl,
    required this.description,
    required this.type,
  });

  factory AkiProduct.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AkiProduct(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      discount: data['discount']?.toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? '',
    );
  }
}