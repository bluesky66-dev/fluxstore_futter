import 'package:flutter/material.dart';
import '../services/index.dart';
import 'cart.dart';
import 'address.dart';
import 'user.dart';

class OrderModel extends ChangeNotifier {
  List<Order> myOrders;
  bool isLoading = true;
  String errMsg;

  void getMyOrder({UserModel userModel}) async {
    try {
      myOrders = await Services().getMyOrders(userModel: userModel);
      isLoading = false;
      notifyListeners();
    } catch (err) {
      errMsg = err.toString();
      isLoading = false;
      notifyListeners();
    }
  }
}

class Order {
  int id;
  String number;
  String status;
  DateTime createdAt;
  double total;
  String paymentMethodTitle;
  String shippingMethodTitle;
  List<ProductItem> lineItems = [];
  Address billing;

  Order({this.id, this.number, this.status, this.createdAt, this.total});

  Order.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    number = parsedJson["number"];
    status = parsedJson["status"];
    createdAt = parsedJson["date_created"] != null
        ? DateTime.parse(parsedJson["date_created"])
        : DateTime.now();
    total =
        parsedJson["total"] != null ? double.parse(parsedJson["total"]) : 0.0;
    paymentMethodTitle = parsedJson["payment_method_title"];

    parsedJson["line_items"].forEach((item) {
      lineItems.add(ProductItem.fromJson(item));
    });

    billing = Address.fromJson(parsedJson["billing"]);
    shippingMethodTitle = parsedJson["shipping_lines"][0]["method_title"];
  }

  Map<String, dynamic> toJson(CartModel cartModel, userId) {
    var lineItems = cartModel.productsInCart.keys.map((key) {
      var productId;
      if(key.contains("-")){
        productId = int.parse(key.split("-")[0]);
      }else{
        productId = int.parse(key);
      }
      var item = {"product_id": productId, "quantity": cartModel.productsInCart[key]};
      if (cartModel.productVariationInCart[key] != null) {
        item["variation_id"] = cartModel.productVariationInCart[key].id;
      }
      return item;
    }).toList();

    return {
      "payment_method": cartModel.paymentMethod.id,
      "payment_method_title": cartModel.paymentMethod.title,
      "set_paid": true,
      "billing": cartModel.address.toJson(),
      "shipping": cartModel.address.toJson(),
      "line_items": lineItems,
      "customer_id": userId,
      "shipping_lines": [
        {"method_id": 'flat_rate', "method_title": 'Flat Rate'}
      ]
    };
  }

  @override
  String toString() => 'Order { id: $id  number: $number}';
}

class ProductItem {
  int productId;
  String name;
  int quantity;
  String total;

  ProductItem.fromJson(Map<String, dynamic> parsedJson) {
    productId = parsedJson["product_id"];
    name = parsedJson["name"];
    quantity = parsedJson["quantity"];
    total = parsedJson["total"];
  }
}
