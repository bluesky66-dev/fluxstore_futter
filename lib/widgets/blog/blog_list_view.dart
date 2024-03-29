import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../models/app.dart';
import '../../models/blog.dart';
import 'blog_view.dart';

class BlogListView extends StatefulWidget {
  final List<Blog> blogs;

  BlogListView({this.blogs});

  @override
  _BlogListState createState() => _BlogListState();
}

class _BlogListState extends State<BlogListView> {
  RefreshController _refreshController;
  int _page = 1;
  bool _isEnd = false;
  double _padding = 2.0;
  List<Blog> _blogList = [];

  List<Blog> emptyList = [
    Blog.empty(1),
    Blog.empty(2),
    Blog.empty(3),
    Blog.empty(4),
    Blog.empty(5),
    Blog.empty(6)
  ];

  @override
  initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: widget.blogs == null);

    _blogList = widget.blogs == null || widget.blogs.isEmpty ? emptyList : widget.blogs;
  }

  Future<List<Blog>> _getBlogs() async {
    List<Blog> blogs = [];
    var _jsons = await Blog.getBlogs(
        url: Provider.of<AppModel>(context).appConfig['server']['blog'], page: _page);
    for (var item in _jsons) {
      blogs.add(Blog.fromJson(item));
    }
    return blogs;
  }

  _onRefresh() async {
    _page = 1;
    _isEnd = false;
    _blogList = await _getBlogs();
    _refreshController.refreshCompleted();
    setState(() {});
  }

  _onLoading() async {
    if (!_isEnd) {
      _page = _page + 1;
      List<Blog> newBlogs = await _getBlogs();
      if (newBlogs.isEmpty) {
        _isEnd = true;
      }
      _blogList = []..addAll(_blogList)..addAll(newBlogs);
      _refreshController.refreshCompleted();
    }
    setState(() {});
  }

  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      header: ClassicHeader(),
      enablePullDown: true,
      enablePullUp: !_isEnd,
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(_padding),
        child: Column(
          children: List.generate(
            _blogList.length,
            (index) {
              return BlogCardView(item: _blogList[index]);
            },
          ),
        ),
      ),
    );
  }
}
