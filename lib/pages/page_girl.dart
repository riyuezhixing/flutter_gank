/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2018/5/22 下午1:16
 */

import 'dart:async';
import 'package:flutter_gank/App.dart';
import 'package:flutter_gank/constant/colors.dart';
import 'package:flutter_gank/utils/utils_db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gank/bean/info_gank.dart';
import 'package:flutter_gank/constant/strings.dart';
import 'package:flutter_gank/utils/utils_http.dart';
import 'package:flutter_gank/utils/utils_indicator.dart';
import 'package:flutter_gank/widget/cached_pic.dart';
import 'package:flutter_gank/widget/item_gank.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../widget/CircleClipper.dart';
import 'package:flutter/scheduler.dart';

class GirlPage extends StatefulWidget {
  final bool isCard;

  GirlPage({this.isCard});

  @override
  _GirlPageState createState() => new _GirlPageState();
}

class _GirlPageState extends State<GirlPage>
    with IndicatorFactory, HttpUtils, DbUtils,AutomaticKeepAliveClientMixin {
  List<GirlInfo> _dataList = [];

  RefreshController _refreshController;

  ScrollController _scrollController;

  int _pageIndex = 1;

  ValueNotifier<double> offsetLis = new ValueNotifier(0.0);

  //这个算法用来捕捉数据应该要终止插入到数据库的位置
  int _catchEndPos(List<GirlInfo> newData) {
    if (_dataList.isEmpty) {
      return newData.length;
    } else {
      for (int i = 0; i < newData.length; i++) {
        if (newData[i].id == _dataList[0].id) {
          return i;
        } else {
          int j = i + 1;
          //是否存在
          while (j < _dataList.length && _dataList[j].desc == newData[j].desc) {
            if (_dataList[j].id != newData[i].id) {
              j++;
            } else {
              return i;
            }
          }
        }
      }
    }
    return 0;
  }

  void _refreshNewData() {
    getGirlfromNet(URL_GANK_FETCH + "福利" + "/100/1")
        .then((List<GirlInfo> data) {
      for (int i = _catchEndPos(data) - 1; i >= 0; i--) {
        _dataList.insert(0, data[i]);
        insert("Girl", data[i].toMap()).then((val) {}).catchError((error) {});
      }
      if (_dataList.length > 0)
        _pageIndex = (_dataList.length ~/ 20).toInt() + 1;
      _refreshController.refreshCompleted();
      setState(() {});
      return false;
    }).catchError((error) {
      _refreshController.refreshFailed();
      return false;
    });
  }

  void _fetchMoreData() async {
    getGirlfromNet(URL_GANK_FETCH + "福利" + "/20/$_pageIndex")
        .then((List<GirlInfo> data) {
      if (data.isEmpty) {
        //空数据
        _refreshController.loadNoData();
      } else {
        for (GirlInfo item in data) {
          _dataList.add(item);
          insert("Girl", item.toMap()).then((val) {}).then((val) {});
        }

        _pageIndex++;

        _refreshController.loadComplete();
        setState(() {});
      }
      return false;
    }).catchError((error) {
      return false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _refreshController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    _refreshController = new RefreshController();

    _scrollController = new ScrollController();
    getList("Girl").then((List<dynamic> list) {
      if (list.isEmpty) {
        SharedPreferences.getInstance().then((SharedPreferences preferences) {
          if (preferences.getBool("autoRefresh") ?? false) {
            _refreshController.requestRefresh();
          }
        });
      } else {
        for (Map map in list) {
          _dataList.add(new GirlInfo.fromMap(map));
        }
        int aa = list.length ~/ 20;
        _pageIndex = aa + 1;
      }
    });
    super.initState();
  }

  void _onRefresh() {
    _refreshNewData();
  }

  void _onLoad() {
    _fetchMoreData();
  }

  void _onClickLike(int index) {
    _dataList[index].like = !_dataList[index].like;
    setState(() {});
    update("Girl", _dataList[index].toMap(), "id = ? ", [_dataList[index].id]);
  }

  Widget _buildList() {
    if (widget.isCard) {
      return new ListView.builder(
          controller: _scrollController,
          itemCount: _dataList.length,
          itemBuilder: (context, index) => new GirlCardItem(
                who: _dataList[index].who,
                time: _dataList[index].desc,
                url: _dataList[index].url,
                isLike: _dataList[index].like,
                onChangeVal: () {
                  _onClickLike(index);
                },
              ));
    }
    return new GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,crossAxisSpacing: 5.0,mainAxisSpacing: 5.0),
      itemCount: _dataList.length,
      itemBuilder: (context, index) => new CachedPic(
            url: _dataList[index].url,
          ),
    );
  }

  @override
  void didUpdateWidget(GirlPage oldWidget) {
    // TODO: implement didUpdateWidget

    super.didUpdateWidget(oldWidget);
    getList("Girl").then((List<dynamic> list) {
      _dataList.clear();
      for (Map map in list) {
        _dataList.add(new GirlInfo.fromMap(map));
      }
      int aa = list.length ~/ 20;
      _pageIndex = aa + 1;
      setState(() {});
    });
    if (widget.isCard != oldWidget.isCard) {
      SchedulerBinding.instance.addPostFrameCallback((val) {
        _scrollController.animateTo(0.0,
            duration: const Duration(milliseconds: 200), curve: Curves.linear);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new SmartRefresher(
      controller: _refreshController,
      child: _buildList(),
      onLoading: _onLoad,
      header: WaterDropMaterialHeader(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      footer: buildDefaultFooter(context, () {
        _refreshController.requestLoading();
      }),
      onRefresh: _onRefresh,
      enablePullUp: true,
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
