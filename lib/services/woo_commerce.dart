import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';
import "dart:core";
import '../models/coupon.dart';
import 'package:http/http.dart' as http;

import '../models/address.dart';
import '../models/cart.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/payment_method.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../models/shipping_method.dart';
import '../models/user.dart';
import 'index.dart';
import 'helper/woocommerce_api.dart';

class WooCommerce implements BaseServices {
  WooCommerceAPI wcApi;
  String isSecure;
  String url;

  WooCommerce.appConfig(appConfig) {
    wcApi = WooCommerceAPI(appConfig["server"]["url"], appConfig["server"]["consumerKey"],
        appConfig["server"]["consumerSecret"]);
    isSecure = appConfig["server"]["url"].indexOf('https') != -1 ? '' : '&insecure=cool';
    url = appConfig["server"]["url"];
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      var response = await wcApi.getAsync("products/categories?&exclude=311&per_page=50");
      List<Category> list = [];
      for (var item in response) {
        list.add(Category.fromJson(item));
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    try {
      var response = await wcApi.getAsync("products");
      List<Product> list = [];
      for (var item in response) {
        list.add(Product.fromJson(item));
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Product>> fetchProductsLayout({config, lang}) async {
    try {
      List<Product> list = [];

      var endPoint = "products?lang=$lang&per_page=10";
      if (config.containsKey("category")) {
        endPoint += "&category=${config["category"]}";
      }
      if (config.containsKey("tag")) {
        endPoint += "&tag=${config["tag"]}";
      }

      var response = await wcApi.getAsync(endPoint);

      for (var item in response) {
        Product product = Product.fromJson(item);
        product.categoryId = config["category"];
        list.add(product);
      }
      return list;
    } catch (e) {
      print('Error: ${e.toString()}');
      throw e;
    }
  }

  @override
  Future<List<Product>> fetchProductsByCategory(
      {categoryId, page, minPrice, maxPrice, orderBy, lang, order}) async {
    try {
      List<Product> list = [];

      var endPoint = "products?lang=$lang&per_page=10&page=$page";
      if (categoryId > -1) {
        endPoint += "&category=$categoryId";
      }
      if (minPrice != null) {
        endPoint += "&min_price=${(minPrice as double).toInt().toString()}";
      }
      if (maxPrice != null && maxPrice > 0) {
        endPoint += "&max_price=${(maxPrice as double).toInt().toString()}";
      }
      if (orderBy != null) {
        endPoint += "&orderby=$orderBy";
      }
      if (order != null) {
        endPoint += "&order=$order";
      }
      var response = await wcApi.getAsync(endPoint);

      for (var item in response) {
        list.add(Product.fromJson(item));
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<User> loginFacebook({String token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint = "$url/api/mstore_user/fb_connect/?second=$cookieLifeTime"
          "&access_token=$token$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['status'] != 'ok') {
        return jsonDecode['msg'];
      }

      return User.fromJsonFB(jsonDecode);
    } catch (e) {
      // print(e.toString());
      throw e;
    }
  }

  @override
  Future<User> loginSMS({String token}) async {
    try {
      var endPoint = "$url/api/mstore_user/sms_login/?access_token=$token$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      return User.fromJsonSMS(jsonDecode);
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  @override
  Future<List<Review>> getReviews(productId) async {
    try {
      var response = await wcApi.getAsync("products/$productId/reviews");
      List<Review> list = [];
      for (var item in response) {
        list.add(Review.fromJson(item));
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<ProductVariation>> getProductVariations(Product product) async {
    try {
      var response = await wcApi.getAsync("products/${product.id}/variations?per_page=20");
      List<ProductVariation> list = [];
      for (var item in response) {
        list.add(ProductVariation.fromJson(item));
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods({Address address, String token}) async {
    try {
      var response = await wcApi.getAsync("shipping_methods");
      List<ShippingMethod> list = [];
      for (var item in response) {
        list.add(ShippingMethod.fromJson(item));
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {Address address, ShippingMethod shippingMethod, String token}) async {
    try {
      var response = await wcApi.getAsync("payment_gateways");
      List<PaymentMethod> list = [];
      for (var item in response) {
        list.add(PaymentMethod.fromJson(item));
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Order>> getMyOrders({UserModel userModel}) async {
    try {
      var response = await wcApi.getAsync("orders?customer=${userModel.user.id}&per_page=20");
      List<Order> list = [];
      for (var item in response) {
        list.add(Order.fromJson(item));
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<Order> createOrder({CartModel cartModel, UserModel user}) async {
    try {
      final params = Order().toJson(cartModel, user.user.id);
      var response = await wcApi.postAsync("orders", params);
      if (response["message"] != null) {
        throw Exception(response["message"]);
      } else {
        return Order.fromJson(response);
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future updateOrder(orderId, {status}) async {
    try {
      var response = await wcApi.putAsync("orders/$orderId", {"status": status});
      if (response["message"] != null) {
        throw Exception(response["message"]);
      } else {
        print(response);
        return Order.fromJson(response);
      }
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<Product>> searchProducts({name, page}) async {
    try {
      var response = await wcApi.getAsync("products?search=$name&page=$page&per_page=50");
      List<Product> list = [];
      for (var item in response) {
        list.add(Product.fromJson(item));
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  /// Get Nonce for Any Action
  Future getNonce({method = 'register'}) async {
    try {
      http.Response response =
          await http.get("$url/api/get_nonce/?controller=mstore_user&method=$method&$isSecure");
      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body)['nonce'];
      } else {
        throw Exception(['error getNonce', response.statusCode]);
      }
    } catch (e) {
      throw e;
    }
  }

  /// Auth
  @override
  Future<User> getUserInfo(cookie) async {
    try {
      print("$url/api/mstore_user/get_currentuserinfo/?cookie=$cookie&$isSecure");

      final http.Response response =
          await http.get("$url/api/mstore_user/get_currentuserinfo/?cookie=$cookie&$isSecure");
      if (response.statusCode == 200) {
        return User.fromAuthUser(convert.jsonDecode(response.body)['user']);
      } else {
        throw Exception("Can not get user info");
      }
    } catch (err) {
      throw err;
    }
  }

  /// Create a New User
  @override
  Future<User> createUser({firstName, lastName, username, password}) async {
    try {
      String niceName = firstName + lastName;
      var nonce = await getNonce();
      final http.Response response = await http.get(
          "$url/api/mstore_user/register/?insecure=cool&nonce=$nonce&username=$username&user_pass=$password&email=$username&user_nicename=$niceName&display_name=$niceName&$isSecure");
      if (response.statusCode == 200) {
        var cookie = convert.jsonDecode(response.body)['cookie'];
        return await this.getUserInfo(cookie);
      } else {
        var message = convert.jsonDecode(response.body)["error"];
        throw Exception(message != null ? message : "Can not create the user.");
      }
    } catch (err) {
      throw err;
    }
  }

  /// login
  @override
  Future<User> login({username, password}) async {
    var cookieLifeTime = 120960000000;
    try {
      final http.Response response = await http.get(
          "$url/api/mstore_user/generate_auth_cookie/?second=$cookieLifeTime&username=$username&password=$password&$isSecure");

      if (response.statusCode == 200) {
        var cookie = convert.jsonDecode(response.body)['cookie'];
        return await this.getUserInfo(cookie);
      } else {
        throw Exception("The username or password is incorrect.");
      }
    } catch (err) {
      throw err;
    }
  }

  Future<Stream<Product>> streamProductsLayout({config}) async {
    try {
      var endPoint = "products?per_page=10";
      if (config.containsKey("category")) {
        endPoint += "&category=${config["category"]}";
      }
      if (config.containsKey("tag")) {
        endPoint += "&tag=${config["tag"]}";
      }

      http.StreamedResponse response = await wcApi.getStream(endPoint);

      return response.stream
          .transform(utf8.decoder)
          .transform(json.decoder)
          .expand((data) => (data as List))
          .map((data) => Product.fromJson(data));
    } catch (e) {
      print('Error: ${e.toString()}');
      throw e;
    }
  }

  @override
  Future<Product> getProduct(id) async {
    try {
      var response = await wcApi.getAsync("products/$id");
      return Product.fromJson(response);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<Coupons> getCoupons() async {
    try {
      var response = await wcApi.getAsync("coupons");
      //print(response.toString());
      return Coupons.getListCoupons(response);
    } catch (e) {
      throw e;
    }
  }
}
