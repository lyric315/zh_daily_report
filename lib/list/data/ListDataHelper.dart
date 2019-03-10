import 'dart:io';

import 'package:dio/dio.dart';
import 'package:zh_daily_report/common/Constants.dart';
import 'package:zh_daily_report/model/HotNewsModel.dart';
import 'package:zh_daily_report/net/Apis.dart';
import 'package:zh_daily_report/net/DioFactory.dart';
import 'package:zh_daily_report/util/DateUtil.dart';

class ListDataHelper {
  ///数据请求监听
  IListDataListener mListDataListener;

  ///当前分页数据的时间戳：loadmore生效
  String mDateTimeStamp;

  ///分页偏移值
  int mDateOffset;

  ListDataHelper(this.mListDataListener);

  void refreshListData() {
    _getList(null).then((data) {
      if (mListDataListener != null) {
        if (data != null) {
          mListDataListener.onLoadNewsSuc(data);
        } else {
          mListDataListener.onLoadNewsFail();
        }
      }
    }).catchError((error) {
      if (mListDataListener != null) {
        mListDataListener.onLoadNewsFail();
      }
    });
  }

  void loadMore() {
    if (mDateTimeStamp == null || mDateOffset == 0) {
      mDateOffset = 1;
    }
    DateTime dateTime = new DateTime.now();
    mDateTimeStamp = DateUtil.formatDateSimple(
        dateTime.subtract(new Duration(days: mDateOffset)));
    _getList(mDateTimeStamp).then((data) {
      if (mListDataListener != null) {
        if (data != null) {
          mListDataListener.onLoadNewsSuc(data);
        } else {
          mListDataListener.onLoadNewsFail();
        }
      }
    }).catchError((error) {
      if (mListDataListener != null) {
        mListDataListener.onLoadNewsFail();
      }
    });
  }

  ///首页数据刷新时，强制将offset清空
  void clearDateOffset() {
    mDateTimeStamp = null;
    mDateOffset = 0;
  }

  ///loadmore完成，分页偏移值加1
  void addDateOffset() {
    mDateOffset++;
    print("mDateOffset: $mDateOffset");
  }

  Future<HotNewsModel> _getList(String date) {
    return _getListDatas(date);
  }

  Future<HotNewsModel> _getListDatas(String date) async {
    Dio dio = DioFactory.getInstance().getDio();

    String url;
    if (null == date) {
      url = Constants.BASE_URL + Apis.NEWS_LATEST;
    } else {
      url = Constants.BASE_URL + Apis.NEWS_BEFORE + date;
    }

    print(url);

    HotNewsModel hotNewsStoriesModel;
    try {
      Response response = await dio.get(url);
      if (response.statusCode == HttpStatus.OK) {
        print(response.data);
        String date = response.data['date'];

        List stories = response.data['stories'];

        List topStories = response.data['top_stories'];

        List<HotNewsTopStoriesModel> topStoriesList;

        List<HotNewsStoriesModel> storiesList = stories.map((model) {
          return new HotNewsStoriesModel.fromJson(model);
        }).toList();

        //topStories根据接口只有当天有，过去时间的topStories为空
        if (topStories != null && topStories.isNotEmpty) {
          topStoriesList = topStories.map((model) {
            return new HotNewsTopStoriesModel.fromJson(model);
          }).toList();
        }

        hotNewsStoriesModel = new HotNewsModel(
            date: date, stories: storiesList, topStories: topStoriesList);
      }
    } catch (exception) {
      //ignore
      print(exception);
    }

    return hotNewsStoriesModel;
  }
}

abstract class IListDataListener {
  void onLoadNewsSuc(HotNewsModel model);

  void onLoadNewsFail();
}
