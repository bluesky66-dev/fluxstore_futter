import 'package:flutter/material.dart';
import 'package:html/parser.dart';

import '../../common/tools.dart';
import '../../models/blog.dart';
import '../../screens/blog_detail.dart';

class BlogItemView extends StatelessWidget {
  final item;

  BlogItemView({this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BlogDetail(item: item)));
      },
      child: ListTile(
        leading: Container(
          width: 100,
          height: 100,
          padding: EdgeInsets.symmetric(vertical: 4.0),
          alignment: Alignment.center,
          child: Hero(
              tag: 'blog-${item.id}',
              child: Tools.image(url: item.imageFeature, size: kSize.medium),
              transitionOnUserGestures: true),
        ),
        title: Text(item.title),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 5.0),
          child: Text(
            item.date,
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
        ),
        dense: false,
      ),
    );
  }
}

class BlogCardView extends StatelessWidget {
  final Blog item;

  BlogCardView({this.item});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => BlogDetail(item: item)));
        },
        child: Container(
          padding: EdgeInsets.only(right: 15, left: 15),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(3.0),
                child: Hero(
                  tag: 'blog-${item.id}',
                  child: Tools.image(
                    url: item.imageFeature,
                    width: screenWidth,
                    height: screenWidth * 0.5,
                    fit: BoxFit.fitWidth,
                    size: kSize.medium,
                  ),
                ),
              ),
              SizedBox(
                height: 30,
                width: screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      item.date,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).accentColor.withOpacity(0.5),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(width: 20.0),
                    Text(
                      item.author.toUpperCase(),
                      style: TextStyle(fontSize: 11, height: 2, fontWeight: FontWeight.bold),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                item.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              SizedBox(height: 10.0),
              Text(
                parse(item.subTitle).documentElement.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  color: Theme.of(context).accentColor.withOpacity(0.8),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ));
  }
}
