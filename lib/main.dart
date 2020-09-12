import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:info_bencana_diy/mapProvider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Info Bencana DIY',
      theme: ThemeData(
        primarySwatch: Colors.green,
        canvasColor: Colors.transparent,
        accentColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChangeNotifierProvider(
        create: (_) => MapProvider(),
        child: MapView(),
      ),
    );
  }
}

class MapView extends StatefulWidget {
  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _petaYogyakarta = CameraPosition(
    target: LatLng(-7.8447214, 110.3926681),
    zoom: 9.5,
  );

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    return new Scaffold(
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _petaYogyakarta,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: mapProvider.getMarker().values.toSet(),
          circles: mapProvider.getCircle().values.toSet(),
        ),
        floatingActionButton: MbFAB());
  }
}

class MbFAB extends StatefulWidget {
  MbFAB({Key key}) : super(key: key);

  @override
  _MbFABState createState() => _MbFABState();
}

class _MbFABState extends State<MbFAB> {
  static final List<Map> _simLoc = [
    {
      'titik_gempa': LatLng(-8.348436, 110.136780),
      'magnitude': '5.0',
      'deep': '19 Km',
      'radius': 20000.0,
      'lokasi_user': LatLng(-7.867454, 110.344263)
    },
    {
      'titik_gempa': LatLng(-7.885028, 110.307106),
      'magnitude': '7.0',
      'deep': '15 Km',
      'radius': 10000.0,
      'lokasi_user': LatLng(-7.891414, 110.450356)
    },
    {
      'titik_gempa': LatLng(-8.349574, 110.224588),
      'magnitude': '6.0',
      'deep': '14 Km',
      'radius': 42000.0,
      'lokasi_user': LatLng(-7.860809, 110.411745)
    },
    {
      'titik_gempa': LatLng(-8.349574, 110.224588),
      'magnitude': '8.0',
      'deep': '19 Km',
      'radius': 41000.0,
      'lokasi_user': LatLng(-7.991854, 110.305473)
    }
  ];

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      children: [
        SpeedDialChild(
            label: 'Simulasi 1',
            child: Icon(Icons.broken_image),
            backgroundColor: Colors.yellow,
            onTap: () {
              _gempa(mapProvider, _simLoc[0]);
              showBottomSheet(
                  context: context,
                  builder: (context) => MbBottomSheet(
                      magnitude: _simLoc[0]['magnitude'],
                      deep: _simLoc[0]['deep'],
                      tsunami: false,
                      safe: true));
            }),
        SpeedDialChild(
            label: 'Simulasi 2',
            child: Icon(Icons.broken_image),
            backgroundColor: Colors.yellow,
            onTap: () {
              _gempa(mapProvider, _simLoc[1]);
              showBottomSheet(
                  context: context,
                  builder: (context) => MbBottomSheet(
                      magnitude: _simLoc[1]['magnitude'],
                      deep: _simLoc[1]['deep'],
                      tsunami: false,
                      safe: true));
            }),
        SpeedDialChild(
            label: 'Simulasi 3',
            child: Icon(Icons.broken_image),
            backgroundColor: Colors.red,
            onTap: () {
              _gempa(mapProvider, _simLoc[2]);
              showBottomSheet(
                  context: context,
                  builder: (context) => MbBottomSheet(
                      magnitude: _simLoc[2]['magnitude'],
                      deep: _simLoc[2]['deep'],
                      tsunami: true,
                      safe: true));
            }),
        SpeedDialChild(
            label: 'Simulasi 4',
            child: Icon(Icons.directions_run),
            backgroundColor: Colors.red,
            onTap: () {
              _gempa(mapProvider, _simLoc[3]);
              showBottomSheet(
                  context: context,
                  builder: (context) => MbBottomSheet(
                      magnitude: _simLoc[3]['magnitude'],
                      deep: _simLoc[3]['deep'],
                      tsunami: true,
                      safe: false));
            }),
      ],
    );
  }

  _gempa(mapProvider, dataGempa) {
    Map<String, Marker> markers = {};
    Map<String, Circle> circles = {};

    markers['titik_gempa'] = Marker(
        markerId: MarkerId('marker_titik_gempa'),
        position: dataGempa['titik_gempa'],
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: 'Titik Gempa'));
    markers['lokasi_user'] = Marker(
        markerId: MarkerId('marker_lokasi_user'),
        position: dataGempa['lokasi_user'],
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: 'Lokasi saat ini'));

    if (dataGempa['radius'] != 0.0) {
      circles['radius_dampak'] = Circle(
          circleId: CircleId('radius_dampak'),
          zIndex: 1000,
          fillColor: Color.fromARGB(127, 244, 67, 54),
          strokeColor: Colors.red,
          strokeWidth: 2,
          center: dataGempa['titik_gempa'],
          radius: dataGempa['radius']);
    }

    mapProvider.updateGempa(markers, circles);
  }
}

class MbBottomSheet extends StatelessWidget {
  MbBottomSheet({Key key, this.magnitude, this.deep, this.tsunami, this.safe})
      : super(key: key);
  final String magnitude;
  final String deep;
  final bool tsunami;
  final bool safe;
  final String date = DateTime.now().day.toString() +
      '/' +
      DateTime.now().month.toString() +
      '/' +
      DateTime.now().year.toString();
  final String time = DateTime.now().hour.toString() +
      ':' +
      DateTime.now().minute.toString() +
      ':' +
      DateTime.now().second.toString();

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 300,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            Center(
              child: Column(
                children: <Widget>[
                  Text(
                    'Telah terjadi',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    'Gempabumi',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.grey[200]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        magnitude,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Magnitudo',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey[600]),
                      )
                    ],
                  ),
                ),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.grey[200]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        deep,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Kedalaman',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey[600]),
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Arahan',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 5),
                  Text(
                    tsunami ? 'berpotensi tsunami' : 'tidak berpotensi tsunami',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Saran',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 5),
                  Text(
                    safe
                        ? 'Hati-hati terhadap gempa susulan yang mungkin terjadi'
                        : 'dimohon untuk mengungsi ke titik pengungsian',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: Column(
                children: <Widget>[
                  Text(
                    'Waktu pemutakhiran',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  Text(
                    date + ' ' + time + 'WIB',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
