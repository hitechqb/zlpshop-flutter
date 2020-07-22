import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shop/repo/payment.dart';
import 'package:shop/utils/theme_data.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  final String title;

  Home(this.title);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const EventChannel eventChannel = EventChannel('flutter.native/eventPayOrder');
  static const MethodChannel platform = const MethodChannel('flutter.native/channelPayOrder');
  final myController = TextEditingController(text: "10000");
  final textStyle = TextStyle(color: Colors.black54);
  final valueStyle = TextStyle(color: AppColor.accentColor, fontSize: 18.0, fontWeight: FontWeight.w400);
  String zpTransToken = "";
  String payResult = "";
  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  void _onEvent(Object event) {
    print("_onEvent: '$event'.");
    setState(() {
      if (event.hashCode == 1) {
        payResult = "Thanh toán thành công";
      } else {
        payResult = "Giao dịch thất bại";
      }
    });
  }

  void _onError(Object error) {
    print("_onError: '$error'.");
    setState(() {
      payResult = "Giao dịch thất bại";
    });
  }


  // Button Create Order
    Widget _btnCreateOrder(String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: GestureDetector(
          onTap: () async {
            int amount = int.parse(value);
            if (amount > 1000000) {
              zpTransToken = "Invalid Amount";
            }
            showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(child: CircularProgressIndicator(),);
                  });
            var result = await createOrder(amount);
            if (result != null) {
              Navigator.pop(context);
              zpTransToken = result.zptranstoken;
              setState(() {
                zpTransToken = result.zptranstoken;
              });
            }
          },
          child: Container(
              height: 50.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text("Create Order",
                  style: TextStyle(color: Colors.white, fontSize: 20.0))),
        ),
      );

  /// Build Button Pay
  Widget _btnPay(String zpToken) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: GestureDetector(
          onTap: () async {
            String response = "";
            try {
              final String result = await platform.invokeMethod('payOrder', {"zptoken": zpToken});
              response = result;
              print("payOrder Result: '$result'.");

            } on PlatformException catch (e) {
              print("Failed to Invoke: '${e.message}'.");
              response = "Thanh toán thất bại";
            }
            print(response);
            setState(() {
              payResult = response;
            });
          },
          child: Container(
              height: 50.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text("Pay",
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
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'Amount',
            icon: Icon(Icons.attach_money),
          ),
          controller: myController,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        ),
      _btnCreateOrder(myController.text),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Text("zptranstoken", style: textStyle,),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Text(zpTransToken, style: valueStyle,),
      ),
      _btnPay(zpTransToken),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Text("Trạng thái đơn hàng", style: textStyle,),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Text(payResult, style: valueStyle,),
      ),
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
                "2554",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
      // _btnQuickEdit,
    ],
  ),
);

