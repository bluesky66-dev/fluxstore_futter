import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/constants.dart';
import '../../common/styles.dart';
import '../../common/tools.dart';
import '../../generated/i18n.dart';
import '../../models/search.dart';
import 'product_list.dart';

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
