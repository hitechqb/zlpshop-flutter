class CreateOrderResponse {
  final String zptranstoken;
  final String orderurl;
  final int returncode;
  final String returnmessage;

  CreateOrderResponse(
      {this.zptranstoken, this.orderurl, this.returncode, this.returnmessage});

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      zptranstoken: json['zptranstoken'] as String,
      orderurl: json['orderurl'] as String,
      returncode: json['returncode'] as int,
      returnmessage: json['returnmessage'] as String,
     );
  }
}
