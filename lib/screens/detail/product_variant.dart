import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../generated/i18n.dart';
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../services/index.dart';
import '../../widgets/product/product_variant.dart';

class ProductVariant extends StatefulWidget {
  final Product product;

  ProductVariant(this.product);

  @override
  StateProductVariant createState() => StateProductVariant(product);
}

class StateProductVariant extends State<ProductVariant> {
  Product product;
  ProductVariation productVariation;

  StateProductVariant(this.product);

  int quantity = 1;
  final services = Services();
  Map<String, String> mapAttribute = HashMap();
  List<ProductVariation> variations = [];

  Future<List<ProductVariation>> getProductVariantions() async {
    final variations = await services.getProductVariations(product);
    setState(() {
      this.variations = variations;
    });
    if (variations.isEmpty) {
      for (var attr in product.attributes) {
        mapAttribute.update(attr.name, (value) => attr.options[0], ifAbsent: () => attr.options[0]);
      }
    } else {
      for (var variant in variations) {
        if (variant.price == product.price) {
          for (var attribute in variant.attributes) {
            setState(() {
              mapAttribute.update(attribute.name, (value) => attribute.option,
                  ifAbsent: () => attribute.option);
            });
          }
          if (mapAttribute.length < product.attributes.length) {
            for (var attribute in product.attributes) {
              setState(() {
                mapAttribute.update(attribute.name, (value) => value,
                    ifAbsent: () => attribute.options[0]);
              });
            }
          }
          break;
        }
      }
    }
    checkVariation();
    return variations;
  }

  @override
  void initState() {
    super.initState();
    getProductVariantions();
  }

  void addToCart() {
    final cartModel = Provider.of<CartModel>(context);
    cartModel.addProductToCart(product: product, quantity: quantity, variation: productVariation);
  }

  void checkVariation() {
    if (variations != null) {
      final variation = variations.firstWhere((item) {
        bool isCorrect = true;
        for (var attribute in item.attributes) {
          if (attribute.option != mapAttribute[attribute.name]) {
            isCorrect = false;
            break;
          }
        }
        if (isCorrect) {
          for (var key in mapAttribute.keys.toList()) {
            bool check = false;
            for (var attribute in item.attributes) {
              if (key == attribute.name) {
                check = true;
                break;
              }
            }
            if (!check) {
              Attribute att = Attribute();
              att.id = null;
              att.name = key;
              att.option = mapAttribute[key];
              item.attributes.add(att);
            }
          }
        }
        return isCorrect;
      }, orElse: () {
        /*ProductVariation variDefault = new ProductVariation();

        variDefault.imageFeature = product.imageFeature;
        variDefault.inStock = product.inStock;
        variDefault.onSale = product.onSale;
        variDefault.price = product.price;
        variDefault.regularPrice = product.regularPrice;
        variDefault.salePrice = product.salePrice;

        for (var key in mapAttribute.keys.toList()) {
          Attribute att = new Attribute();
          att.id = null;
          att.name = key;
          att.option = mapAttribute[key];
          variDefault.attributes.add(att);
        }

        return variDefault;*/
        return null;
      });
      if (variation != null && mounted) {
        setState(() {
          productVariation = variation;
        });
        Provider.of<ProductModel>(context).changeProductVariation(variation);
      }
    }
  }

  List<Widget> getProductVariant() {
    final ThemeData theme = Theme.of(context);
    List<Widget> listwidget = new List();
    final check = product.attributes != null && product.attributes.isNotEmpty ? true : false;
    final inStock = productVariation != null ? productVariation.inStock : product.inStock;

    listwidget.add(
      SizedBox(height: 10.0),
    );


    if (check) {
      for (var attr in product.attributes) {
        listwidget.add(
          BasicSelection(
            options: List<String>.from(attr.options),
            title: attr.name,
            type: ProductVariantLayout[attr.name.toLowerCase()] ?? 'box',
            value: mapAttribute[attr.name] != null ? mapAttribute[attr.name] : "",
            onChanged: (val) {
              setState(() {
                //size = val;
                mapAttribute.update(attr.name, (value) => val, ifAbsent: () => val);
              });
              checkVariation();
            },
          ),
        );
        listwidget.add(
          SizedBox(height: 20.0),
        );
      }
    }

    listwidget.add(
      Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap:
                  inStock && (product.attributes.length == mapAttribute.length) ? addToCart : null,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: inStock && (product.attributes.length == mapAttribute.length)
                      ? theme.primaryColor
                      : theme.disabledColor,
                ),
                child: Center(
                  child: Text(
                    S.of(context).addToCart.toUpperCase(),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(color: theme.backgroundColor),
            child: QuantitySelection(
              value: quantity,
              color: theme.accentColor,
              onChanged: (val) {
                setState(() {
                  quantity = val;
                });
              },
            ),
          )
        ],
      ),
    );
    return listwidget;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: getProductVariant(),
    );
  }
}
