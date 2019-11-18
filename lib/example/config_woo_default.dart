import 'package:fstore/common/constants.dart';


/// Example categies:
/// {23: Category { id: 23  name: Bags}, 24: Category { id: 24  name: Bags},
/// 25: Category { id: 25  name: Blazers}, 208: Category { id: 208  name: Clothing},
/// 26: Category { id: 26  name: Dresses}, 209: Category { id: 209  name: Hoodies},
/// 27: Category { id: 27  name: Jackets}, 28: Category { id: 28  name: Jackets},
/// 29: Category { id: 29  name: Jeans}, 30: Category { id: 30  name: Jeans},
/// 18: Category { id: 18  name: Men}, 210: Category { id: 210  name: Music},
/// 211: Category { id: 211  name: Posters}, 19: Category { id: 19  name: Shirts},
/// 20: Category { id: 20  name: Shoes}, 212: Category { id: 212  name: Singles},
/// 21: Category { id: 21  name: T-Shirts}, 22: Category { id: 22  name: Women}}


const HomeIconsCategories = [
  {
    "category": 18,
    "image": "assets/icons/categories/ic_tshirt.png",
    "colors": ["#3CC2BF", "#3CC2BF"],
  },
  {
    "category": 22,
    "image": "assets/icons/categories/ic_dress.png",
    "colors": ["#3E6AB5", "#3E6AB5"],
  },
  {
    "category": 208,
    "image": "assets/icons/categories/ic_shorts.png",
    "colors": ["#53A2CC", "#53A2CC"],
  },
  {
    "category": 211,
    "image": "assets/icons/categories/ic_glasses.png",
    "colors": ["#53688A", "#53688A"],
  },
  {
    "category": 210,
    "image": "assets/icons/categories/ic_tie.png",
    "colors": ["#43506A", "#43506A"],
  },
];

const HomeImagesCategory = [
  {
    "category": 211,
  },
  {
    "category": 208,
  },
  {
    "category": 22,
  },
  {
    "image": "assets/images/hci_restaurant.jpg",
    "name": "Restaurants",
    "description": "Top-rated eats",
  },
  {
    "image": "assets/images/hci_adventures.jpg",
    "name": "Adventures",
    "description": "Multi-day trips",
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
