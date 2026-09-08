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
        description: 'Crisp and juicy apples - Premium quality',
        price: 5.99,
        category: 'Fruits',
        imageUrl:
            'https://images.unsplash.com/photo-1560806647-97c37282514e?w=200&h=200&fit=crop',
        stock: 50,
        rating: 4.5,
      ),
      Product(
        id: '2',
        name: 'Organic Milk',
        description: 'Fresh organic milk 1L - Full fat',
        price: 3.99,
        category: 'Dairy',
        imageUrl:
            'https://images.unsplash.com/photo-1550583874-b592ee89568e?w=200&h=200&fit=crop',
        stock: 30,
        rating: 4.8,
      ),
      Product(
        id: '3',
        name: 'Whole Wheat Bread',
        description: 'Freshly baked whole wheat bread - Soft & healthy',
        price: 2.49,
        category: 'Bakery',
        imageUrl:
            'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=200&h=200&fit=crop',
        stock: 20,
        rating: 4.3,
      ),
      Product(
        id: '4',
        name: 'Fresh Tomatoes',
        description: 'Fresh red tomatoes - Locally grown',
        price: 4.49,
        category: 'Vegetables',
        imageUrl:
            'https://images.unsplash.com/photo-1557804506-669714112fc5?w=200&h=200&fit=crop',
        stock: 45,
        rating: 4.6,
      ),
      Product(
        id: '5',
        name: 'Orange Juice',
        description: 'Fresh squeezed orange juice 1L - No sugar added',
        price: 4.99,
        category: 'Beverages',
        imageUrl:
            'https://images.unsplash.com/photo-1600271886742-f049cd1eada0?w=200&h=200&fit=crop',
        stock: 25,
        rating: 4.4,
      ),
      Product(
        id: '6',
        name: 'Carrots Bundle',
        description: 'Fresh orange carrots - Rich in vitamins',
        price: 3.49,
        category: 'Vegetables',
        imageUrl:
            'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=200&h=200&fit=crop',
        stock: 40,
        rating: 4.4,
      ),
      Product(
        id: '7',
        name: 'Bananas',
        description: 'Sweet and ripe bananas - Perfect for smoothies',
        price: 2.99,
        category: 'Fruits',
        imageUrl:
            'https://images.unsplash.com/photo-1587182612944-4e896e6cf31f?w=200&h=200&fit=crop',
        stock: 60,
        rating: 4.7,
      ),
      Product(
        id: '8',
        name: 'Yogurt',
        description: 'Creamy yogurt 500g - Probiotic rich',
        price: 2.49,
        category: 'Dairy',
        imageUrl:
            'https://images.unsplash.com/photo-1488477181946-6428a0291840?w=200&h=200&fit=crop',
        stock: 35,
        rating: 4.5,
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
