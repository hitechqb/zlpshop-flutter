import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop/models/create_order_response.dart';
import 'package:shop/models/product.dart';
import 'package:shop/repo/payment.dart';
import 'package:shop/screens/create_order_response.dart';
import 'package:shop/utils/util.dart' as utils;
import 'package:shop/utils/theme_data.dart';
import 'package:sprintf/sprintf.dart';
import 'package:crypto/crypto.dart';

class Home extends StatefulWidget {
  final String title;

  Home(this.title);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Product> _listProduct = [];
  var selectedItem = new Product();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listProduct = getListItems();
    selectedItem = _listProduct != null ? _listProduct[0] : null;
  }

  /// Build Item for Pay
  Widget _item(Product product) {
    var _textStyleSelected = TextStyle();
    if (selectedItem == product) {
      _textStyleSelected = TextStyle(color: Colors.white);
    }

    return GestureDetector(
      onTap: () {
        if (selectedItem != product) {
          setState(() {
            selectedItem = product;
          });
          print("Secleted: ${product.name}");
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        height: 120.0,
        width: 120.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: product != selectedItem
              ? _bgColorItem
              : AppColor.primaryColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Image.asset(
              product.imageUrl,
              width: 50.0,
              height: 50.0,
              fit: BoxFit.cover,
            ),
            Text(
              utils.formatNumber(product.price),
              style: _textStyleSelected,
            ),
          ],
        ),
      ),
    );
  }

  /// Build Button Pay
  Widget _btnPay(Product _product) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: GestureDetector(
          onTap: () async {
            var result = await createOrder(product: _product);
            if (result != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CreateOrderAndPayWidget(response: result, price: utils.formatNumber(_product.price),)));
            }
          },
          child: Container(
               height: 100.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text("THANH TOÁN",
                  style: TextStyle(color: Colors.white, fontSize: 20.0))),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _quickConfig,
        GridView.count(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
          padding: const EdgeInsets.all(20.0),
          children: List.generate(
            _listProduct.length,
            (index) => _item(_listProduct[index]),
          ),
        ),
        _btnPay(selectedItem),
      ],
    );
  }
}

/// Build Info App
Widget _quickConfig = Container(
  margin: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text("Thông tin"),
          ),
          Row(
            children: <Widget>[
              Text(
                "AppID: ",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
              Text(
                "124705",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
      _btnQuickEdit,
    ],
  ),
);

/// Build Button Quick Edit Info
Widget _btnQuickEdit = Container(
  decoration: BoxDecoration(
      color: AppColor.accentColor.withOpacity(0.8),
      borderRadius: BorderRadius.circular(25.0)),
  child: IconButton(
    icon: Icon(
      Icons.edit,
      color: Colors.white,
    ),
  ),
);

/// Background color items
final _bgColorItem = const Color(0xFFEEF7FB);
