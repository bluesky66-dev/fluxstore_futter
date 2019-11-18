import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart' as Extend;
import 'package:provider/provider.dart';

import '../common/tools.dart';
import '../common/constants.dart';
import '../generated/i18n.dart';
import '../models/category.dart';
import 'tree_view.dart';

class BackdropMenu extends StatefulWidget {
  final Function onFilter;

  const BackdropMenu({
    Key key,
    this.onFilter,
  }) : super(key: key);

  @override
  _BackdropMenuState createState() => _BackdropMenuState();
}

class _BackdropMenuState extends State<BackdropMenu>
    with SingleTickerProviderStateMixin, AfterLayoutMixin<BackdropMenu> {
  double mixPrice = 0.0;
  double maxPrice = kMaxPriceFilter / 2;
  int categoryId = -1;

  @override
  void afterFirstLayout(BuildContext context) {
    Provider.of<CategoryModel>(context).getCategories();
  }

  @override
  Widget build(BuildContext context) {
    final category = Provider.of<CategoryModel>(context);

    return ListenableProvider(
        builder: (_) => category,
        child: Consumer<CategoryModel>(builder: (context, value, child) {
          if (value.isLoading) {
            return Center(child: kLoadingWidget(context));
          }

          if (value.message != null) {
            return Center(
              child: Text(value.message),
            );
          }

          if (value.categories != null) {
            final categories = value.categories.where((item) => item.parent == 0).toList();

            return Container(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(S.of(context).byPrice,
                        style: TextStyle(fontSize: 22, color: Colors.white70)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        Tools.getCurrecyFormatted(mixPrice),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        " - ",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        Tools.getCurrecyFormatted(maxPrice),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Extend.RangeSlider(
                      min: 0.0,
                      max: kMaxPriceFilter,
                      lowerValue: mixPrice,
                      upperValue: maxPrice,
                      showValueIndicator: true,
                      valueIndicatorMaxDecimals: 0,
                      onChanged: (double newLowerValue, double newUpperValue) {
                        setState(() {
                          mixPrice = newLowerValue;
                          maxPrice = newUpperValue;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, top: 30),
                    child: Text(S.of(context).byCategory,
                        style: TextStyle(fontSize: 22, color: Colors.white70)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black12),
                        child: SingleChildScrollView(
                          child: TreeView(
                            parentList: [
                              for (var item in categories)
                                Parent(
                                    parent: CategoryItem(
                                      item,
                                      hasChild: hasChildren(value.categories, item.id),
                                      isSelected: item.id == categoryId,
                                      onTap: (val) {
                                        setState(() {
                                          categoryId = val;
                                        });
                                      },
                                    ),
                                    childList: ChildList(children: [
                                      for (var category
                                          in getSubCategories(value.categories, item.id))
                                        Parent(
                                            parent: CategoryItem(
                                              category,
                                              isLast: true,
                                              isSelected: category.id == categoryId,
                                              onTap: (val) {
                                                setState(() {
                                                  categoryId = val;
                                                });
                                              },
                                            ),
                                            childList: ChildList(
                                              children: [],
                                            ))
                                    ]))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Row(children: [
                      Expanded(
                          child: ButtonTheme(
                              height: 44,
                              child: RaisedButton(
                                  elevation: 0.5,
                                  onPressed: () {
                                    widget.onFilter(
                                        minPrice: mixPrice,
                                        maxPrice: maxPrice,
                                        categoryId: categoryId);
                                  },
                                  child: Text(S.of(context).apply),
                                  shape: new RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(3.0)))))
                    ]),
                  ),
                  SizedBox(
                    height: 70,
                  )
                ],
              ),
            );
          }

          return null;
        }));
  }

  bool hasChildren(categories, id) {
    return categories.where((o) => o.parent == id).toList().length > 0;
  }

  List<Category> getSubCategories(categories, id) {
    return categories.where((o) => o.parent == id).toList();
  }
}

class CategoryItem extends StatelessWidget {
  final Category category;
  final bool isLast;
  final bool isSelected;
  final bool hasChild;
  final Function onTap;

  CategoryItem(this.category,
      {this.isLast = false, this.isSelected = true, this.hasChild = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasChild
          ? null
          : () {
              onTap(category.id);
            },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10.0),
        child: Row(
          children: <Widget>[
            Container(
                child: Icon(Icons.check,
                    color: isSelected ? Colors.white : Colors.transparent, size: 20)),
            SizedBox(
              width: isLast ? 50 : 10,
            ),
            Expanded(
                child: Text(
              category.name + " (${category.totalProduct})",
              style: TextStyle(color: Colors.white, fontSize: 14),
            )),
            if (hasChild)
              Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white,
                size: 20,
              ),
            SizedBox(
              width: 20,
            )
          ],
        ),
      ),
    );
  }
}
