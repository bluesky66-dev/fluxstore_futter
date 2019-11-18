import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/i18n.dart';
import '../../models/category.dart';
import '../../models/search.dart';
import 'card.dart';
import 'column.dart';
import 'search.dart';
import 'side_menu.dart';
import 'sub.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CategoriesScreenState();
  }
}

class CategoriesScreenState extends State<CategoriesScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  FocusNode _focus;
  bool isVisibleSearch = false;
  String searchText;
  var textController = new TextEditingController();
  Timer _timer;

  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 0, end: 60).animate(controller);
    animation.addListener(() {
      setState(() {});
    });

    _focus = new FocusNode();
    _focus.addListener(_onFocusChange);

    Future.delayed(Duration.zero, () {
      Provider.of<CategoryModel>(context).getCategories();
    });
  }

  void _onFocusChange() {
    if (_focus.hasFocus && animation.value == 0) {
      controller.forward();
      setState(() {
        isVisibleSearch = true;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final category = Provider.of<CategoryModel>(context);

    return ListenableProvider(
          builder: (_) => category,
          child: Consumer<CategoryModel>(
            builder: (context, value, child) {
              if (value.isLoading) {
                return kLoadingWidget(context);
              }

              if (value.message != null) {
                return Center(
                  child: Text(value.message),
                );
              }

              if (value.categories == null) {
                return null;
              }

              return Scaffold(
                body: SafeArea(
                  child: Column(
                    children: <Widget>[
                      AnimatedContainer(
                        height: isVisibleSearch ? 0 : 40,
                        padding: EdgeInsets.only(left: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text(S.of(context).search,
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        duration: Duration(milliseconds: 250),
                      ),
                      Row(children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            margin: EdgeInsets.only(left: 10, right: 10, bottom: 15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.search,
                                  color: Colors.black45,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: textController,
                                    focusNode: _focus,
                                    onChanged: (text) {
                                      if (_timer != null) {
                                        _timer.cancel();
                                      }
                                      _timer = Timer(Duration(milliseconds: 500), () {
                                        setState(() {
                                          searchText = text;
                                        });
                                        Provider.of<SearchModel>(context)
                                            .searchProducts(name: text, page: 1);
                                      });
                                    },
                                    decoration: InputDecoration(
                                      fillColor: Theme.of(context).accentColor,
                                      border: InputBorder.none,
                                      hintText: S.of(context).searchForItems,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.reverse();
                            setState(() {
                              searchText = "";
                              isVisibleSearch = false;
                            });
                            textController.text = "";
                            FocusScope.of(context).requestFocus(new FocusNode());
                          },
                          child: Container(
                            height: 30,
                            width: animation.value,
                            child: Text(S.of(context).cancel, overflow: TextOverflow.ellipsis),
                          ),
                        )
                      ]),
                      Expanded(
                        child: isVisibleSearch
                            ? SearchScreen(searchText, (text) {
                                setState(() {
                                  searchText = text;
                                });
                                textController.text = text;
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode()); //dismiss keyboard
                                Provider.of<SearchModel>(context)
                                    .searchProducts(name: text, page: 1);
                              })
                            : renderCategories(value),
                      ),
                    ],
                  ),
                ),
              );
            },
          ));
  }

  Widget renderCategories(value) {
    switch (CategoriesListLayout) {
      case kCategoriesLayout.card:
        return CardCategories(value.categories);
      case kCategoriesLayout.column:
        return ColumnCategories(value.categories);
      case kCategoriesLayout.subCategories:
        return SubCategories(value.categories);
      case kCategoriesLayout.sideMenu:
        return SideMenuCategories(value.categories);
      default:
        return CardCategories(value.categories);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
