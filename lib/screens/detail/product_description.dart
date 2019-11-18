import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';

import '../../common/styles.dart';
import '../../generated/i18n.dart';
import '../../models/app.dart';
import '../../models/product.dart';
import '../../widgets/expansion_info.dart';
import 'additional_information.dart';
import 'review.dart';

class ProductDescription extends StatelessWidget {
  final Product product;

  ProductDescription(this.product);

  @override
  Widget build(BuildContext context) {
    final appConfig = Provider.of<AppModel>(context).appConfig;
    bool enableReview = appConfig["server"]["type"] != "magento";

    return Column(
      children: <Widget>[
        SizedBox(height: 15),
        ExpansionInfo(
            title: S.of(context).description,
            children: <Widget>[
              HtmlWidget(
                product.description,
                textStyle: TextStyle(color: Theme.of(context).accentColor),
              ),
            ],
            expand: true),
        if (enableReview) Container(height: 1, decoration: BoxDecoration(color: kGrey200)),
        if (enableReview)
          ExpansionInfo(
            title: S.of(context).readReviews,
            children: <Widget>[
              Reviews(product.id),
            ],
          ),
        Container(height: 1, decoration: BoxDecoration(color: kGrey200)),
        ExpansionInfo(
          title: S.of(context).additionalInformation,
          children: <Widget>[
            AdditionalInformation(product),
          ],
        ),
      ],
    );
  }
}
