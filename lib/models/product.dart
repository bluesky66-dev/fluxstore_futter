import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../common/constants.dart';
import '../screens/products.dart';
import '../services/index.dart';
import 'app.dart';

class ProductModel with ChangeNotifier {
  Services _service = Services();
  List<List<Product>> products;
  String message;

  /// current select product id/name
  int categoryId;
  String categoryName;

  //list products for products screen
  bool isFetching = false;
  List<Product> productsList;
  String errMsg;
  bool isEnd;

  ProductVariation productVariation;

  changeProductVariation(ProductVariation variation) {
    productVariation = variation;
    notifyListeners();
  }

  Future<List<Product>> fetchProductLayout(config, lang) async {
    return await _service.fetchProductsLayout(config: config, lang: lang);
  }

  void fetchProductsByCategory({categoryId, categoryName}) {
    this.categoryId = categoryId;
    this.categoryName = categoryName;
    notifyListeners();
  }

  void saveProducts(Map<String, dynamic> data) async {
    final LocalStorage storage = new LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey["home"], data);
      }
    } catch (err) {
      print(err);
    }
  }

  void getProductsList({categoryId, minPrice, maxPrice, orderBy, order, lang, page}) async {
    try {
      if (categoryId != null) {
        this.categoryId = categoryId;
      }
      isFetching = true;
      isEnd = false;
      notifyListeners();

      final products = await _service.fetchProductsByCategory(
          categoryId: categoryId,
          minPrice: minPrice,
          maxPrice: maxPrice,
          orderBy: orderBy,
          order: order,
          lang: lang,
          page: page);
      if (products.isEmpty) {
        isEnd = true;
      }

      if (page == 0 || page == 1) {
        productsList = products;
      } else {
        productsList = []..addAll(productsList)..addAll(products);
      }
      isFetching = false;
      notifyListeners();
    } catch (err) {
      errMsg = err.toString();
      isFetching = false;
      notifyListeners();
    }
  }

  void setProductsList(products) {
    productsList = products;
    isFetching = false;
    isEnd = false;
    notifyListeners();
  }
}

class Product {
  int id;
  String sku;
  String name;
  String description;
  String permalink;
  String price;
  String regularPrice;
  String salePrice;
  bool onSale;
  bool inStock;
  double averageRating;
  double ratingCount;
  List<String> images;
  String imageFeature;
  List<ProductAttribute> attributes;
  int categoryId;

  Product.empty(int id) {
    this.id = id;
    name = 'Loading...';
    price = '0.0';
    imageFeature = '';
  }

  bool isEmptyProduct() {
    return name == 'Loading...' && price == '0.0' && imageFeature == '';
  }

  Product.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    name = parsedJson["name"];
    description = parsedJson["description"];
    permalink = parsedJson["permalink"];
    price = parsedJson["price"] == 0 ? 10 : parsedJson["price"];

    regularPrice = parsedJson["regular_price"];
    salePrice = parsedJson["sale_price"];
    onSale = parsedJson["on_sale"];
    inStock = parsedJson["in_stock"];

    averageRating = double.parse(parsedJson["average_rating"]);
    ratingCount = double.parse(parsedJson["rating_count"].toString());
    categoryId = parsedJson["categories"] != null && parsedJson["categories"].length > 0
        ? parsedJson["categories"][0]["id"]
        : 0;

    List<ProductAttribute> attributeList = [];
    parsedJson["attributes"].forEach((item) {
      attributeList.add(ProductAttribute.fromJson(item));
    });
    attributes = attributeList;

    List<String> list = [];
    for (var item in parsedJson["images"]) {
      list.add(item["src"]);
    }
    images = list;
    imageFeature = images[0];
  }

  /// Show the product list
  static showList({cateId, cateName, context, List<Product> products, config}) {
    var categoryId = cateId ?? config['category'];
    var categoryName = cateName ?? config['name'];
    final product = Provider.of<ProductModel>(context);

    print(products);

    // for caching current products list
    if (products != null) {
      product.setProductsList(products);
      return Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProductsPage(products, categoryId)));
    }

    // for fetching beforehand
    product.fetchProductsByCategory(categoryId: categoryId, categoryName: categoryName);
    product.setProductsList(List<Product>()); //clear old products
    product.getProductsList(
      categoryId: categoryId,
      page: 1,
      lang: Provider.of<AppModel>(context).locale,
    );

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProductsPage(products ?? [], categoryId)));

//    if (isMagic) {
//      Navigator.push(context,
//          MaterialPageRoute(builder: (context) => MagicScreen(products, categoryId, imageBanner)));
//    } else {
//      /// if the products list is not full just go straightaway
//      Navigator.push(
//          context, MaterialPageRoute(builder: (context) => ProductsPage(products, categoryId)));
//    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sku": sku,
      "name": name,
      "description": description,
      "permalink": permalink,
      "price": price,
      "regularPrice": regularPrice,
      "salePrice": salePrice,
      "onSale": onSale,
      "inStock": inStock,
      "averageRating": averageRating,
      "ratingCount": ratingCount,
      "images": images,
      "imageFeature": imageFeature,
      "attributes": attributes,
      "categoryId": categoryId
    };
  }

  Product.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      sku = json['sku'];
      name = json['name'];
      description = json['description'];
      permalink = json['permalink'];
      price = json['price'];
      regularPrice = json['regularPrice'];
      salePrice = json['salePrice'];
      onSale = json['onSale'];
      inStock = json['inStock'];
      averageRating = json['averageRating'];
      ratingCount = json['ratingCount'];
      List<String> imgs = [];
      for (var item in json['images']) {
        imgs.add(item);
      }
      images = imgs;
      imageFeature = json['imageFeature'];
      List<ProductAttribute> attrs = [];
      for (var item in json['attributes']) {
        attrs.add(ProductAttribute.fromLocalJson(item));
      }
      attributes = attrs;
      categoryId = json['categoryId'];
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  String toString() => 'Product { id: $id name: $name }';
}

class ProductAttribute {
  int id;
  String name;
  List options;

  ProductAttribute.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    name = parsedJson["name"];
    options = parsedJson["options"];
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "options": options};
  }

  ProductAttribute.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      name = json['name'];
      options = json['options'];
    } catch (e) {
      print(e.toString());
    }
  }
}

class Attribute {
  int id;
  String name;
  String option;

  Attribute();

  Attribute.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    name = parsedJson["name"];
    option = parsedJson["option"];
  }
}

class ProductVariation {
  int id;
  String price;
  String regularPrice;
  String salePrice;
  bool onSale;
  bool inStock;
  String imageFeature;
  List<Attribute> attributes = [];

  ProductVariation();

  ProductVariation.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    price = parsedJson["price"];
    regularPrice = parsedJson["regular_price"];
    salePrice = parsedJson["sale_price"];
    onSale = parsedJson["on_sale"];
    inStock = parsedJson["in_stock"];
    imageFeature = parsedJson["image"]["src"];

    List<Attribute> attributeList = [];
    parsedJson["attributes"].forEach((item) {
      attributeList.add(Attribute.fromJson(item));
    });
    attributes = attributeList;
  }
}
