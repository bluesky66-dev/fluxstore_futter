import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../models/category.dart';
import '../../models/product.dart';

/// The category icon circle list
class CategoryItem extends StatelessWidget {
  final config;
  final products;

  CategoryItem({this.config, this.products});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final itemWidth = screenSize.width / 6;
    final categoryList = Provider.of<CategoryModel>(context).categoryList;
    final id = config['category'];
    final name = categoryList[id] != null ? categoryList[id].name : '';

    List<Color> colors = [];
    for (var item in config["colors"]) {
      colors.add(HexColor(item).withAlpha(30));
    }

    return GestureDetector(
        onTap: () => Product.showList(config: config, context: context),
        child: Container(
          width: itemWidth,
          height: 120,
          margin: EdgeInsets.only(left: 10),
          padding: EdgeInsets.only(top: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors, // whitish to gray
                    ),
                    borderRadius: BorderRadius.circular(itemWidth / 2)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(config["image"],
                      color: HexColor(config["colors"][0]),
                      width: itemWidth * 0.4,
                      height: itemWidth * 0.4),
                ),
              ),
              SizedBox(height: 6),
              Container(
                child: Text(
                  name,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).accentColor),
                ),
              )
            ],
          ),
        ));
  }
}

/// List of Category Items
class CategoryIcons extends StatelessWidget {
  final config;

  CategoryIcons({this.config});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final itemWidth = screenSize.width / 10;
    final heightList = itemWidth + 20;

    List<Widget> items = [];
    for (var item in HomeIconsCategories) {
      items.add(CategoryItem(config: item));
    }

    /// if the wrap config is enable
    if (config['wrap'] != null || config['wrap'] == false) {
      return Wrap(children: items);
    }

    return Container(
      height: heightList + 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items,
        ),
      ),
    );
  }
}
