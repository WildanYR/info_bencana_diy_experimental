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
  static final List<LatLng> _lokasi = [
    LatLng(-7.998507, 110.249508), //lokasi user bahaya 1 btl
    LatLng(-7.988116, 110.221247), //lokasi user bahaya 2 kp
    LatLng(-7.804253, 110.365104), //lokasi user jauh
    LatLng(-8.037029, 110.228829), //titik gempa 2 btl
    LatLng(-8.036211, 110.199313), //titik gempa 3 kp
    LatLng(-8.213697, 110.445063), //titik gempa 1 gk
    LatLng(-7.993852, 110.252240), //titik evakuasi 2 btl
    LatLng(-7.971942, 110.226579), //titik evakuasi 3 kp
  ];

  static final List<String> _locLabel = [
    'Lokasi saat ini',
    'Lokasi saat ini',
    'Lokasi saat ini',
    'Titik Gempa',
    'Titik Gempa',
    'Titik Gempa',
    'Titik Evakuasi',
    'Titik Evakuasi'
  ];

  static final List<double> _locIconColor = [
    BitmapDescriptor.hueBlue,
    BitmapDescriptor.hueBlue,
    BitmapDescriptor.hueBlue,
    BitmapDescriptor.hueRed,
    BitmapDescriptor.hueRed,
    BitmapDescriptor.hueRed,
    BitmapDescriptor.hueGreen,
    BitmapDescriptor.hueGreen
  ];

  /*
    stat [
      7.0-17km,
      6.0-20km,
      8.0-23km,
      5.0-15km,
      5.0-19km
    ]
  */

  static final List<double> _radiusTsunami = [
    10000, //radius tsunami 1
    8000, //radius tsunami 2
    10000 //radius tsunami 3
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
            label: 'Tsunami 1',
            child: Icon(Icons.directions_run),
            backgroundColor: Colors.red,
            onTap: () {
              _simulasi(mapProvider, '10010010', '100');
              showBottomSheet(
                  context: context,
                  builder: (context) => MbBottomSheet(
                      magnitude: '7.0',
                      deep: '17 Km',
                      tsunami: true,
                      safe: false));
            }),
        SpeedDialChild(
            label: 'Tsunami 2',
            child: Icon(Icons.directions_run),
            backgroundColor: Colors.red,
            onTap: () {
              _simulasi(mapProvider, '01001001', '010');
              showBottomSheet(
                  context: context,
                  builder: (context) => MbBottomSheet(
                      magnitude: '6.0',
                      deep: '20 Km',
                      tsunami: true,
                      safe: false));
            }),
        SpeedDialChild(
            label: 'Tsunami 3',
            child: Icon(Icons.broken_image),
            backgroundColor: Colors.red,
            onTap: () {
              _simulasi(mapProvider, '00100100', '001');
              showBottomSheet(
                  context: context,
                  builder: (context) => MbBottomSheet(
                      magnitude: '8.0',
                      deep: '23 Km',
                      tsunami: true,
                      safe: true));
            }),
        SpeedDialChild(
            label: 'Gempa 1',
            child: Icon(Icons.broken_image),
            backgroundColor: Colors.yellow,
            onTap: () {
              _simulasi(mapProvider, '10010000', '000');
              showBottomSheet(
                  context: context,
                  builder: (context) => MbBottomSheet(
                      magnitude: '5.0',
                      deep: '15 Km',
                      tsunami: false,
                      safe: true));
            }),
        SpeedDialChild(
            label: 'Gempa 2',
            child: Icon(Icons.broken_image),
            backgroundColor: Colors.yellow,
            onTap: () {
              _simulasi(mapProvider, '00101000', '000');
              showBottomSheet(
                  context: context,
                  builder: (context) => MbBottomSheet(
                      magnitude: '5.0',
                      deep: '19 Km',
                      tsunami: false,
                      safe: true));
            })
      ],
    );
  }

  _simulasi(mapProvider, String point, String rad) {
    Map<String, Marker> markers = {};
    Map<String, Circle> circles = {};
    int index = 0;
    for (int i = 0; i < point.length; i++) {
      if (point[i] == '1') {
        markers[index.toString()] = Marker(
            markerId: MarkerId('marker-' + index.toString()),
            position: _lokasi[i],
            icon: BitmapDescriptor.defaultMarkerWithHue(_locIconColor[i]),
            infoWindow: InfoWindow(title: _locLabel[i]));
        index++;
      }
    }
    index = 0;
    for (int i = 0; i < rad.length; i++) {
      if (rad[i] == '1') {
        circles[index.toString()] = Circle(
          circleId: CircleId('circle-' + index.toString()),
          zIndex: 1000,
          fillColor: Color.fromARGB(127, 244, 67, 54),
          strokeColor: Colors.red,
          strokeWidth: 2,
          center: _lokasi[i + 3],
          radius: _radiusTsunami[i],
        );
        index++;
      }
    }
    mapProvider.updateMarker(markers);
    mapProvider.updateCircle(circles);
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
