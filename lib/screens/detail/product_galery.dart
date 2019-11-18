import 'package:flutter/material.dart';

import '../../common/tools.dart';
import '../../models/product.dart';
import 'image_galery.dart';

class ProductGalery extends StatelessWidget {
  final Product product;

  ProductGalery(this.product);

  _onShowGallery(context, [index = 0]) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return ImageGalery(images: product.images, index: index);
        });
  }

  @override
  Widget build(BuildContext context) {
    double dimension = MediaQuery.of(context).size.width * 0.31;

    if (product.images.length < 4) return Container();
    return Container(
      height: dimension,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(width: 10.0),
          for (var i = 1; i < product.images.length; i++)
            GestureDetector(
              onTap: () => _onShowGallery(context, i),
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: Tools.image(
                  url: product.images[i],
                  height: dimension,
                  width: dimension,
                  isResize: true,
                  fit: BoxFit.cover,
                ),
              ),
            )
        ],
      ),
    );
  }
}
