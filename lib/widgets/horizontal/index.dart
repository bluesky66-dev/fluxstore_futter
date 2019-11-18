import 'package:flutter/material.dart';

import '../../common/constants.dart';
import 'banner_animate_items.dart';
import 'banner_group_items.dart';
import 'banner_slider_items.dart';
import 'blog_list_items.dart';
import 'category_icon_items.dart';
import 'category_image_items.dart';
import 'instagram_items.dart';
import 'product_list_items.dart';

class HorizontalList extends StatefulWidget {
  final configs;

  HorizontalList({this.configs});

  @override
  _HorizontalListState createState() => _HorizontalListState();
}

class _HorizontalListState extends State<HorizontalList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// convert the JSON to list of horizontal widgets
  Widget jsonWidget(config) {
    switch (config["layout"]) {
      case "logo":
        return Container(
          //margin: EdgeInsets.only(left: 15, right:15),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 55,
                left: 10,
                child: IconButton(
                  icon: Icon(
                    Icons.blur_on,
                    color: Theme.of(context).accentColor.withOpacity(0.6),
                    size: 22,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              Center(
                child: Padding(
                  child: Image.asset(kLogoImage, height: 40),
                  padding: EdgeInsets.only(bottom: 10.0, top: 60.0),
                ),
              ),
            ],
          ),
        );
      case "bannerAnimated":
        return BannerAnimated(config: config);
      case "bannerImage":
        return config['isSlider'] == true
            ? BannerSliderItems(config: config)
            : BannerGroupItems(config: config);
      case "iconCategory":
        return CategoryIcons(config: config);
      case "imageCategory":
        return CategoryImages(config: config);
        break;
      case "instagram":
        return InstagramItems(config: config);
      case "blog":
        var blogUrl = widget.configs["server"]["blog"];
        return BlogListItems(config: config, url: blogUrl);
      default:
        return ProductListItems(config: config);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.configs == null) return Container();

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[for (var config in widget.configs["HorizonLayout"]) jsonWidget(config)],
      ),
    );
  }
}
