import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/config.dart';
import 'common/constants.dart';
import 'common/styles.dart';
import 'common/tools.dart';
import 'generated/i18n.dart';
import 'models/app.dart';
import 'models/cart.dart';
import 'models/category.dart';
import 'models/order.dart';
import 'models/payment_method.dart';
import 'models/product.dart';
import 'models/search.dart';
import 'models/shipping_method.dart';
import 'models/user.dart';
import 'models/wishlist.dart';
import 'screens/blogs.dart';
import 'package:fstore/screens/chat/chat_screen.dart';
import 'screens/checkout/index.dart';
import 'screens/login.dart';
import 'screens/notification.dart';
import 'screens/onboard_screen.dart';
import 'screens/orders.dart';
import 'screens/products.dart';
import 'screens/registration.dart';
import 'screens/wishlist.dart';
import 'services/index.dart';
import 'tabbar.dart';
import 'screens/chat/chat_list_by_admin.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

class SplashScreenAnimate extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenAnimate> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      return false;
    } else {
      prefs.setBool('seen', true);
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen.callback(
      name: kSplashScreen,
      startAnimation: 'fluxstore',
      backgroundColor: Colors.white,
      onError: (error, stack) => {},
      onSuccess: (object) async {
        bool isFirstSeen = await checkFirstSeen();

        if (isFirstSeen) {
          return Navigator.pushNamed(context, '/onboardscreen');
        }

        if (IsRequiredLogin) {
          return Navigator.pushReplacementNamed(context, '/login');
        }

        return Navigator.pushReplacementNamed(context, '/home');
      },
      until: () {
        return Future.delayed(Duration(seconds: 1));
      },
    );
  }
}

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

class AppState extends State<App> with AfterLayoutMixin {
  final _app = AppModel();
  final _product = ProductModel();
  final _wishlist = WishListModel();
  final _shippingMethod = ShippingMethodModel();
  final _paymentMethod = PaymentMethodModel();
  final _order = OrderModel();
  final _search = SearchModel();

  @override
  void afterFirstLayout(BuildContext context) {
    _app.loadAppConfig();
  }

  void onUpdateAppConfig(appConfig) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Services().setAppConfig(appConfig);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppModel>.value(
      value: _app,
      child: Consumer<AppModel>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return kLoadingWidget(context);
          }
          onUpdateAppConfig(value.appConfig);

          return MultiProvider(
            providers: [
              Provider<ProductModel>.value(value: _product),
              Provider<WishListModel>.value(value: _wishlist),
              Provider<ShippingMethodModel>.value(value: _shippingMethod),
              Provider<PaymentMethodModel>.value(value: _paymentMethod),
              Provider<OrderModel>.value(value: _order),
              Provider<SearchModel>.value(value: _search),
              ChangeNotifierProvider(builder: (context) => UserModel()),
              ChangeNotifierProvider(builder: (context) => CategoryModel()),
              ChangeNotifierProvider(builder: (context) => CartModel()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: new Locale(Provider.of<AppModel>(context).locale, ""),
              navigatorObservers: [
                FirebaseAnalyticsObserver(analytics: analytics),
              ],
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              localeListResolutionCallback:
                  S.delegate.listResolution(fallback: const Locale('en', '')),
              home: SplashScreenAnimate(),
              routes: <String, WidgetBuilder>{
                "/home": (context) => MainTabs(),
                "/login": (context) => LoginScreen(),
                "/register": (context) => RegistrationScreen(),
                '/products': (context) => ProductsPage(),
                '/wishlist': (context) => WishList(),
                '/checkout': (context) => Checkout(),
                '/orders': (context) => MyOrders(),
                '/onboardscreen': (context) => OnBoardScreen(),
                '/blogs': (context) => BlogScreen(),
                '/notify': (context) => Notifications(),
                '/chatlist': (context) => ListChat(),
                '/chatscreen': (context) => ChatScreen(),
              },
              theme: Provider.of<AppModel>(context).darkTheme
                  ? buildDarkTheme().copyWith(
                      primaryColor:
                          HexColor(_app.appConfig["Setting"]["MainColor"]))
                  : buildLightTheme().copyWith(
                      primaryColor:
                          HexColor(_app.appConfig["Setting"]["MainColor"])),
            ),
          );
        },
      ),
    );
  }
}
