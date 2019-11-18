// The config app layout variable
// or this value can load online https://json-inspire-ui.inspire.now.sh/config.json - see document
import 'package:flutter/material.dart';

const kAppConfig = 'lib/common/config.json';
const kDefaultImage =
    "https://user-images.githubusercontent.com/1459805/58628416-d3056f00-8303-11e9-9212-00179a1f3682.jpg";
const kLogoImage = 'assets/images/logo.png';
const kProfileBackground =
    "https://images.unsplash.com/photo-1494253109108-2e30c049369b?ixlib=rb-1.2.1&auto=format&fit=crop&w=3150&q=80";

const welcomeGift =
    'https://media.giphy.com/media/3oz8xSjBmD1ZyELqW4/giphy.gif';

const kSplashScreen = "assets/images/splashscreen.flr";
enum kCategoriesLayout { card, sideMenu, column, subCategories }

const kEmptyColor = 0XFFF2F2F2;

const kColorNameToHex = {
  "red": "#ec3636",
  "black": "#000000",
  "white": "#ffffff",
  "green": "#36ec58",
  "grey": "#919191",
  "yellow": "#f6e46a",
  "blue": "#3b35f3"
};

const kOrderStatusColor = {
  "processing": "#B7791D",
  "cancelled": "#C82424",
  "refunded": "#C82424",
  "completed": "#15B873"
};

const kLocalKey = {
  "userInfo": "userInfo",
  "shippingAddress": "shippingAddress",
  "recentSearches": "recentSearches",
  "wishlist": "wishlist",
  "home": "home"
};

const kMaxPriceFilter = 1000.0;

Widget kLoadingWidget(context) => Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        strokeWidth: 2.0,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
    );


