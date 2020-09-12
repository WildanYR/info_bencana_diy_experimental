import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapProvider with ChangeNotifier {
  Map<String, Marker> _marker = {};
  Map<String, Circle> _circle = {};

  getMarker() => _marker;
  getCircle() => _circle;

  void updateGempa(Map<String, Marker> marker, Map<String, Circle> circle) {
    _marker = marker;
    _circle = circle;
    notifyListeners();
  }
}
