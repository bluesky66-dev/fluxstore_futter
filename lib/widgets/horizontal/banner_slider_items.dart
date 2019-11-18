import 'package:flutter/material.dart';
import 'package:page_indicator/page_indicator.dart';

import 'banner_items.dart';

/// The Banner Group type to display the image as multi columns
class BannerSliderItems extends StatelessWidget {
  final config;

  BannerSliderItems({this.config});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    PageController _controller = PageController();
    double _bannerPercent = config['height'] ?? 0.25;
    List items = config['items'];


    return Container(
      height: screenSize.height * _bannerPercent,
      child: PageIndicatorContainer(
        pageView: PageView(
          controller: _controller,
          children: <Widget>[
            for (int i = 0; i < items.length; i++)
              BannerImageItem(config: items[i], width: screenSize.width, boxFit: BoxFit.cover)
          ],
        ),
        align: IndicatorAlign.bottom,
        length: items.length,
        indicatorSpace: 5.0,
        padding: const EdgeInsets.all(10.0),
        indicatorColor: Colors.black12,
        indicatorSelectorColor: Colors.black87,
        shape: IndicatorShape.roundRectangleShape(
          size: Size(25.0, 2.0),
        ),
      ),
    );
  }
}
