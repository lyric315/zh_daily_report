class NewsDetailModel {
  String mBody;

  String mImage;

  String mTitle;

  String mShareUrl;

  NewsDetailModel({this.mBody, this.mImage, this.mShareUrl, this.mTitle});

  NewsDetailModel.fromJson(Map<String, dynamic> json)
      : mBody = json['body'],
        mImage = json['image'],
        mTitle = json['title'],
        mShareUrl = json['share_url'];
}
