import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/index.dart';
import '../../widgets/product/product_list.dart';
import '../../models/category.dart';
import '../../models/app.dart';
import '../../models/product.dart';

class SideMenuCategories extends StatefulWidget {
  final List<Category> categories;
  SideMenuCategories(this.categories);

  @override
  State<StatefulWidget> createState() {
    return SideMenuCategoriesState();
  }
}

class SideMenuCategoriesState extends State<SideMenuCategories> {
  int selectedIndex = 0;
  Services _service = Services();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Row(
      children: <Widget>[
        Container(
          width: 100,
          child: ListView.builder(
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? Colors.grey[100]
                          : Colors.white),
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Center(
                      child: Text(widget.categories[index].name,
                          style: TextStyle(
                              fontSize: 18,
                              color: selectedIndex == index
                                  ? theme.primaryColor
                                  : theme.hintColor)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Product>>(
            future: _service.fetchProductsByCategory(
                lang: Provider.of<AppModel>(context).locale,
                categoryId: widget.categories[selectedIndex].id),
            builder:
                (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
              return ProductList(
//                isLoading: snapshot.connectionState == ConnectionState.none ||
//                    snapshot.connectionState == ConnectionState.active ||
//                    snapshot.connectionState == ConnectionState.waiting,
//                errorMsg: snapshot.hasError ? snapshot.error : null,
                products: snapshot.data,
                width: screenSize.width - 100,
                padding: 4.0,
              );
            },
          ),
        )
      ],
    );
  }
}
