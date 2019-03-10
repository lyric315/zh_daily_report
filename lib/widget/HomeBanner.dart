import 'dart:async';

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:zh_daily_report/model/HotNewsModel.dart';

class HomeBanner extends StatefulWidget {
  final mHomeBannerHeight;

  final List<HotNewsTopStoriesModel> topList;

  HomeBanner(this.topList, this.mHomeBannerHeight);

  @override
  State<StatefulWidget> createState() {
    return new HomeBannerState();
  }
}

class HomeBannerState extends State<HomeBanner> {
  static int fakeLength = 1000;

  int mCurPageIndex = 0;

  int mCurIndicatorsIndex = 0;

  PageController mPageController =
      new PageController(initialPage: fakeLength ~/ 2);

  List<Widget> mIndicators = [];

  List<HotNewsTopStoriesModel> mFakeList = [];

  Duration mBannerDuration = new Duration(seconds: 3);

  Duration _bannerAnimationDuration = new Duration(milliseconds: 500);

  Timer mTimer;

  bool reverse = false;

  bool _isEndScroll = true;

  @override
  void initState() {
    super.initState();
    mCurPageIndex = fakeLength ~/ 2;

    initTimer();
  }

  @override
  void dispose() {
    super.dispose();
    mTimer.cancel();
  }

  //通过时间timer做轮询，达到自动播放的效果
  initTimer() {
    mTimer = new Timer.periodic(mBannerDuration, (timer) {
      if (_isEndScroll) {
        mPageController.animateToPage(mCurPageIndex + 1,
            duration: _bannerAnimationDuration, curve: Curves.linear);
      }
    });
  }

  //用于做banner循环
  _initFakeList() {
    for (int i = 0; i < fakeLength; i++) {
      mFakeList.addAll(widget.topList);
    }
  }

  _initIndicators() {
    mIndicators.clear();
    for (int i = 0; i < widget.topList.length; i++) {
      mIndicators.add(new SizedBox(
        width: 5.0,
        height: 5.0,
        child: new Container(
          color: i == mCurIndicatorsIndex ? Colors.white : Colors.grey,
        ),
      ));
    }
  }

  _changePage(int index) {
    mCurPageIndex = index;
    //获取指示器索引
    mCurIndicatorsIndex = index % widget.topList.length;
    setState(() {});
  }

  //创建指示器
  Widget _buildIndicators() {
    _initIndicators();
    return new Align(
      alignment: Alignment.bottomCenter,
      child: new Container(
          color: Colors.black45,
          height: 20.0,
          child: new Center(
            child: new SizedBox(
              width: widget.topList.length * 16.0,
              height: 5.0,
              child: new Row(
                children: mIndicators,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
            ),
          )),
    );
  }

  Widget _buildPagerView() {
    _initFakeList();
    //检查手指和自动播放的是否冲突，如果滚动停止开启自动播放，反之停止自动播放
    return new NotificationListener(
        onNotification: (ScrollNotification scrollNotification) {
          if (scrollNotification is ScrollEndNotification ||
              scrollNotification is UserScrollNotification) {
            _isEndScroll = true;
          } else {
            _isEndScroll = false;
          }
          return false;
        },
        child: new PageView.builder(
          controller: mPageController,
          itemBuilder: (BuildContext context, int index) {
            return _buildItem(context, index);
          },
          itemCount: mFakeList.length,
          onPageChanged: (index) {
            _changePage(index);
          },
        ));
  }

  Widget _buildBanner() {
    return new Container(
      height: widget.mHomeBannerHeight,
      //指示器覆盖在pagerview上，所以用Stack
      child: new Stack(
        children: <Widget>[
          _buildPagerView(),
          _buildIndicators(),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    HotNewsTopStoriesModel item = mFakeList[index];
    return new GestureDetector(
      onTap: () {
        //TODO 通过路由跳转到详情
        //RouteUtil.route2Detail(context, '${item.id}'); // 通过路由跳转到详情
      },
      onTapDown: (donw) {
        _isEndScroll = false;
      },
      onTapUp: (up) {
        _isEndScroll = true;
      },
      child: new FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: item.image,
          height: widget.mHomeBannerHeight,
          fit: BoxFit.fitWidth),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBanner();
  }
}
