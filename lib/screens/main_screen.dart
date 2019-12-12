import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preschool/screens/chats.dart';
import 'package:preschool/screens/friends.dart';
import 'package:preschool/screens/home.dart';
import 'package:preschool/screens/notifications.dart';
import 'package:preschool/screens/profile.dart';
import 'package:preschool/setup/root.dart';
import 'package:preschool/util/data.dart';
import 'package:preschool/widgets/icon_badge.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController _pageController;
  int _page = 2;
  FirebaseUser user;
  String _title, _idclass;
  int _count = 0;
  void initState() {
    getNumberPost();
    _pageController = PageController(initialPage: 2);
    _title = 'Feeds';
    super.initState();
  }

  @override
  getNumberPost() async {
    user = await FirebaseAuth.instance.currentUser();
    await Firestore.instance
        .collection('Users')
        .document(user.uid)
        .get()
        .then((DocumentSnapshot ds) {
      _idclass = ds.data['idClass'];
    });
    //tim so luong post
    await Firestore.instance
        .collection('Class')
        .document(_idclass)
        .collection('Posts')
        .getDocuments()
        .then((ds) {
      _count = ds.documents.length;
    });
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      await _firebaseAuth.signOut().whenComplete(() {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RootPage(), fullscreenDialog: true));
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(_title),
        automaticallyImplyLeading: false,
        centerTitle: true,
        //  elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
      ),
      endDrawer: Drawer(
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
            CustomListTile(
                Icons.power_settings_new, 'Đăng xuất', () => _signOut(context))
          ],
        ),
      ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: <Widget>[
          Chats(),
          Friends(),
          Home(),
          Notifications(),
          Profile(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
          canvasColor: Theme.of(context).primaryColor,
          // sets the active color of the `BottomNavigationBar` if `Brightness` is light
          primaryColor: Theme.of(context).accentColor,
          textTheme: Theme.of(context).textTheme.copyWith(
                caption: TextStyle(color: Colors.grey[500]),
              ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.message,
              ),
              title: Container(height: 0.0),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.group,
              ),
              title: Container(height: 0.0),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              title: Container(height: 0.0),
            ),
            BottomNavigationBarItem(
              icon: IconBadge(
                count: _count,
                icon: Icons.notifications,
              ),
              title: Container(height: 0.0),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              title: Container(height: 0.0),
            ),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ),
      ),
    );
  }

  void navigationTapped(int page) {
    if (page == 0) {
      _title = 'Chats';
    }
    if (page == 1) {
      _title = 'Friends';
    }
    if (page == 2) {
      _title = 'Feeds';
    }
    if (page == 3) {
      _title = 'Notifications';
    }
    if (page == 4) {
      _title = 'Profile';
    }
    print('mmmmmmmmmmmmmmmmmmmmmmmmmmm' + user.toString());
    _pageController.jumpToPage(page);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
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
