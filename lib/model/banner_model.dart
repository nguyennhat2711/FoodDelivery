class HomeBannerModel {
  String bannerId;
  String title;
  String subTitle;
  String banner;
  String actions;
  String pageId;
  String customUrl;

  HomeBannerModel(
      {this.bannerId,
      this.title,
      this.subTitle,
      this.banner,
      this.actions,
      this.pageId,
      this.customUrl});

  HomeBannerModel.fromJson(Map<String, dynamic> json) {
    bannerId = json['banner_id'];
    title = json['title'];
    subTitle = json['sub_title'];
    banner = json['banner'];
    actions = json['actions'];
    pageId = json['page_id'];
    customUrl = json['custom_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['banner_id'] = this.bannerId;
    data['title'] = this.title;
    data['sub_title'] = this.subTitle;
    data['banner'] = this.banner;
    data['actions'] = this.actions;
    data['page_id'] = this.pageId;
    data['custom_url'] = this.customUrl;
    return data;
  }
}
