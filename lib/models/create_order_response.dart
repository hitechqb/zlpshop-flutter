class CreateOrderResponse {
  final String zptranstoken;
  final String orderurl;
  final int returncode;
  final String returnmessage;

  CreateOrderResponse(
      {this.zptranstoken, this.orderurl, this.returncode, this.returnmessage});

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      zptranstoken: json['zp_trans_token'] as String,
      orderurl: json['order_url'] as String,
      returncode: json['return_code'] as int,
      returnmessage: json['return_message'] as String,
     );
  }
}
