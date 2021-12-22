import 'package:awesome_app/awesome_app.dart';
import 'package:flutter/material.dart';

enum Status { initial, loading, hasData, failed, noData }

class PhotosProvider extends ChangeNotifier {
  final ApiService apiService;

  PhotosProvider({required this.apiService}) {
    fetchListPhotos(5, 1);
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

  PhotosModel? _photosModel;
  PhotosModel? get photosModel => _photosModel;

  void fetchListPhotos(int limit, int offset) async {
    setStatus(Status.loading);
    try {
      PhotosModel? data = await apiService.getListPhotos(limit, offset);
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
