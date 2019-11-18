import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/styles.dart';
import '../../common/tools.dart';
import '../../generated/i18n.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/search.dart';
import '../../widgets/product/product_card_view.dart';
import '../../widgets/tree_view.dart';

class CardCategories extends StatelessWidget {
  final List<Category> categories;

  CardCategories(this.categories);

  bool hasChildren(id) {
    return categories.where((o) => o.parent == id).toList().length > 0;
  }

  List<Category> getSubCategories(id) {
    return categories.where((o) => o.parent == id).toList();
  }

  @override
  Widget build(BuildContext context) {
    final _categories = categories.where((item) => item.parent == 0).toList();
    return SingleChildScrollView(
      child: Column(
        children: [
          TreeView(
            parentList: [
              for (var item in _categories)
                Parent(
                  parent: CategoryCardItem(item, hasChildren: hasChildren(item.id)),
                  childList: ChildList(
                    children: [
                      for (var category in getSubCategories(item.id))
                        Parent(
                            parent: SubItem(category),
                            childList: ChildList(
                              children: [
                                for (var cate in getSubCategories(category.id))
                                  Parent(
                                      parent: SubItem(cate, isLast: true),
                                      childList: ChildList(
                                        children: <Widget>[],
                                      ))
                              ],
                            ))
                    ],
                  ),
                )
            ],
          ),
          Recent()
        ],
      ),
    );
  }
}

class CategoryCardItem extends StatelessWidget {
  final Category category;
  final bool hasChildren;

  CategoryCardItem(this.category, {this.hasChildren = false});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: hasChildren
          ? null
          : () {
              Product.showList(context: context, cateId: category.id, cateName: category.name);
            },
      child: Container(
        height: screenSize.width * 0.30,
        padding: EdgeInsets.only(left: 10, right: 10),
        margin: EdgeInsets.only(bottom: 10),
        child: Stack(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(3.0)),
              child: Tools.image(
                url: category.image,
                fit: BoxFit.cover,
                width: screenSize.width,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.4),
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: Center(
                child: Text(
                  category.name.toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubItem extends StatelessWidget {
  final Category category;
  final bool isLast;

  SubItem(this.category, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: kGrey200))),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: isLast ? 50 : 20,
          ),
          Expanded(child: Text(category.name)),
          InkWell(
            onTap: () {
              Product.showList(context: context, cateId: category.id, cateName: category.name);
            },
            child: Text(
              "${category.totalProduct} items",
              style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor),
            ),
          ),
          IconButton(
              icon: Icon(Icons.keyboard_arrow_right),
              onPressed: () {
                Product.showList(context: context, cateId: category.id, cateName: category.name);
              })
        ],
      ),
    );
  }
}

class Recent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableProvider<SearchModel>(
      builder: (_) => Provider.of<SearchModel>(context),
      child: Consumer<SearchModel>(builder: (context, model, child) {
        if (model.products == null || model.products.isEmpty) {
          return Container();
        }
        return Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                SizedBox(width: 10),
                Expanded(
                  child: Text(S.of(context).recents,
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                ),
//                FlatButton(
//                    onPressed: null,
//                    child: Text(
//                      S.of(context).seeAll,
//                      style: TextStyle(color: Colors.greenAccent, fontSize: 13),
//                    ))
              ],
            ),
            SizedBox(height: 10),
            Divider(
              height: 1,
              color: kGrey200,
            ),
            SizedBox(height: 10),
            Container(
              height: MediaQuery.of(context).size.width * 0.35 + 120,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var item in model.products)
                      ProductCard(item: item, width: MediaQuery.of(context).size.width * 0.35)
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
