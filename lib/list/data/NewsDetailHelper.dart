import 'dart:io';

import 'package:dio/dio.dart';
import 'package:zh_daily_report/common/Constants.dart';
import 'package:zh_daily_report/model/NewsDetailModel.dart';
import 'package:zh_daily_report/net/Apis.dart';
import 'package:zh_daily_report/net/DioFactory.dart';

class NewsDetailDataHelper {
  IDetailDataListener mDataListener;

  NewsDetailDataHelper(this.mDataListener);

  void tryGetNewsDetailData(int newsId) {
    getNewsDetailData(newsId).then((data) {
      if (mDataListener != null) {
        mDataListener.onNewsDetailSuc(data);
      } else {
        mDataListener.onNewsDetailFail();
      }
    }).catchError((error) {
      if (mDataListener != null) mDataListener.onNewsDetailFail();
    });
  }

  Future<NewsDetailModel> getNewsDetailData(int newsId) async {
    Dio dio = DioFactory.getInstance().getDio();

    String url = Constants.BASE_URL + Apis.DETAIL + newsId.toString();
    print(url);

    try {
      Response response = await dio.get(url);
      if (response.statusCode == HttpStatus.OK) {
        print(response.data);

        String body = response.data['body'];
        String title = response.data['title'];
        String image = response.data['image'];
        String share_url = response.data['share_url'];

        return NewsDetailModel(
            mBody: body, mImage: image, mTitle: title, mShareUrl: share_url);
      }
    } catch (exception) {
      //ignore
      print(exception);
    }
    return null;
  }
}

abstract class IDetailDataListener {
  void onNewsDetailSuc(NewsDetailModel model);

  void onNewsDetailFail();
}
