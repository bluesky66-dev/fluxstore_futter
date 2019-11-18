import 'package:flutter/material.dart';
import '../services/index.dart';
import '../common/constants.dart';

class CategoryModel with ChangeNotifier {
  Services _service = Services();
  List<Category> categories;
  Map<int, Category> categoryList = {};

  bool isLoading = true;
  String message;

  void getCategories() async {
    try {
      categories = await _service.getCategories();
      isLoading = false;

      for(Category cat in categories) {
        categoryList[cat.id] = cat;
      }

      print(categories);
      notifyListeners();
    } catch (err) {
      isLoading = false;
      message = err.toString();
      notifyListeners();
    }
  }
}

class Category {
  int id;
  String name;
  String image;
  int parent;
  int totalProduct;

  Category.fromJson(Map<String, dynamic> parsedJson) {

    if (parsedJson["slug"] == 'uncategorized') {
      return;
    }

    id = parsedJson["id"];
    name = parsedJson["name"];
    parent = parsedJson["parent"];
    totalProduct = parsedJson["count"];

    final image = parsedJson["image"];
    if (image != null) {
      this.image = image["src"];
    } else {
      this.image = kDefaultImage;
    }
  }

  @override
  String toString() => 'Category { id: $id  name: $name}';
}
