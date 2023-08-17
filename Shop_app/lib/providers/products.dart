import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import './product.dart';
class Products with ChangeNotifier {
  final String authToken;
  final String userId;
  List<Product> _items = [];
  Products(this.authToken,this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favouriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  Product findById(String id){
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse('https://shop-a26a6-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken&$filterString');
    try{
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String,dynamic>;
      final  List<Product> loadedProducts = [];
      if(extractedData == null){
        return;
      }
      final url1 = Uri.parse('https://shop-a26a6-default-rtdb.asia-southeast1.firebasedatabase.app/userFavourites/$userId.json?auth=$authToken');
      final favouriteResponse = await http.get(url1);
      final favouriteData = json.decode(favouriteResponse.body);
      extractedData.forEach((prodId,prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavourite: favouriteData == null ? false : favouriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    }catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    // sending a http request to add a new product to a server database using flutter.
    final url = Uri.parse('https://shop-a26a6-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode(
            {
              'title': product.title,
              'description': product.description,
              'price': product.price,
              'imageUrl': product.imageUrl,
              'creatorId': userId,
            }
        ),
      );

      final _newProduct = Product(
        title: product.title,
        imageUrl: product.imageUrl,
        price: product.price,
        description: product.description,
        id: json.decode(response.body)['name'],
      );
      _items.add(_newProduct);
      //_items.insert(0,_newProduct); // to insert the product at the beginning of list.
      notifyListeners();

    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String productId, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == productId);
    if(prodIndex >=0 ){
      final url = Uri.parse('https://shop-a26a6-default-rtdb.asia-southeast1.firebasedatabase.app/products/$productId.json?auth=$authToken');
      await http.patch(
        url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'price': newProduct.price,
          'imageUrl': newProduct.imageUrl,
        })
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse('https://shop-a26a6-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if(response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HTTPException('Could not delete product.');
    }
    existingProduct = null;
  }

}