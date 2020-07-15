import 'package:shop/models/create_order_response.dart';
import 'package:shop/models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shop/utils/endpoints.dart';

import 'package:shop/utils/util.dart' as utils;
import 'package:sprintf/sprintf.dart';

class ZaloPayConfig {
  static const String appId = "124705";
  static const String key1 = "UkRVyT0Mb4qBCZOZRRATz1dvEE2VDd0Y";
  static const String key2 = "7B8SfUKWyN1h2Y6qEer0UPnt5oaEgEHm";

  static const String appUser = "zamo app";
  static int transIdDefault = 1;

  /// use method for get detail value
//   String getAppId() => appId;
//   String getKey1() => key1;
//   String getKey2() => key2;
}

Future<CreateOrderResponse> createOrder({Product product}) async {
  var header = new Map<String, String>();
  header["Content-Type"] = "application/x-www-form-urlencoded";

  var body = new Map<String, String>();
  body["app_id"] = ZaloPayConfig.appId;
  body["app_user"] = ZaloPayConfig.appUser;
  body["app_time"] = DateTime.now().millisecondsSinceEpoch.toString();
  body["amount"] = product.price.toStringAsFixed(0);
  body["app_trans_id"] = utils.getAppTransId();
  body["embed_data"] = utils.getEmbedData();
  body["item"] = utils.getItems(
      id: product.id,
      name: product.name,
      price: product.price.toStringAsFixed(0));
  body["bank_code"] = utils.getBankCode();body["description"] = utils.getDescription(body["app_trans_id"]);

  var dataGetMac = sprintf("%s|%s|%s|%s|%s|%s|%s", [
    body["app_id"],
    body["app_trans_id"],
    body["app_user"],
    body["amount"],
    body["app_time"],
    body["embed_data"],
    body["item"]
  ]);
  body["mac"] = utils.getMacCreateOrder(dataGetMac);
  print("mac: ${body["mac"]}");
//    body["phone"] = "phone";
//    body["email"] = "email";
//    body["address"] ="address";

  http.Response response = await http.post(
    Uri.encodeFull(Endpoints.createOrderUrl),
    headers: header,
    body: body,
  );

  print("body_request: $body");
  if (response.statusCode != 200) {
    return null;
  }

  var data = jsonDecode(response.body);
  print("data_response: $data}");

  return CreateOrderResponse.fromJson(data);
}
