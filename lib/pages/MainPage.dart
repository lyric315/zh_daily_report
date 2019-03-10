import 'package:flutter/material.dart';
import 'package:zh_daily_report/common/Constants.dart';

import '../list/MainListView.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  String mMainPageTitle = Constants.HOME_TITLE;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text('$mMainPageTitle'), //动态改变title
        centerTitle: true, // 居中
      ), //头部的标题AppBar
      body: new MainListView(),
    );
  }
}
