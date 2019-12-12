import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preschool/setup/signin.dart';
import 'package:preschool/util/data.dart';

class appbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: <Color>[
              Colors.blue[200],
              Colors.blueAccent,
            ])),
            child: Container(
              child: Column(
                children: <Widget>[
                  new Center(
                    child: CircleAvatar(
                      backgroundImage: ExactAssetImage(
                          "assets/cm${random.nextInt(10)}.jpeg"),
                      minRadius: 20,
                      maxRadius: 50,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: new Text("Yến Nhi", textScaleFactor: 1.3),
                  )
                ],
              ),
            ),
          ),
          CustomListTile(Icons.wallpaper, 'Album ảnh', () => {}),
          CustomListTile(Icons.receipt, 'Đơn xin phép', () => {}),
          CustomListTile(Icons.child_care, 'Học sinh', () => {}),
          CustomListTile(Icons.event_note, 'Thời khóa biểu', () => {}),
          CustomListTile(Icons.fastfood, 'Thực đơn', () => {}),
          CustomListTile(Icons.person, 'Trang cá nhân', () => {}),
          CustomListTile(Icons.event_available, 'Sự kiện', () => {}),
          CustomListTile(Icons.power_settings_new, 'Đăng xuất', () => {})
        ],
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  IconData icon;
  String text;
  Function onTap;

  CustomListTile(this.icon, this.text, this.onTap);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white))),
        child: InkWell(
          splashColor: Colors.blueAccent,
          onTap: onTap,
          child: Container(
            //color: Colors.blue[200],
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                      child: Icon(
                        icon,
                        color: Colors.blue[300],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                      child: Text(
                        text,
                        style: TextStyle(fontSize: 15.0, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_right,
                  color: Colors.blue[200],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
