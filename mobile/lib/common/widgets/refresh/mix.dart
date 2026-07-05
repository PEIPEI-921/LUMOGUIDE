import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

mixin RefreshableMixin<T> {
  final EasyRefreshController _refreshController = EasyRefreshController(
      controlFinishRefresh: true, controlFinishLoad: true);
  EasyRefreshController get refreshController => _refreshController;

  // 初始页码
  int _initPage = 1;

  // 当前页码
  int _page = 1;
  int get page => _page;

  // 每页数量
  int _limit = 20;
  int get limit => _limit;

  // 是否加载更多
  bool _isLoadMore = true;
  bool get isLoadMore => _isLoadMore;

  final _items = <T>[].obs;
  List<T> get items => _items;
  int get itemCount => _items.length;

  Completer? _completer;

  bool get isToRefresh => _page == _initPage;

  initRefresh({int initPage = 1, int limit = 20, bool isLoadMore = false}) {
    _initPage = initPage;
    _page = initPage;
    _limit = limit;
    _isLoadMore = isLoadMore;
  }

  FutureOr fetchData();

  Future onRefresh() async {
    _completer = Completer();
    _page = _initPage;
    fetchData();
    return _completer!.future;
  }

  Future onLoadMore() async {
    _completer = Completer();
    _page++;
    fetchData();
    return _completer!.future;
  }

  void endLoad(List<T> lists) {
    if (isToRefresh) {
      _items.clear();
    }
    _items.addAll(lists);
    _endCompleter();
    _stopRefresh();
    _reloadFooterState(lists);
  }

  void refreshItems() {
    _items.refresh();
  }

  void _endCompleter() {
    _completer?.complete();
    _completer = null;
  }

  void _stopRefresh() {
    _refreshController.finishRefresh();
    _refreshController.finishLoad();
  }

  void _reloadFooterState(List lists) {
    if (!isLoadMore) {
      return;
    }
    var state = IndicatorResult.success;
    if (lists.length < _limit) {
      state = IndicatorResult.noMore;
    }
    _refreshController.finishLoad(state);
  }
}
