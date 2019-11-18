import 'dart:async';

import 'package:flutter/material.dart';
import '../../models/app.dart';
import 'package:provider/provider.dart';

import '../../models/blog.dart';
import '../../screens/blogs.dart';
import '../../widgets/blog/blog_view.dart';
import 'header_view.dart';

class BlogListItems extends StatefulWidget {
  final config;
  final url;

  BlogListItems({this.config, this.url});

  @override
  _BlogListItemsState createState() => _BlogListItemsState();
}

class _BlogListItemsState extends State<BlogListItems> {
  Future<List<Blog>> _fetchBlogs;

  @override
  void initState() {
    _fetchBlogs = getBlogs(); // only create the future once.
    super.initState();
  }

  Future<List<Blog>> getBlogs() async {
    List<Blog> blogs = [];
    var _jsons = await Blog.getBlogs(url: widget.url, page: 1);
//    Provider.of<AppModel>(context).appConfig

    for (var item in _jsons) {
      blogs.add(Blog.fromJson(item));
    }
    return blogs;
  }

  Widget _buildHeader(context, blogs) {
    final locale = Provider.of<AppModel>(context).locale;
    if (widget.config.containsKey("name")) {
      var showSeeAllLink = widget.config['layout'] != "instagram";
      return HeaderView(
        headerText: locale == "ar"
            ? widget.config["name"]["ab"]
            : (locale == "vi" ? widget.config["name"]["vi"] : widget.config["name"]["en"]),
        showSeeAll: showSeeAllLink,
        callback: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogScreen(blogs: blogs),
            ),
          )
        },
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: <Widget>[
        FutureBuilder<List<Blog>>(
          future: _fetchBlogs,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Column(
                  children: <Widget>[
                    _buildHeader(context, null),
                    BlogItemView(item: Blog.empty(1)),
                    BlogItemView(item: Blog.empty(2)),
                    BlogItemView(item: Blog.empty(3)),
                  ],
                );
                break;
              case ConnectionState.done:
              default:
                if (snapshot.hasError) {
                  return Container();
                } else {
                  List<Blog> blogs = snapshot.data;
                  int length = blogs.length;
                  return Column(
                    children: <Widget>[
                      _buildHeader(context, blogs),
                      Container(
                        width: screenWidth,
                        height: screenWidth * 0.7,
                        child: PageView(
                          children: [
                            for (var i = 0; i < length; i = i + 3)
                              Column(
                                children: <Widget>[
                                  if (blogs[i] != null) BlogItemView(item: blogs[i]),
                                  if (i + 1 < length) BlogItemView(item: blogs[i + 1]),
                                  if (i + 2 < length) BlogItemView(item: blogs[i + 2]),
                                ],
                              )
                          ],
                        ),
                      ),
                    ],
                  );
                }
            }
          },
        ),
      ],
    );
  }
}
