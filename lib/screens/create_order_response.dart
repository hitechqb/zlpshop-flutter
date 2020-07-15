import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shop/models/create_order_response.dart';
import 'package:shop/utils/images_network.dart';
import 'package:shop/utils/theme_data.dart';
import 'package:shop/utils/util.dart';

class CreateOrderAndPayWidget extends StatefulWidget {
  final CreateOrderResponse response;
  final String price;
  CreateOrderAndPayWidget({Key key, this.response, this.price});

  @override
  _CreateOrderAndPayWidgetState createState() => _CreateOrderAndPayWidgetState();
}

class _CreateOrderAndPayWidgetState extends State<CreateOrderAndPayWidget> {
  static const EventChannel eventChannel = EventChannel('flutter.native/eventPayOrder');
  static const MethodChannel platform = const MethodChannel('flutter.native/channelPayOrder');

  String _paymentStatus = 'Đang xử lý';
  String _textButton = "THANH TOÁN";
  Future<void> _onTabButton;

  Future<void> backToHome(BuildContext context) async{
    Navigator.pop(context);
  }

  Future<void> getPayment(String zptoken) async {
     String response = "";
    try {
      final String result = await platform.invokeMethod('payOrder', {"zptoken": zptoken});
       response = result;
       print("payOrder Result: '$result'.");

    } on PlatformException catch (e) {
      print("Failed to Invoke: '${e.message}'.");
      response = "Thanh toán thất bại";
    }

    setState(() {
      _paymentStatus = response;
      _textButton = "TRANG CHỦ";
    });
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    }
    _onTabButton = getPayment(widget.response.zptranstoken);
  }

  void _onEvent(Object event) {
    print("_onEvent: '$event'.");
    setState(() {
      if (event.hashCode == 1) {
        _paymentStatus = "Thanh toán thành công";
      } else {
        _paymentStatus = "Giao dịch thất bại";
      }
      _textButton = "TRANG CHỦ";
    });
  }

  void _onError(Object error) {
    print("_onError: '$error'.");
    setState(() {
      _paymentStatus = "Giao dịch thất bại";
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Build Order Detail
    Widget _orderDetail = Center(
      child: Stack(
        children: <Widget>[
          Container(
            //color: Colors.orangeAccent,
            margin: const EdgeInsets.only(top: 25.0),
            height: MediaQuery.of(context).size.height / 2,
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border.fromBorderSide(
                    BorderSide(width: 1.0, color: Colors.black12)
                ),
                borderRadius: BorderRadius.circular(12.0)
            ),
            child: Container(
              child: _orderWidget(widget.response, widget.price, _paymentStatus),
            ),
          ),
        ],
      ),
    );

    /// Build Button PayOrder
    Widget _btnPayOrder = Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: GestureDetector(
        onTap: () async {
           if (_textButton != "THANH TOÁN") {
             await backToHome(context);
           } else{
             await _onTabButton;
           }
        },
        child: Container(
            height: 60.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColor.primaryColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(_textButton,
                style: TextStyle(color: Colors.white, fontSize: 20.0))),
      ),
    );

    /// Build BottomNavigationBar
    final _bottomNavigationBar = BottomNavigationBar(
      iconSize: 30.0,
      currentIndex: 0,
      items: [
        BottomNavigationBarItem(
            title: Text("Get Status"),
            icon: Icon(Icons.highlight)
        ),
        BottomNavigationBarItem(
            title: Text("Refund"),
            icon: Icon(Icons.create)
        ),
        BottomNavigationBarItem(
            title: Text("Capture"),
            icon: Icon(Icons.fullscreen)
        ),
      ],
    );

    ///
    final isSuccess = widget.response.returncode == 1;
    final cardDetail = isSuccess
        ? _orderDetail
        : Text("Tạo đơn hàng thất bại");

    return Scaffold(
      appBar: AppBar(title: Text("Thông tin đơn hàng")),
      body: Container(
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                      child: cardDetail),
                  _btnPayOrder,
                ],
              ),
            ),
          )),
      bottomNavigationBar: _bottomNavigationBar,
    );
  }
}

Widget _orderWidget(CreateOrderResponse response, String price, String _paymentStatus) {
  final textStyle = TextStyle(color: Colors.black54);
  final moneyStyle = TextStyle(color: AppColor.accentColor, fontSize: 22.0, fontWeight: FontWeight.w600);
  final valueStyle = TextStyle(color: AppColor.accentColor, fontSize: 18.0, fontWeight: FontWeight.w400);
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
          child: Text("CHI TIẾT ORDER", style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600))),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text("Đơn giá: ", style: textStyle,),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(price, style: moneyStyle,),
          ),
        ],
      ),

      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text("zptranstoken", style: textStyle,),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(response.zptranstoken, style: valueStyle,),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Text("Trạng thái đơn hàng", style: textStyle,),
      ),
      Container(
        padding: const EdgeInsets.all(20.0),
        color: AppColor.accentColor.withOpacity(0.8),
        child: Text(_paymentStatus, style: TextStyle(color: Colors.white),),
       )
    ],
  );
}
