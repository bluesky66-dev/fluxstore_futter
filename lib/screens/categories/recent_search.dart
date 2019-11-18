import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/styles.dart';
import '../../common/tools.dart';
import '../../generated/i18n.dart';
import '../../models/category.dart';
import '../../models/search.dart';
import 'card.dart';
import 'column.dart';
import 'side_menu.dart';
import 'sub.dart';
import 'product_list.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CategoriesScreenState();
  }
}

class CategoriesScreenState extends State<CategoriesScreen>
    with
        AutomaticKeepAliveClientMixin,
        SingleTickerProviderStateMixin {
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
//    controller = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
//    animation = Tween<double>(begin: 0, end: 60).animate(controller);
//    animation.addListener(() {
//      setState(() {});
//    });

    _focus = new FocusNode();
    _focus.addListener(_onFocusChange);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<CategoryModel>(context).getCategories();
  }

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
                              Provider.of<SearchModel>(context).searchProducts(name: text, page: 1);
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

class RecentSearches extends StatelessWidget {
  final Function onTap;

  RecentSearches({this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListenableProvider(
      builder: (_) => Provider.of<SearchModel>(context),
      child: Consumer<SearchModel>(builder: (context, model, child) {
        return Column(
          children: <Widget>[
            Container(
              height: 45,
              decoration: BoxDecoration(color: HexColor("#F9F9F9")),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(S.of(context).recentSearches),
                  if (model.keywords.isNotEmpty)
                    InkWell(
                        onTap: () {
                          Provider.of<SearchModel>(context).clearKeywords();
                        },
                        child: Text("Clear", style: TextStyle(color: Colors.green, fontSize: 13)))
                ],
              ),
            ),
            model.keywords.isEmpty ? renderEmpty() : renderKeywords(model.keywords)
          ],
        );
      }),
    );
  }

  Widget renderEmpty() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/empty_search.png',
            width: 120,
            height: 120,
          ),
          SizedBox(height: 10),
          Container(
              width: 250,
              child: Text(
                "You haven't searched for items yet. Let's start now - we'll help you.",
                style: TextStyle(color: kGrey400),
                textAlign: TextAlign.center,
              ))
        ],
      ),
    );
  }

  Widget renderKeywords(List<String> items) {
    return Expanded(
      child: ListView.separated(
          separatorBuilder: (context, index) => Divider(
                color: kGrey200,
              ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
                title: Text(items[index]),
                onTap: () {
                  onTap(items[index]);
                });
          }),
    );
  }
}

class SearchScreen extends StatelessWidget {
  final String searchText;
  final Function onSearch;

  SearchScreen(this.searchText, this.onSearch);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<SearchModel>(
      builder: (_) => Provider.of<SearchModel>(context),
      child: Consumer<SearchModel>(builder: (context, model, child) {
        if (searchText == null || searchText.isEmpty) {
          return RecentSearches(onTap: onSearch);
        }

        if (model.loading) {
          return kLoadingWidget(context);
        }

        if (model.errMsg != null && model.errMsg.isNotEmpty) {
          return Center(child: Text(model.errMsg, style: TextStyle(color: kErrorRed)));
        }

        if (model.products.length == 0) {
          return Center(child: Text("No Product"));
        }

        return Column(
          children: <Widget>[
            Container(
              height: 45,
              decoration: BoxDecoration(color: HexColor("#F9F9F9")),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(children: [
                Text(
                  "We found ${model.products.length} products",
                )
              ]),
            ),
            Expanded(
                child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: ProductList(name: searchText, products: model.products),
            ))
          ],
        );
      }),
    );
  }
}
