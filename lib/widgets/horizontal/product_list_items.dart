import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../../services/index.dart';
import '../../common/tools.dart';
import '../../models/app.dart';
import '../../models/product.dart';
import '../../widgets/product/product_card_view.dart';
import 'header_view.dart';

class ProductListItems extends StatefulWidget {
  final config;

  ProductListItems({this.config});

  @override
  _ProductListItemsState createState() => _ProductListItemsState();
}

class _ProductListItemsState extends State<ProductListItems> {
  final Services _service = Services();
  Future<List<Product>> _getProductLayout;

  final _memoizer = AsyncMemoizer<List<Product>>();

  @override
  void initState() {
    // only create the future once.

    new Future.delayed(Duration.zero, () {
      _getProductLayout = getProductLayout(context);
    });
    super.initState();
  }

  double _buildProductWidth(screenWidth) {
    switch (widget.config["layout"]) {
      case "twoColumn":
        return screenWidth * 0.5;
      case "threeColumn":
        return screenWidth * 0.35;
      case "card":
      default:
        return screenWidth - 10;
    }
  }

  double _buildProductHeight(screenWidth, isTablet) {
    switch (widget.config["layout"]) {
      case "twoColumn":
        return isTablet ? screenWidth * 0.7 : screenWidth * 0.85;
        break;
      case "threeColumn":
        return isTablet ? screenWidth * 0.6 : screenWidth * 0.7;
        break;
      case "card":
      default:
        var cardHeight =
            widget.config["height"] != null ? widget.config["height"] + 40.0 : screenWidth * 1.4;
        return isTablet ? screenWidth * 1.3 : cardHeight;
        break;
    }
  }

  Future<List<Product>> getProductLayout(context) => _memoizer.runOnce(
        () => _service.fetchProductsLayout(
            config: widget.config, lang: Provider.of<AppModel>(context).locale),
      );

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = Tools.isTablet(MediaQuery.of(context));

    return FutureBuilder<List<Product>>(
      future: _getProductLayout,
      builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
        final locale = Provider.of<AppModel>(context).locale;
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Column(
              children: <Widget>[
                HeaderView(
                  headerText: locale == "ar"
                      ? widget.config["name"]["ab"]
                      : (locale == "vi"
                          ? widget.config["name"]["vi"]
                          : widget.config["name"]["en"]),
                  showSeeAll: true,
                  callback: () => Product.showList(context: context, config: widget.config),
                ),
                SizedBox(
                  height: _buildProductHeight(screenSize.width, isTablet),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(width: 10.0),
                        for (var i = 0; i < 3; i++)
                          ProductCard(
                            item: Product.empty(i),
                            width: _buildProductWidth(screenSize.width),
                          )
                      ],
                    ),
                  ),
                )
              ],
            );
          case ConnectionState.done:
          default:
            if (snapshot.hasError || snapshot.data.length == 0) {
              return Container();
            } else {
              return Column(
                children: <Widget>[
                  HeaderView(
                    headerText: locale == "ar"
                        ? widget.config["name"]["ab"]
                        : (locale == "vi"
                            ? widget.config["name"]["vi"]
                            : widget.config["name"]["en"]),
                    showSeeAll: true,
                    callback: () => Product.showList(
                        context: context, config: widget.config, products: snapshot.data),
                  ),
                  Container(
                    height: _buildProductHeight(screenSize.width, isTablet),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(width: 10.0),
                          for (var item in snapshot.data)
                            ProductCard(
                              item: item,
                              //isHero: true,
                              width: _buildProductWidth(screenSize.width),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
        }
      },
    );
  }
}
