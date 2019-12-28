import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preschool/drawers/albums.dart';
import 'package:preschool/drawers/changeclass.dart';
import 'package:preschool/drawers/childrens.dart';
import 'package:preschool/drawers/events.dart';
import 'package:preschool/drawers/leaveforms.dart';
import 'package:preschool/drawers/menu.dart';
import 'package:preschool/drawers/profile.dart';
import 'package:preschool/drawers/timetables.dart';
import 'package:preschool/models/user.dart';
import 'package:preschool/screens/chats.dart';
import 'package:preschool/screens/class.dart';
import 'package:preschool/screens/friends.dart';
import 'package:preschool/screens/home.dart';
import 'package:preschool/screens/notifications.dart';
import 'package:preschool/setup/signin.dart';
import 'package:preschool/widgets/icon_badge.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with AutomaticKeepAliveClientMixin<MainScreen> {
  PageController _pageController;
  int _page = 2;
  FirebaseUser user;
  String _title, _idclass;
  User _user;
  static int _count = 0;
  bool _load = false;
  bool _view = false;

  void initState() {
    getInfo();
    _pageController = PageController(initialPage: 2);
    _title = 'Bảng tin';
    super.initState();
  }

  getInfo() async {
    user = await FirebaseAuth.instance.currentUser();
    await Firestore.instance
        .collection('Users')
        .document(user.uid)
        .get()
        .then((DocumentSnapshot ds) {
      _user = User.fromDocument(ds);
      _idclass = ds.data['idClass'];
      if (ds.data['role'] == 'teacher') _view = true;
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
    if (!mounted) return;
    setState(() {
      _load = true;
    });
  }

  get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _load == false ? buildWaitingScreen() : runMain();
  }

  Scaffold buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  _signOut() async {
    try {
      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      await _firebaseAuth.signOut().whenComplete(() {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SigninPage()));
      });
    } catch (e) {
      print(e);
    }
  }

  Widget runMain() {
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
                        backgroundImage: NetworkImage(_user.profileimage),
                        minRadius: 20,
                        maxRadius: 50,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: new Text(_user.username, textScaleFactor: 1.3),
                    )
                  ],
                ),
              ),
            ),
            CustomListTile(
                Icons.wallpaper,
                'Album ảnh',
                () => {
                      Navigator.pop(context),
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Albums()))
                    }),
            CustomListTile(
                Icons.receipt,
                'Đơn xin phép',
                () => {
                      Navigator.pop(context),
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LeaveForms()))
                    }),
            Visibility(
              child: CustomListTile(
                  Icons.change_history,
                  'Học sinh',
                  () => {
                        Navigator.pop(context),
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Childrens()))
                      }),
              visible: _view,
            ),
            CustomListTile(
                Icons.event_note,
                'Thời khóa biểu',
                () => {
                      Navigator.pop(context),
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => TimeTables()))
                    }),
            CustomListTile(
                Icons.fastfood,
                'Thực đơn',
                () => {
                      Navigator.pop(context),
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Menu()))
                    }),
            CustomListTile(
                Icons.person,
                'Trang cá nhân',
                () => {
                      Navigator.pop(context),
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Profile()))
                    }),
            CustomListTile(
                Icons.event_available,
                'Sự kiện',
                () => {
                      Navigator.pop(context),
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Event()))
                    }),
            Visibility(
              child: CustomListTile(
                  Icons.change_history,
                  'Đổi lớp',
                  () => {
                        Navigator.pop(context),
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChangeClass()))
                      }),
              visible: !_view,
            ),
            CustomListTile(
                Icons.power_settings_new, 'Đăng xuất', () => _signOut())
          ],
        ),
      ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: <Widget>[
          // Chats(),
          Friends(),
          Home(),
          Notifications(),
          Class(),
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
            // BottomNavigationBarItem(
            //   icon: Icon(
            //     Icons.message,
            //   ),
            //   title: Container(height: 0.0),
            // ),
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
      _title = 'Tin nhắn';
    }
    if (page == 1) {
      _title = 'Phụ huynh';
    }
    if (page == 2) {
      _title = 'Bảng tin';
    }
    if (page == 3) {
      _title = 'Thông báo';
    }
    if (page == 4) {
      _title = 'Thông tin lớp';
    }
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
