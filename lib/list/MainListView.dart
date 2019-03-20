import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zh_daily_report/common/Constants.dart';
import 'package:zh_daily_report/list/data/ListDataHelper.dart';
import 'package:zh_daily_report/list/data/NewsDetailHelper.dart';
import 'package:zh_daily_report/model/HotNewsModel.dart';
import 'package:zh_daily_report/model/NewsDetailModel.dart';
import 'package:zh_daily_report/pages/DetailPage.dart';
import 'package:zh_daily_report/util/CollectionUtils.dart';
import 'package:zh_daily_report/widget/CommonDivider.dart';
import 'package:zh_daily_report/widget/CommonLoadingDialog.dart';
import 'package:zh_daily_report/widget/CommonRetry.dart';
import 'package:zh_daily_report/widget/HomeBanner.dart';

///知乎日报列表
class MainListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MainListViewState();
  }
}

class MainListViewState extends State<MainListView>
    implements IListDataListener, IDetailDataListener {
  final GlobalKey<RefreshIndicatorState> mRefreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  List<HotNewsStoriesModel> mNormalDatas = new List<HotNewsStoriesModel>();
  List<HotNewsTopStoriesModel> mTopDatas = new List<HotNewsTopStoriesModel>();

  bool mIsShowRetry = false;

  bool mIsLoadMore = false;

  ScrollController mScrollController;

  ListDataHelper mListDataHelper;

  NewsDetailDataHelper mNewsDetailHelper;

  void _scrollListener() {
    //滑到最底部刷新
    if (mScrollController.position.pixels ==
        mScrollController.position.maxScrollExtent) {
      //load more
      _loadMoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildList(context);
  }

  @override
  void initState() {
    super.initState();
    mScrollController = new ScrollController()..addListener(_scrollListener);
    mListDataHelper = new ListDataHelper(this);
    mNewsDetailHelper = new NewsDetailDataHelper(this);
    _refreshData();
  }

  @override
  void dispose() {
    super.dispose();
    mScrollController.removeListener(_scrollListener);
  }

  Widget _buildList(BuildContext context) {
    var content;

    if (CollectionUtils.isEmpty(mNormalDatas)) {
      if (mIsShowRetry) {
        mIsShowRetry = false;
        content = CommonRetry.buildRetry(_refreshData);
      } else {
        content = ProgressDialog.buildProgressDialog();
      }
    } else {
      content = new ListView.builder(
        //设置physics属性总是可滚动
        physics: AlwaysScrollableScrollPhysics(),
        controller: mScrollController,
        itemCount: mNormalDatas.length,
        itemBuilder: _buildItem,
      );
    }

    var refreshIndicator = new NotificationListener(
      child: new RefreshIndicator(
        key: mRefreshIndicatorKey,
        onRefresh: _refreshData,
        child: content,
      ),
    );

    return refreshIndicator;
  }

  ///根据type组装数据
  Widget _buildItem(BuildContext context, int index) {
    final HotNewsStoriesModel item = mNormalDatas[index];

    Widget widget;

    switch (item.itemType) {
      case HotNewsStoriesModel.itemTypeBanner:
        widget = new HomeBanner(mTopDatas, Constants.BANNER_HEIGHT);
        break;
      case HotNewsStoriesModel.itemTypeNormal:
        widget = _buildNormalItem(item);
        break;
//      case HotNewsStoriesModel.itemTypeDate:
//        widget = _buildDateTimeItem(item);
        break;
    }
    return widget;
  }

  Widget _buildNormalItem(HotNewsStoriesModel item) {
    final String imgUrl = item.images[0];
    final String title = item.title;
    final int id = item.id;

    return new InkWell(
        onTap: () {
          // TODO 跳转到详情页
          //RouteUtil.route2Detail(context, '$id');
          _tryGetNewsDetail(id);
        },
        child: new Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: new SizedBox(
              height: Constants.normalItemHeight,
              child: new Column(
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new Text(
                          title,
                          style: new TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w300),
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new SizedBox(
                          height: 80.0,
                          width: 80.0,
                          child: new Image.network(imgUrl),
                        ),
                      )
                    ],
                  ),
                  new Expanded(
                    child: new Align(
                      alignment: Alignment.bottomCenter,
                      child: CommonDivider.buildDivider(),
                    ),
                  ),
                ],
              ),
            )));
  }

  Future<Null> _refreshData() {
    mIsLoadMore = false;

    final Completer<Null> completer = new Completer<Null>();
    mListDataHelper.refreshListData();
    completer.complete(null);

    return completer.future;
  }

  Future<Null> _loadMoreData() {
    mIsLoadMore = true;

    final Completer<Null> completer = new Completer<Null>();
    mListDataHelper.loadMore();
    setState(() {});

    completer.complete(null);

    return completer.future;
  }

  ///知乎日报数据加载失败
  @override
  void onLoadNewsFail() {
    if (!mIsLoadMore) {
      mIsLoadMore = true;
      setState(() {});
    }
  }

  ///知乎日报数据返回成功
  @override
  void onLoadNewsSuc(HotNewsModel model) {
    if (!mounted) return; //异步处理，防止报错

    if (model == null ||
            CollectionUtils.isEmpty(model
                .stories) /* ||
        CollectionUtils.isEmpty(model.topStories)*/
        ) {
      return;
    }

    List<HotNewsStoriesModel> normalList = model.stories;
    List<HotNewsTopStoriesModel> topList = model.topStories;

    if (mIsLoadMore) {
      mNormalDatas.addAll(normalList);
      mListDataHelper.addDateOffset();
    } else {
      mNormalDatas = normalList;
      mTopDatas = topList;

      int offset = Constants.normalItemHeight.round() * mNormalDatas.length;
      if (null != mTopDatas && mTopDatas.isNotEmpty) {
        offset = offset + Constants.BANNER_HEIGHT.round();
        HotNewsStoriesModel bannerItem = new HotNewsStoriesModel();
        bannerItem.setItemType(HotNewsStoriesModel.itemTypeBanner);
        mNormalDatas.insert(0, bannerItem);
      }
      mListDataHelper.clearDateOffset();
    }

    setState(() {});
  }

  void _tryGetNewsDetail(int newsId) {
    if (mNewsDetailHelper != null) {
      mNewsDetailHelper.tryGetNewsDetailData(newsId);
    }
  }

  @override
  void onNewsDetailFail() {
    // TODO: implement onNewsDetailFail
  }

  @override
  void onNewsDetailSuc(NewsDetailModel model) {
    // TODO: implement onNewsDetailSuc
    if (model != null) {
      Navigator.push(context, new MaterialPageRoute(builder: (context) {
        return new DetailPage(model.mShareUrl, model.mTitle);
      }));
    }
  }
}
