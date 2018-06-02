/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2018/5/21 下午10:19
 */

import 'package:flutter/material.dart';
import 'package:flutter_gank/constant/colors.dart';
import 'package:flutter_gank/constant/strings.dart';
import 'package:flutter_gank/pages/page_gank.dart';
import 'package:flutter_gank/pages/page_girl.dart';
import 'package:flutter_gank/pages/page_home.dart';
import 'package:flutter_gank/pages/page_like.dart';
import 'package:flutter_gank/pages/page_setting.dart';
import 'package:flutter_gank/utils/utils_db.dart';
import 'package:flutter_gank/widget/search_bar.dart';
import 'package:residemenu/residemenu.dart';

class MainActivity extends StatefulWidget {
  @override
  _MainActivityState createState() => new _MainActivityState();
}

class _MainActivityState extends State<MainActivity>
    with TickerProviderStateMixin, DbUtils {
  final List<String> _gankTitles = [
    STRING_GANK_WEB,
    STRING_GANK_ANDROID,
    STRING_GANK_IOS,
    STRING_GANK_TUIJIAN,
    STRING_GANK_EXTRA,
    STRING_GANK_APP,
    STRING_GANK_VIDEO
  ];
  MenuController _menuController;

  TabController _tabController;

  int selectIndex = 0;

  int _gankSelectIndex = 0;

  bool isCard = false;

  bool _isSearching = false;

  List<GlobalKey<GankPageState>> _gankPageKeys = [];

  Widget _buildRight() {
    if (selectIndex == 1) {
      return new InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: new Container(
          alignment: Alignment.center,
          child: _isSearching
              ? new Text('取消')
              : new Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 25.0,
                ),
          margin: new EdgeInsets.all(10.0),
        ),
        onTap: () {
          _isSearching = !_isSearching;
          setState(() {});
        },
      );
    } else if (selectIndex == 2) {
      return new InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          isCard = !isCard;
          setState(() {});
        },
        child: new Container(
          alignment: Alignment.center,
          margin: new EdgeInsets.only(right: 10.0),
          child: new Text(isCard ? "缩略图" : "卡片",style:const TextStyle(inherit: true,color:Colors.white)),
        ),
      );
    }
    return null;
  }

  Widget _buildViewPagerIndicator() {
    return selectIndex == 1
        ? new TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            isScrollable: true,
            labelColor: Colors.white,
            tabs: <Widget>[
              new Tab(text: STRING_GANK_WEB),
              new Tab(text: STRING_GANK_ANDROID),
              new Tab(text: STRING_GANK_IOS),
              new Tab(text: STRING_GANK_TUIJIAN),
              new Tab(text: STRING_GANK_EXTRA),
              new Tab(text: STRING_GANK_APP),
              new Tab(text: STRING_GANK_VIDEO)
            ],
            controller: _tabController,
          )
        : null;
  }

  Widget _buildBody() {
    return new Stack(
      children: <Widget>[
        new Offstage(
          offstage: selectIndex != 0,
          child: new HomePage(),
        ),
        new Offstage(
          offstage: selectIndex != 1,
          child: new Stack(
            children: <Widget>[
              new Offstage(
                  offstage: _gankSelectIndex != 0,
                  child: new GankPage(key: _gankPageKeys[0],title: _gankTitles[0],isSeaching: _isSearching,)),
              new Offstage(
                  offstage: _gankSelectIndex != 1,
                  child: new GankPage(key: _gankPageKeys[1],title: _gankTitles[1],isSeaching: _isSearching,)),
              new Offstage(
                  offstage: _gankSelectIndex != 2,
                  child: new GankPage(key: _gankPageKeys[2],title: _gankTitles[2],isSeaching: _isSearching,)),
              new Offstage(
                  offstage: _gankSelectIndex != 3,
                  child: new GankPage(key: _gankPageKeys[3],title: _gankTitles[3],isSeaching: _isSearching,)),
              new Offstage(
                  offstage: _gankSelectIndex != 4,
                  child: new GankPage(key: _gankPageKeys[4],title: _gankTitles[4],isSeaching: _isSearching,)),
              new Offstage(
                  offstage: _gankSelectIndex != 5,
                  child: new GankPage(key: _gankPageKeys[5],title: _gankTitles[5],isSeaching: _isSearching,)),
              new Offstage(
                  offstage: _gankSelectIndex != 6,
                  child: new GankPage(key: _gankPageKeys[6],title: _gankTitles[6],isSeaching: _isSearching,)),
            ],
          ),
        ),
        new Offstage(
          offstage: selectIndex != 2,
          child: new GirlPage(isCard: isCard),
        ),
        new Offstage(
          offstage: selectIndex != 3,
          child: new LikePage(),
        ),
        new Offstage(
          offstage: selectIndex != 4,
          child: new SettingPage(),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String title, IconData iconName, Function callback) {
    return new InkWell(
      child: new ResideMenuItem(
          title: title,
          titleStyle:
              new TextStyle(inherit: true, color: Colors.white, fontSize: 14.0),
          icon: new Icon(
            iconName,
            color: Colors.white,
          )),
      onTap: callback,
    );
  }

  Widget _buildMiddleMenu() {
    return new MenuScaffold(
        itemExtent: 50.0,
        header: new Container(
          margin: new EdgeInsets.only(bottom: 20.0),
          child: new CircleAvatar(
            backgroundImage: new AssetImage('images/gank.jpg'),
            radius: 40.0,
          ),
        ),
        children: <Widget>[
          _buildMenuItem(STRING_HOME, Icons.apps, () {
            setState(() {
              selectIndex = 0;
            });
            _menuController.closeMenu();
          }),
          _buildMenuItem(STRING_GANK, Icons.explore, () {
            setState(() {
              selectIndex = 1;
            });
            _menuController.closeMenu();
          }),
          _buildMenuItem(STRING_GIRL, Icons.insert_photo, () {
            setState(() {
              selectIndex = 2;
            });
            _menuController.closeMenu();
          }),
          _buildMenuItem(STRING_LIKE, Icons.favorite, () {
            setState(() {
              selectIndex = 3;
            });
            _menuController.closeMenu();
          }),
          _buildMenuItem(STRING_SETTING, Icons.settings, () {
            setState(() {
              selectIndex = 4;
            });
            _menuController.closeMenu();
          }),
        ]);
  }

  void _onSearch(String text){
    for(GlobalKey<GankPageState> key in _gankPageKeys){
      key.currentState.searchGank(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new ResideMenu.scafford(
      enableFade: false,
      controller: _menuController,
      leftScaffold: _buildMiddleMenu(),
      child: new Scaffold(
        appBar: new AppBar(
          title: _isSearching && selectIndex == 1
              ? new SearchBar(onChangeText: _onSearch,)
              : new Text(selectIndex == 0
                  ? STRING_HOME
                  : selectIndex == 1
                      ? STRING_GANK
                      : selectIndex == 2
                          ? STRING_GIRL
                          : selectIndex == 3
                              ? STRING_LIKE
                              : selectIndex == 4
                                  ? STRING_SETTING
                                  : STRING_ABOUTME,style: const TextStyle(inherit: true,color: Colors.white)),
          leading: new InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: const Icon(Icons.menu,color: Colors.white),
            onTap: () {
              _menuController.openMenu(true);
            },
          ),
          bottom: _buildViewPagerIndicator(),
          actions: _buildRight() != null ? [_buildRight()] : null,
        ),
        body: _buildBody(),
      ),
      direction: ScrollDirection.LEFT,
      decoration: new BoxDecoration(
          gradient: const LinearGradient(
              colors: <Color>[DEFAULT_THEMECOLOR, const Color(0xff666666)],
              begin: Alignment.topLeft)),
    ));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    close();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (int i = 0; i < 7; i++) _gankPageKeys.add(new GlobalKey());
    _tabController = new TabController(length: 7, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      _gankSelectIndex = _tabController.index;
      setState(() {});
    });
    _menuController = new MenuController(vsync: this);
  }
}
