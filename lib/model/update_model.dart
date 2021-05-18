class UpdateModel {
  String status;
  String unit;
  String platform;
  String version;
  String required;

  UpdateModel(
      {this.status, this.unit, this.platform, this.version, this.required});

  UpdateModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    unit = json['unit'];
    platform = json['platform'];
    version = json['version'];
    required = json['required'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['unit'] = this.unit;
    data['platform'] = this.platform;
    data['version'] = this.version;
    data['required'] = this.required;
    return data;
  }
}