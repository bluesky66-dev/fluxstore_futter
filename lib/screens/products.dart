import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/i18n.dart';
import '../models/app.dart';
import '../models/product.dart';
import '../widgets/asymmetric_view.dart';
import '../widgets/backdrop.dart';
import '../widgets/backdrop_menu.dart';
import '../widgets/product/product_bottom_sheet.dart';
import '../widgets/product/product_list.dart';

class ProductBackdrop extends StatelessWidget {
  final ExpandingBottomSheet expandingBottomSheet;
  final Backdrop backdrop;

  const ProductBackdrop({Key key, this.expandingBottomSheet, this.backdrop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        backdrop,
        Align(child: expandingBottomSheet, alignment: Alignment.bottomRight)
      ],
    );
  }
}

class ProductsPage extends StatefulWidget {
  final List<Product> products;
  final int categoryId;

  ProductsPage([this.products, this.categoryId]);

  @override
  State<StatefulWidget> createState() {
    return ProductsPageState();
  }
}

class ProductsPageState extends State<ProductsPage> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  int newCategoryId = -1;
  double minPrice;
  double maxPrice;
  String orderBy;
  String order;
  bool isFiltering = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      newCategoryId = widget.categoryId;
    });
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 450),
      value: 1.0,
    );
  }

  void onFilter({minPrice, maxPrice, categoryId}) {
    _controller.forward();
    final productModel = Provider.of<ProductModel>(context);
    newCategoryId = categoryId;
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    productModel.setProductsList(List<Product>());
    productModel.getProductsList(
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        page: 1,
        lang: Provider.of<AppModel>(context).locale,
        orderBy: orderBy,
        order: order);
  }

  void onSort(order) {
    orderBy = "date";
    this.order = order;
    Provider.of<ProductModel>(context).getProductsList(
        categoryId: newCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        lang: Provider.of<AppModel>(context).locale,
        page: 1,
        orderBy: orderBy,
        order: order);
  }

  void onRefresh() {
    Provider.of<ProductModel>(context).getProductsList(
        categoryId: newCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        lang: Provider.of<AppModel>(context).locale,
        page: 1,
        orderBy: orderBy,
        order: order);
  }

  void onLoadMore(page) {
    Provider.of<ProductModel>(context).getProductsList(
        categoryId: newCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        lang: Provider.of<AppModel>(context).locale,
        page: page,
        orderBy: orderBy,
        order: order);
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<ProductModel>(context);
    final title = product.categoryName ?? S.of(context).products;
    final layout = Provider.of<AppModel>(context).appConfig['Setting']['ProductListLayout'];
    final isListView = layout  != 'horizontal';

    /// load the product base on default 2 columns view or AsymmetricView
    /// please note that the AsymmetricView is not ready support for loading per page.
    final backdrop = ({products, isFetching, errMsg, isEnd}) => ProductBackdrop(
          backdrop: Backdrop(
            frontLayer: isListView
                ? ProductList(
                    products: products,
                    onRefresh: onRefresh,
                    onLoadMore: onLoadMore,
                    isFetching: isFetching,
                    errMsg: errMsg,
                    isEnd: isEnd,
                    layout:layout)
                : AsymmetricView(products: widget.products),
            backLayer: BackdropMenu(onFilter: onFilter),
            frontTitle: Text(title),
            backTitle: Text('Filters'),
            controller: _controller,
            onSort: onSort,
          ),
          expandingBottomSheet: ExpandingBottomSheet(hideController: _controller),
        );

    return ListenableProvider(
        builder: (_) => product,
        child: Consumer<ProductModel>(
          builder: (context, value, child) {
            return backdrop(
                products: value.productsList,
                isFetching: value.isFetching,
                errMsg: value.errMsg,
                isEnd: value.isEnd);
          },
        ));
  }
}
