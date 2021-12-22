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

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  void clearDataPhotosPaging() {
    _photosModel = PhotosModel();
    _hasMore = true;
    notifyListeners();
  }

  PhotosModel? _photosModel;
  PhotosModel? get photosModel => _photosModel;

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
        if (_photosModel != null) {
          _photosModel!.photos!.addAll(data.photos!);
        } else {
          _photosModel = data;
        }
        _isLoading = false;
        _pageIndex++;
        notifyListeners();
        setStatus(Status.hasData);
      }
    } catch (e) {
      _message = e.toString();
      _status = Status.failed;
      _hasMore = false;
      _photosModel!.photos = List<Photos>.empty();

      setStatus(Status.failed);
    }
  }
}
