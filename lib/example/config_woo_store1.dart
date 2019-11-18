import 'package:fstore/common/constants.dart';

/// Example categies:
//{37: Category { id: 37  name: Accessories},
//38: Category { id: 38  name: Bags},
//39: Category { id: 39  name: Footwear},
//40: Category { id: 40  name: Man},
//15: Category { id: 15  name: Uncategorized},
//41: Category { id: 41  name: Woman}}

const HomeIconsCategories = [
  {
    "category": 41,
    "image": "assets/icons/categories/ic_tshirt.png",
    "colors": ["#3CC2BF", "#3CC2BF"],
  },
  {
    "category": 38,
    "image": "assets/icons/categories/ic_dress.png",
    "colors": ["#3E6AB5", "#3E6AB5"],
  },
  {
    "category": 40,
    "image": "assets/icons/categories/ic_shorts.png",
    "colors": ["#53A2CC", "#53A2CC"],
  },
  {
    "category": 37,
    "image": "assets/icons/categories/ic_glasses.png",
    "colors": ["#53688A", "#53688A"],
  },
  {
    "category": 39,
    "image": "assets/icons/categories/ic_woman_shoes.png",
    "colors": ["#53A2CC", "#53A2CC"],
  },
];

const CategoriesListLayout = kCategoriesLayout.card;

const Payments = {
  "paypal": "assets/icons/payment/paypal.png",
  "stripe": "assets/icons/payment/stripe.png",
  "razorpay": "assets/icons/payment/razorpay.png",
};

const DefaultCurrency = {"symbol": "\$", "decimalDigits": 2};

/// if it is true, user should login before using the app
const bool IsRequiredLogin = false;

/// use to config the product image height for the product detail
/// height=(percent * width-screen)
/// isHero: support hero animate
const kProductDetail = {
  "height": 1.2,
  "marginTop": 100,
  "isHero": false,
};

/// The Google API Key to support Pick up the Address automatically
/// We recommend to generate both ios and android to restrict by bundle app id
/// The download package is remove these keys, please use your own key
const kGoogleAPIKey = {
  "android": "",
  "ios": ""
};
