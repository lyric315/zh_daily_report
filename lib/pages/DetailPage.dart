import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class DetailPage extends StatefulWidget {
  String mDetailPageUrl;

  String mDetialTitle;

  DetailPage(String url, String title) {
    this.mDetailPageUrl = url;
    this.mDetialTitle = title;
  }

  @override
  State<StatefulWidget> createState() {
    return new DetailPageState(mDetailPageUrl, mDetialTitle);
  }
}

class DetailPageState extends State<DetailPage> {
  String mDetailPageUrl;

  String mDetialTitle;

  DetailPageState(String url, String title) {
    this.mDetailPageUrl = url;
    this.mDetialTitle = title;
  }

  @override
  Widget build(BuildContext context) {
    return new WebviewScaffold(
      url: mDetailPageUrl,
      appBar: new AppBar(
        title: new Text(mDetialTitle),
      ),
    );
  }
}
