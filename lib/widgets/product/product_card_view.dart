import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/tools.dart';
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../screens/detail/index.dart';
import '../../widgets/heart_button.dart';
import '../start_rating.dart';

class ProductCard extends StatelessWidget {
  final Product item;
  final width;
  final marginRight;
  final kSize size;
  final bool isHero;
  final bool showCart;
  final bool showHeart;

  ProductCard(
      {this.item,
      this.width,
      this.size = kSize.medium,
      this.isHero = false,
      this.showHeart = false,
      this.showCart = false,
      this.marginRight = 10.0});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final addProductToCart = Provider.of<CartModel>(context).addProductToCart;
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    double titleFontSize = isTablet ? 20.0 : 14.0;
    double iconSize = isTablet ? 24.0 : 18.0;
    double starSize = isTablet ? 20.0 : 13.0;

    void onTapProduct() {
      if (item.imageFeature == '') return;

      Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => Detail(product: item),
            fullscreenDialog: true,
          ));
    }

    return Stack(
      children: <Widget>[
        Container(
          color: Theme.of(context).cardColor,
          margin: EdgeInsets.only(right: marginRight),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: onTapProduct,
                child: isHero
                    ? Hero(
                        tag: 'product-${item.id}',
                        child: Tools.image(
                          url: item.imageFeature,
                          width: width,
                          size: kSize.medium,
                          isResize: true,
                          height: width * 1.2,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Tools.image(
                        url: item.imageFeature,
                        width: width,
                        size: kSize.medium,
                        isResize: true,
                        height: width * 1.2,
                        fit: BoxFit.cover,
                      ),
              ),
              Container(
                width: width,
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.name,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1),
                    SizedBox(height: 6),
                    Text(Tools.getCurrecyFormatted(item.price),
                        style: TextStyle(color: theme.accentColor)),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SmoothStarRating(
                            allowHalfRating: true,
                            starCount: 5,
                            rating: item.averageRating ?? 0.0,
                            size: starSize,
                            color: theme.primaryColor,
                            borderColor: theme.primaryColor,
                            spacing: 0.0),
                        if (showCart && !item.isEmptyProduct())
                          IconButton(
                              padding: EdgeInsets.all(2.0),
                              icon: Icon(Icons.add_shopping_cart, size: iconSize),
                              onPressed: () {
                                addProductToCart(product: item);
                              }),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        if (showHeart && !item.isEmptyProduct())
          Positioned(
            top: 0,
            right: 0,
            child: HeartButton(product: item, size: 18),
          )
      ],
    );
  }
}
