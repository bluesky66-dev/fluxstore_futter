import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

/// The product variant config
const ProductVariantLayout = {
  "color": "color",
  "size": "box",
  "height": "option",
};

/// if it is true, user should login before using the app
const bool IsRequiredLogin = false;

/// The Google API Key to support Pick up the Address automatically
/// We recommend to generate both ios and android to restrict by bundle app id
/// The download package is remove these keys, please use your own key
const kGoogleAPIKey = {
  "android": "your-google-api-key",
  "ios": "your-google-api-key"
};

const admob_id = "ca-app-pub-3940256099942544~3347511713";

/// use to config the product image height for the product detail
/// height=(percent * width-screen)
/// isHero: support hero animate
///
const kProductDetail = {
  "height": 0.5,
  "marginTop": 0,
  "isHero": false,
//  "showVideo": true,
//  "showAR": true,
//  "show360": true,
};


/// config for the chat app
const String adminEmail = "admininspireui@gmail.com";
const smartChat = [
  {'app': 'whatsapp://send?phone=8499999999', 'iconData': FontAwesomeIcons.whatsapp},
  {'app': 'https://m.me/csasonic2', 'iconData': FontAwesomeIcons.facebookMessenger},
  {'app': 'tel:8499999999', 'iconData': FontAwesomeIcons.phone},
  {'app': 'sms://8499999999', 'iconData': FontAwesomeIcons.sms}
];

/// the welcome screen data
List onBoardingData = [
  {
    "title": "Welcome to FluxStore",
    "image": "assets/images/fogg-delivery-1.png",
    "desc": "Fluxstore is on the way to serve you. "
  },
  {
    "title": "Connect Surrounding World",
    "image": "assets/images/fogg-uploading-1.png",
    "desc": "See all things happening around you just by a click in your phone. "
        "Fast, convenient and clean."
  },
  {
    "title": "Let's Get Started",
    "image": "fogg-order-completed.png",
    "desc": "Waiting no more, let's see what we get!"
  },
];
