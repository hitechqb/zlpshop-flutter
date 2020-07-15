import 'package:flutter/material.dart';
import 'package:shop/screens/home.dart';


class Dashboard extends StatefulWidget {
  final String title;
  final String version;
  Dashboard({this.title, this.version});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        elevation: 0,
        // backgroundColor: Colors.transparent,
        leading: Center(
           child: Text(widget.version),
        ),
        title: Text(widget.title, style: Theme.of(context).textTheme.title,),
        actions: <Widget>[
          Container(
             margin: const EdgeInsets.only(right: 20.0),
            child: Icon(Icons.crop_free),
          )
        ],
      ),
      body: SafeArea(
        child: Home(widget.title),
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30.0,
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
              title: Text("Home"),
              icon: Icon(Icons.remove_from_queue)
          ),
          BottomNavigationBarItem(
            title: Text("Tạo đơn hàng"),
            icon: Icon(Icons.create)
          ),
          BottomNavigationBarItem(
              title: Text("Lịch sử"),
              icon: Icon(Icons.history)
          ),
        ],
      ),
    );
  }
}


