import 'package:flutter/material.dart';
import 'package:network_module/network/models/photos_model.dart';
import 'package:repository_module/repository/repository.dart';

enum Status { initial, loading, hasData, failed, noData }

class PhotosProvider extends ChangeNotifier {
  final Repository repository;

  PhotosProvider({required this.repository}) {
    fetchListPhotos(limit: 5, offset: 1);
  }

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

  PhotosModel? _photosModel;
  PhotosModel? get photosModel => _photosModel;

  void fetchListPhotos({required int limit, required int offset}) async {
    setStatus(Status.loading);
    try {
      PhotosModel? data = await repository.getListPhotos(limit, offset);
      if (_photosModel != null) {
        _photosModel!.photos!.addAll(data!.photos!);
      } else {
        _photosModel = data;
      }
      setStatus(Status.hasData);
    } catch (e) {
      _message = e.toString();
      setStatus(Status.failed);
    }
  }
}
