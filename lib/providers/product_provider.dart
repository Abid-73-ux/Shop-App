import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _selectedCategory = 'All';

  List<Product> get products => _filteredProducts;
  String get selectedCategory => _selectedCategory;

  ProductProvider() {
    _initializeProducts();
  }

  void _initializeProducts() {
    _products = [
      Product(
        id: '1',
        name: 'Fresh Apples',
        description: 'Crisp and juicy apples',
        price: 5.99,
        category: 'Fruits',
        imageUrl: 'https://via.placeholder.com/200?text=Apples',
        stock: 50,
        rating: 4.5,
      ),
      Product(
        id: '2',
        name: 'Organic Milk',
        description: 'Fresh organic milk 1L',
        price: 3.99,
        category: 'Dairy',
        imageUrl: 'https://via.placeholder.com/200?text=Milk',
        stock: 30,
        rating: 4.8,
      ),
      Product(
        id: '3',
        name: 'Whole Wheat Bread',
        description: 'Freshly baked whole wheat bread',
        price: 2.49,
        category: 'Bakery',
        imageUrl: 'https://via.placeholder.com/200?text=Bread',
        stock: 20,
        rating: 4.3,
      ),
      Product(
        id: '4',
        name: 'Tomatoes',
        description: 'Fresh red tomatoes',
        price: 4.49,
        category: 'Vegetables',
        imageUrl: 'https://via.placeholder.com/200?text=Tomatoes',
        stock: 45,
        rating: 4.6,
      ),
      Product(
        id: '5',
        name: 'Orange Juice',
        description: 'Fresh squeezed orange juice 1L',
        price: 4.99,
        category: 'Beverages',
        imageUrl: 'https://via.placeholder.com/200?text=OJ',
        stock: 25,
        rating: 4.4,
      ),
    ];
    _filteredProducts = _products;
  }

  List<String> getCategories() {
    return ['All', ...{..._products.map((p) => p.category)}];
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    if (category == 'All') {
      _filteredProducts = _products;
    } else {
      _filteredProducts = _products.where((p) => p.category == category).toList();
    }
    notifyListeners();
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      filterByCategory(_selectedCategory);
    } else {
      _filteredProducts = _products
          .where((p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) &&
              (_selectedCategory == 'All' || p.category == _selectedCategory))
          .toList();
    }
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
