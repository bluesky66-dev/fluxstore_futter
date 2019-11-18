import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:validate/validate.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'config.dart';
import 'constants.dart';

enum kSize { small, medium, large }

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class Tools {
  static String formatImage(String url, [kSize size = kSize.medium]) {
    if (GlobalConfiguration().getString("type") == "woo") {
      String pathWithoutExt = p.withoutExtension(url);
      String ext = p.extension(url);
      String imageURL = url ?? kDefaultImage;

      switch (size) {
        case kSize.large:
          imageURL = '$pathWithoutExt-large$ext';
          break;
        case kSize.small:
          imageURL = '$pathWithoutExt-small$ext';
          break;
        default: // kSize.medium:e
          imageURL = '$pathWithoutExt-medium$ext';
          break;
      }
      return imageURL;
    } else {
      return url;
    }
  }

  static NetworkImage networkImage(String url, [kSize size = kSize.medium]) {
    return NetworkImage(formatImage(url, size) ?? kDefaultImage);
  }

  /// Smart image function to load image cache and check empty URL to return empty box
  /// Only apply for the product image resize with (small, medium, large)
  static image(
      {String url,
      kSize size,
      double width,
      double height,
      BoxFit fit,
      String tag,
      bool isResize = false}) {
    if (url.isEmpty || url == '') {
      return Container(
        width: width,
        height: height,
        color: Color(kEmptyColor),
      );
    }

    return ExtendedImage.network(
      isResize ? formatImage(url, size) : url,
      width: width,
      height: height,
      fit: fit,
      cache: true,
      border: Border.all(color: Colors.red, width: 1.0),
      enableLoadState: false,
    );

//    return FadeInImage.memoryNetwork(
//      image: isResize ? formatImage(url, size) : url,
//      fit: fit,
//      width: width,
//      height: height,
//      placeholder: kTransparentImage,
//    );
  }

  static String getCurrecyFormatted(price) {
    final formatCurrency = new NumberFormat.currency(
        symbol: DefaultCurrency["symbol"],
        decimalDigits: DefaultCurrency["decimalDigits"]);
    try {
      if (price is String) {
        return formatCurrency
            .format(price.isNotEmpty ? double.parse(price) : 0);
      } else {
        return formatCurrency.format(price);
      }
    } catch (err) {
      return formatCurrency.format(0);
    }
  }

  /// check tablet screen
  static bool isTablet(MediaQueryData query) {
    var size = query.size;
    var diagonal =
        sqrt((size.width * size.width) + (size.height * size.height));
    var isTablet = diagonal > 1100.0;
    return isTablet;
  }

  /// cache avatar for the chat
  static getCachedAvatar(String avatarUrl) {
    return CachedNetworkImage(
      imageUrl: avatarUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );

  }
}

class Validator {
  static String validateEmail(String value) {
    try {
      Validate.isEmail(value);
    } catch (e) {
      return 'The E-mail Address must be a valid email address.';
    }

    return null;
  }
}
