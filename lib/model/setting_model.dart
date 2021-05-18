class ServerSettingModel {
  String status;
  Settings settings;
  List<Data> data;

  ServerSettingModel({this.status, this.settings, this.data});

  ServerSettingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    settings = json['settings'] != String
        ? new Settings.fromJson(json['settings'])
        : String;
    if (json['data'] != String) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.settings != String) {
      data['settings'] = this.settings.toJson();
    }
    if (this.data != String) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Settings {
  String countryName;
  String countryFlag;
  String defaultDomain;
  String backupDomain;
  String isEnable;
  String setting;

  Settings(
      {this.countryName,
        this.countryFlag,
        this.defaultDomain,
        this.backupDomain,
        this.isEnable,
        this.setting});

  Settings.fromJson(Map<String, dynamic> json) {
    countryName = json['country_name'];
    countryFlag = json['country_flag'];
    defaultDomain = json['default_domain'];
    backupDomain = json['backup_domain'];
    isEnable = json['is_enable'];
    setting = json['setting'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['country_name'] = this.countryName;
    data['country_flag'] = this.countryFlag;
    data['default_domain'] = this.defaultDomain;
    data['backup_domain'] = this.backupDomain;
    data['is_enable'] = this.isEnable;
    data['setting'] = this.setting;
    return data;
  }
}

class Data {
  String settingId;
  String flag;
  String country;
  String domain;
  String backupDomain;
  String enable;
  String userMessage1Enable;
  String userMessage1;
  String userMessage2Enable;
  String userMessage2;
  String userSplashScreen;
  String merchantMessage1Enable;
  String merchantMessage1;
  String merchantMessage2Enable;
  String merchantMessage2;
  String merchantSplashScreen;
  String driverMessage1Enable;
  String driverMessage1;
  String driverMessage2Enable;
  String driverMessage2;
  String driverSplashScreen;
  String adminMessage1Enable;
  String adminMessage1;
  String adminMessage2Enable;
  String adminMessage2;
  String adminSplashScreen;
  String apiKey;
  String countryCode;
  String custom1;
  String custom2;

  Data(
      {this.settingId,
        this.flag,
        this.country,
        this.domain,
        this.backupDomain,
        this.enable,
        this.userMessage1Enable,
        this.userMessage1,
        this.userMessage2Enable,
        this.userMessage2,
        this.userSplashScreen,
        this.merchantMessage1Enable,
        this.merchantMessage1,
        this.merchantMessage2Enable,
        this.merchantMessage2,
        this.merchantSplashScreen,
        this.driverMessage1Enable,
        this.driverMessage1,
        this.driverMessage2Enable,
        this.driverMessage2,
        this.driverSplashScreen,
        this.adminMessage1Enable,
        this.adminMessage1,
        this.adminMessage2Enable,
        this.adminMessage2,
        this.adminSplashScreen,
        this.apiKey,
        this.countryCode,
        this.custom1,
        this.custom2});

  Data.fromJson(Map<String, dynamic> json) {
    settingId = json['setting_id'];
    flag = json['flag'];
    country = json['country'];
    domain = json['domain'];
    backupDomain = json['backup_domain'];
    enable = json['enable'];
    userMessage1Enable = json['user_message1_enable'];
    userMessage1 = json['user_message1'];
    userMessage2Enable = json['user_message2_enable'];
    userMessage2 = json['user_message2'];
    userSplashScreen = json['user_splash_screen'];
    merchantMessage1Enable = json['merchant_message1_enable'];
    merchantMessage1 = json['merchant_message1'];
    merchantMessage2Enable = json['merchant_message2_enable'];
    merchantMessage2 = json['merchant_message2'];
    merchantSplashScreen = json['merchant_splash_screen'];
    driverMessage1Enable = json['driver_message1_enable'];
    driverMessage1 = json['driver_message1'];
    driverMessage2Enable = json['driver_message2_enable'];
    driverMessage2 = json['driver_message2'];
    driverSplashScreen = json['driver_splash_screen'];
    adminMessage1Enable = json['admin_message1_enable'];
    adminMessage1 = json['admin_message1'];
    adminMessage2Enable = json['admin_message2_enable'];
    adminMessage2 = json['admin_message2'];
    adminSplashScreen = json['admin_splash_screen'];
    apiKey = json['api_key'];
    countryCode = json['country_code'];
    custom1 = json['custom_1'];
    custom2 = json['custom_2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['setting_id'] = this.settingId;
    data['flag'] = this.flag;
    data['country'] = this.country;
    data['domain'] = this.domain;
    data['backup_domain'] = this.backupDomain;
    data['enable'] = this.enable;
    data['user_message1_enable'] = this.userMessage1Enable;
    data['user_message1'] = this.userMessage1;
    data['user_message2_enable'] = this.userMessage2Enable;
    data['user_message2'] = this.userMessage2;
    data['user_splash_screen'] = this.userSplashScreen;
    data['merchant_message1_enable'] = this.merchantMessage1Enable;
    data['merchant_message1'] = this.merchantMessage1;
    data['merchant_message2_enable'] = this.merchantMessage2Enable;
    data['merchant_message2'] = this.merchantMessage2;
    data['merchant_splash_screen'] = this.merchantSplashScreen;
    data['driver_message1_enable'] = this.driverMessage1Enable;
    data['driver_message1'] = this.driverMessage1;
    data['driver_message2_enable'] = this.driverMessage2Enable;
    data['driver_message2'] = this.driverMessage2;
    data['driver_splash_screen'] = this.driverSplashScreen;
    data['admin_message1_enable'] = this.adminMessage1Enable;
    data['admin_message1'] = this.adminMessage1;
    data['admin_message2_enable'] = this.adminMessage2Enable;
    data['admin_message2'] = this.adminMessage2;
    data['admin_splash_screen'] = this.adminSplashScreen;
    data['api_key'] = this.apiKey;
    data['country_code'] = this.countryCode;
    data['custom_1'] = this.custom1;
    data['custom_2'] = this.custom2;
    return data;
  }
}