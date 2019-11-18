import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/tools.dart';
import '../../models/app.dart';
import '../../models/product.dart';
import '../../screens/detail/index.dart';
import '../../services/index.dart';

/// The Banner type to display the image
class BannerImageItem extends StatefulWidget {
  final Key key;
  final config;
  final double width;
  final padding;
  final BoxFit boxFit;

  BannerImageItem({this.key, this.config, this.padding, this.width, this.boxFit}) : super(key: key);

  @override
  _BannerImageItemState createState() => _BannerImageItemState();
}

class _BannerImageItemState extends State<BannerImageItem> with AfterLayoutMixin {
  Product _product;

  List<Product> _products;

  Services _service = Services();

  @override
  void afterFirstLayout(BuildContext context) {
    /// for pre-load the product detail
    if (widget.config["product"] != null) {
      _service.getProduct(widget.config["product"]).then(
        (product) {
          if (!mounted) return;
          setState(() {
            _product = product;
          });
        },
      );
    }

    /// for pre-load the list product
    if (widget.config["category"] != null) {
      _service.fetchProductsLayout(
          config: {"category": widget.config["category"]},
          lang: Provider.of<AppModel>(context).locale).then((products) {
        if (!mounted) return;
        setState(() {
          _products = products;
        });
      });
    }
  }

  _onTap(context) {
    /// support to show the product detail
    if (widget.config["product"] != null && _product != null) {
      return Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => Detail(product: _product),
            fullscreenDialog: true,
          ));
    }

    /// support to show the post detail
    if (widget.config["post"] != null) {}

    /// Default navigate to show the list products
    Product.showList(context: context, config: widget.config, products: _products);
  }

  @override
  Widget build(BuildContext context) {
    double _pading = widget.config["padding"] ?? widget.padding ?? 10.0;

    final screenSize = MediaQuery.of(context).size;
    final itemWidth = widget.width ?? screenSize.width;

    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        width: itemWidth,
        child: Padding(
          padding: EdgeInsets.only(left: _pading, right: _pading),
          child: Tools.image(
            fit: this.widget.boxFit ?? BoxFit.fitWidth,
            url: widget.config["image"],
          ),
        ),
      ),
    );
  }
}
