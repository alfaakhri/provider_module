import 'package:flutter/material.dart';
import 'package:network_module/network/models/photos_model.dart';
import 'package:repository_module/repository/repository.dart';

enum Status { initial, loading, hasData, failed, noData }

class PhotosProvider extends ChangeNotifier {
  final Repository repository = Repository();

  Status _status = Status.initial;
  Status get status => _status;
  void setStatus(Status status) {
    _status = status;
    notifyListeners();
  }

  bool _isGrid = false;
  bool get isGrid => _isGrid;
  void setIsGrid() {
    if (_isGrid) {
      _isGrid = false;
    } else {
      _isGrid = true;
    }
    notifyListeners();
  }

  String _message = '';
  String get message => _message;

  int _pageIndex = 0;
  int get pageIndex => _pageIndex;
  void setPageIndex(int pageIndex) {
    _pageIndex = pageIndex;
    notifyListeners();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  void clearDataPhotosPaging() {
    _listPhotos = [];
    _hasMore = true;
    _status = Status.loading;
    notifyListeners();
  }

  List<Photos>? _listPhotos = [];
  List<Photos>? get listPhotos => _listPhotos;

  void fetchListPhotos({required int limit, required int offset}) async {
    _isLoading = true;
    notifyListeners();
    try {
      PhotosModel? data = await repository.getListPhotos(limit, offset);
      if (data!.photos!.isEmpty) {
        _isLoading = false;
        _hasMore = false;
        notifyListeners();
      } else {
        if (_listPhotos!.isNotEmpty) {
          //TO-DO set max < 30 for control limit access
          if (_listPhotos!.length < 30) {
            _listPhotos!.addAll(data.photos!);
          } else {
            _hasMore = false;
          }
        } else {
          _listPhotos = data.photos;
          _status = Status.hasData;
          notifyListeners();
        }
        _isLoading = false;
        _pageIndex++;
        notifyListeners();
      }
    } catch (e) {
      _message = e.toString();
      _status = Status.failed;
      _hasMore = false;
      _listPhotos = List<Photos>.empty();

      setStatus(Status.failed);
    }
  }
}
