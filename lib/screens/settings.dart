import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/config.dart' as config;
import '../common/constants.dart';
import '../common/styles.dart';
import '../generated/i18n.dart';
import '../models/app.dart';
import '../models/user.dart';
import '../models/wishlist.dart';
import '../screens/chat/chat_list_by_admin.dart';
import '../screens/chat/chat_screen.dart';
import '../widgets/fab_circle_menu.dart';
import 'language.dart';
import 'notification.dart';

class SettingScreen extends StatefulWidget {
  final User user;
  final VoidCallback onLogout;

  SettingScreen({this.user, this.onLogout});

  @override
  State<StatefulWidget> createState() {
    return SettingScreenState();
  }
}

class SettingScreenState extends State<SettingScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final bannerHigh = 200.0;
  bool enabledNotification = true;

  RateMyApp _rateMyApp = RateMyApp(
    minDays: 7,
    minLaunches: 10,
    remindDays: 7,
    remindLaunches: 10,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      checkNotificationPermission();
    });

    // With this, we will be able to check if the permission is granted or not
    // when returning to the application
    WidgetsBinding.instance.addObserver(this);
  }


  IconButton getIconButton(IconData iconData, double iconSize, Color iconColor, String appUrl) {
    return IconButton(
        icon: Icon(
          iconData,
          size: iconSize,
          color: iconColor,
        ),
        onPressed: () async {
          print(appUrl);
          await canLaunch(appUrl) ? launch(appUrl) : print("error on launching app");
        });
  }

  List<Widget> getFabIconButton() {
    List<Widget> listWidget = [];
    for (int i = 0; i < config.smartChat.length; i++) {
      String appUrl = config.smartChat[i]['app'];

      canLaunch(appUrl).then((can) {
        if (can)
          listWidget.add(getIconButton(config.smartChat[i]['iconData'], 35, Colors.white, appUrl));
      });
    }

    listWidget.add(
      IconButton(
          icon: Icon(
            FontAwesomeIcons.google,
            size: 35,
            color: kLightPrimary,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(
                          user: widget.user,
                          userEmail: widget.user.email,
                        )));
          }),
    );
    return listWidget;
  }

  void checkNotificationPermission() async {
    try {
      NotificationPermissions.getNotificationPermissionStatus().then((status) {
        if (mounted)
          setState(() {
            enabledNotification = status == PermissionStatus.granted;
          });
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkNotificationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishListCount = Provider.of<WishListModel>(context).products.length;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      floatingActionButton: (widget.user.username == config.adminEmail)
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ListChat(user: widget.user))); //
              },
              child: Icon(
                Icons.chat,
                size: 22,
              ),
            )
          : FabCircularMenu(
              child: Container(),
              fabOpenIcon: Icon(Icons.chat),
              ringColor: Theme.of(context).primaryColor,
              ringWidth: 125.0,
              ringDiameter: 300.0,
              fabMargin: EdgeInsets.all(10),
              options: getFabIconButton(),
            ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Color(0xFF0084C9),
            leading: IconButton(
              icon: Icon(
                Icons.blur_on,
                color: Colors.white70,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            expandedHeight: bannerHigh,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                title: Text(S.of(context).settings,
                    style:
                        TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
                background: Image.network(
                  kProfileBackground,
                  fit: BoxFit.cover,
                )),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      ListTile(
                        leading: widget.user.picture != null
                            ? CircleAvatar(backgroundImage: NetworkImage(widget.user.picture))
                            : Icon(Icons.face),
                        title: Text(widget.user.name, style: TextStyle(fontSize: 16)),
                      ),
                      ListTile(
                        leading: Icon(Icons.email),
                        title: Text(widget.user.email, style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(height: 30.0),
                      Text(S.of(context).generalSetting,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      SizedBox(height: 10.0),
                      Card(
                        margin: EdgeInsets.only(bottom: 2.0),
                        elevation: 0,
                        child: ListTile(
                          leading: Image.asset(
                            'assets/icons/profile/icon-heart.png',
                            width: 20,
                            color: Theme.of(context).accentColor,
                          ),
                          title: Text(S.of(context).myWishList, style: TextStyle(fontSize: 15)),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (wishListCount > 0)
                              Text(
                                "$wishListCount ${S.of(context).items}",
                                style:
                                    TextStyle(fontSize: 14, color: Theme.of(context).primaryColor),
                              ),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600)
                          ]),
                          onTap: () {
                            Navigator.pushNamed(context, "/wishlist");
                          },
                        ),
                      ),
                      Divider(
                        color: Colors.black12,
                        height: 1.0,
                        indent: 75,
                        //endIndent: 20,
                      ),
                      Card(
                        margin: EdgeInsets.only(bottom: 2.0),
                        elevation: 0,
                        child: SwitchListTile(
                          secondary: Image.asset(
                            'assets/icons/profile/icon-notify.png',
                            width: 25,
                            color: Theme.of(context).accentColor,
                          ),
                          value: enabledNotification,
                          activeColor: Color(0xFF0066B4),
                          onChanged: (bool value) {
                            if (value) {
                              NotificationPermissions.requestNotificationPermissions(
                                      const NotificationSettingsIos(
                                          sound: true, badge: true, alert: true))
                                  .then((_) {
                                checkNotificationPermission();
                              });
                            }
                            setState(() {
                              enabledNotification = value;
                            });
                          },
                          title: Text(
                            S.of(context).getNotification,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.black12,
                        height: 1.0,
                        indent: 75,
                        //endIndent: 20,
                      ),
                      enabledNotification
                          ? Card(
                              margin: EdgeInsets.only(bottom: 2.0),
                              elevation: 0,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => Notifications()));
                                },
                                child: ListTile(
                                  leading: Icon(
                                    Icons.list,
                                    size: 24,
                                    color: Theme.of(context).accentColor,
                                  ),
                                  title: Text(S.of(context).listMessages),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: kGrey600,
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      enabledNotification
                          ? Divider(
                              color: Colors.black12,
                              height: 1.0,
                              indent: 75,
                              //endIndent: 20,
                            )
                          : Container(),
                      Divider(
                        color: Colors.black12,
                        height: 1.0,
                        indent: 75,
                        //endIndent: 20,
                      ),
                      Card(
                        margin: EdgeInsets.only(bottom: 2.0),
                        elevation: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => Language()));
                          },
                          child: ListTile(
                            leading: Icon(
                              Icons.language,
                              color: Theme.of(context).accentColor,
                              size: 24,
                            ),
                            title: Text(S.of(context).language),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: kGrey600,
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.black12,
                        height: 1.0,
                        indent: 75,
                        //endIndent: 20,
                      ),
                      Card(
                        margin: EdgeInsets.only(bottom: 2.0),
                        elevation: 0,
                        child: SwitchListTile(
                          secondary: Icon(
                            Icons.dashboard,
                            color: Theme.of(context).accentColor,
                            size: 24,
                          ),
                          value: Provider.of<AppModel>(context).darkTheme,
                          activeColor: Color(0xFF0066B4),
                          onChanged: (bool value) {
                            if (value) {
                              Provider.of<AppModel>(context).updateTheme(true);
                            } else
                              Provider.of<AppModel>(context).updateTheme(false);
                          },
                          title: Text(
                            S.of(context).darkTheme,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.0),
                      Text(S.of(context).orderDetail,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      SizedBox(height: 10.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/orders");
                        },
                        child: Card(
                          margin: EdgeInsets.only(bottom: 2.0),
                          elevation: 0,
                          child: ListTile(
                            leading: Icon(
                              Icons.history,
                              color: Theme.of(context).accentColor,
                              size: 24,
                            ),
                            title: Text(S.of(context).orderHistory, style: TextStyle(fontSize: 16)),
                            trailing: Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.black12,
                        height: 1.0,
                        indent: 75,
                        //endIndent: 20,
                      ),
                      Card(
                        margin: EdgeInsets.only(bottom: 2.0),
                        elevation: 0,
                        child: ListTile(
                          onTap: () {
                            _rateMyApp.showRateDialog(context).then((v) => setState(() {}));
                          },
                          leading: Image.asset(
                            'assets/icons/profile/icon-star.png',
                            width: 24,
                            color: Theme.of(context).accentColor,
                          ),
                          title: Text(S.of(context).rateTheApp, style: TextStyle(fontSize: 16)),
                          trailing: Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600),
                        ),
                      ),
                      Divider(
                        color: Colors.black12,
                        height: 1.0,
                        indent: 75,
                        //endIndent: 20,
                      ),
                      Card(
                        margin: EdgeInsets.only(bottom: 2.0),
                        elevation: 0,
                        child: ListTile(
                          onTap: widget.onLogout,
                          leading: Image.asset(
                            'assets/icons/profile/icon-logout.png',
                            width: 24,
                            color: Theme.of(context).accentColor,
                          ),
                          title: Text(S.of(context).logout, style: TextStyle(fontSize: 16)),
                          trailing: Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
