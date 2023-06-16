import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemap_search/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:search_map_place_updated/search_map_place_updated.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TextEditingController _controller = TextEditingController();
  MapType mapType = MapType.normal;
  late GoogleMapController _mapController;
   LatLng? currentLocation;
  LatLng? pickedLocation;
  bool addressConfimed = false;
  String? formatedAdd;
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(9.1450, 40.4897),
    zoom: 7,
  );
  Set<Marker> _markers = {
    Marker(
        icon: BitmapDescriptor.defaultMarker,
        markerId: MarkerId('m1'),
        position: LatLng(9.1450, 40.4897))
  };

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    LatLng latLngC = currentLocation!;
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLngC.latitude},${latLngC.longitude}&key=${YOUR GOOGLE MAP API KEY}';

    http.get(Uri.parse(url)).then((value) {
      print('value:...$value');
      final formatedAdd =
          json.decode(value.body)['results'][0]['formatted_address'];
      print('formated address:.....$formatedAdd');
      _mapController
          .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: latLngC,
        zoom: 50,
      )));
      _markers.clear();
      setState(() {
        cameraPosition = CameraPosition(
          target: latLngC,
          zoom: 50,
        );
        _markers.add(Marker(
          infoWindow: InfoWindow(title: '${formatedAdd}'),
          icon: BitmapDescriptor.defaultMarker,
          markerId: MarkerId('m1'),
          position: latLngC,
        ));
      });
    });
  }

  getAddress(double lat, double long) {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=${YOUR GOOGLE MAP API KEY}';

    http.get(Uri.parse(url)).then((value) {
      print('value:...$value');
      formatedAdd = json.decode(value.body)['results'][0]['formatted_address'];
      print('formated address:.....$formatedAdd');
      LatLng latLngC = LatLng(lat, long);
      _mapController
          .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: latLngC,
        zoom: 50,
      )));
      _markers.clear();
      setState(() {
        cameraPosition = CameraPosition(
          target: latLngC,
          zoom: 50,
        );
        _markers.add(Marker(
          infoWindow: InfoWindow(title: '${formatedAdd}'),
          icon: BitmapDescriptor.defaultMarker,
          markerId: MarkerId('m1'),
          position: latLngC,
        ));
        pickedLocation = latLngC;
      });
    });
  }

  void changeMapTypenormal() {
    setState(() {
      mapType = MapType.normal;
    });
  }

  void changeMapTypeSat() {
    setState(() {
      mapType = MapType.satellite;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Set the status bar color
      statusBarIconBrightness:
          Brightness.light, // Set the status bar text color
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    super.initState();
  }

  void showalert(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Tap on Map or Search Place',
            textAlign: TextAlign.justify,
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  void showalertConfirmation(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Your Selected Location',
            textAlign: TextAlign.justify,
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  addressConfimed = true;
                });
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    print('DID CHANGE DEPENDANCY....................');
    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).then((position) {
      print('POSITION........:${position}');
      print('POSITION........:${position.latitude}');
      LatLng latLngC = LatLng(position.latitude, position.longitude);
      currentLocation = latLngC;
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _mapController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: SearchMapPlaceWidget(
        hasClearButton: true,
        bgColor: Colors.white,
        textColor: Colors.black45,
        iconColor: Colors.black45,
        apiKey: '${YOUR GOOGLE MAP API KEY}',
        onSelected: (place) {
          print('place onselected:.....$place');
          LatLng latLngC = LatLng(23.00, 34.56);
          dynamic formatedAdd;
          final plc = place;
          plc.geolocation.then(
            (value) {
              print('plc:.......${value!.coordinates}');
              latLngC = value.coordinates;
            },
          ).then(
            (value) {
              final url =
                  'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLngC.latitude},${latLngC.longitude}&key=${YOUR GOOGLE MAP API KEY}';
              http.get(Uri.parse(url)).then(
                (value) {
                  print('value:...$value');
                  formatedAdd = json.decode(value.body)['results'][0]
                      ['formatted_address'];
                  print('formated address:.....$formatedAdd');
                },
              );
            },
          ).then((value) {
            _mapController
                .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
              target: latLngC,
              zoom: 50,
            )));
            _markers.clear();
            setState(() {
              cameraPosition = CameraPosition(
                target: latLngC,
                zoom: 50,
              );
              _markers.add(Marker(
                infoWindow: InfoWindow(title: '${formatedAdd}'),
                icon: BitmapDescriptor.defaultMarker,
                markerId: MarkerId('m1'),
                position: latLngC,
              ));
              pickedLocation = latLngC;
              print('search result:.....${pickedLocation}');
            });
          });
        },
      ),
      appBar: AppBar(
        // toolbarHeight: 100,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
            margin: EdgeInsets.only(left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                    onTap: changeMapTypeSat,
                    child: Container(
                        color: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(
                          'Satellite View',
                          style: TextStyle(color: Colors.white),
                        ))),
                InkWell(
                    onTap: changeMapTypenormal,
                    child: Container(
                        color: Colors.blue,
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(
                          'Normal View',
                          style: TextStyle(color: Colors.white),
                        ))),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.yellow[800],
        title: Text('Search and Mark Location '),
        actions: [
          InkWell(
            onTap: () {
              if (pickedLocation != null) {
                Navigator.pop(context);

                // showalertConfirmation('${formatedAdd}');
                // if (addressConfimed) {
                //   print('INSIDE pop if,,,,,,,,,,,,,,,,,,,');
                // }
              } else {
                showalert(
                    'Please tap on your desired location on the map screen OR search a place and the required location will be picked');
              }
            },
            child: Container(
                color: Colors.white,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.symmetric(horizontal: 10),
                height: 4,
                child: Icon(Icons.check, color: Colors.black)),
          ),
        ],
      ),
      body: GoogleMap(
        mapType: mapType,
        onTap: (argument) {
          getAddress(argument.latitude, argument.longitude);
        },
        onMapCreated: _onMapCreated,
        initialCameraPosition: cameraPosition,
        markers: _markers,
      ),
    );
  }
}
