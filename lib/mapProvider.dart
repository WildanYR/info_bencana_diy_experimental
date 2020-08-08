import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapProvider with ChangeNotifier {
  Map<String, Marker> _marker = {};
  Map<String, Circle> _circle = {};

  getMarker() => _marker;
  getCircle() => _circle;

  void updateMarker(Map<String, Marker> marker) {
    _marker = marker;
    notifyListeners();
  }

  void updateCircle(Map<String, Circle> circle) {
    _circle = circle;
    notifyListeners();
  }
}
