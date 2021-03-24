import 'dart:async';
import 'dart:ui';
import 'package:gisproj/Upload.dart';
import 'package:gisproj/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'placeInfo_model.dart';

class Mapshow extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Mapshow> {
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(24.985546, 121.5783253);
  LatLng testLat = LatLng(24.985546, 121.5783253);
  LatLng _lastMapPosition = _center;
  List user_data = [];
  MapType _currentMapType = MapType.normal;
  final DatabaseReference fireBaseDB = FirebaseDatabase.instance.reference();
  List<PlaceInfo> placeInfoList = [];
  final Set<Marker> _markers = {};
  final FirebaseAuth auth = FirebaseAuth.instance;

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _getTypeInfo(type) {
    fireBaseDB.child("subject").once().then((DataSnapshot snapshot) {
      snapshot.value.forEach((key, value) {
        if (value["type"] == type) {
          var longitude = value["longitude"];
          var latitude = value["latitude"];
          PlaceInfo thisPlaceInfo = new PlaceInfo();
          thisPlaceInfo.img_path = value['img_path'];
          thisPlaceInfo.description = value['description'];
          thisPlaceInfo.name = value['name'];
          thisPlaceInfo.locationCoords = LatLng(latitude, longitude);
          placeInfoList.add(thisPlaceInfo);
        }
      });
      _onAddMarkerButtonPlaceInfo();
    });
  }

  void _onAddMarkerButtonPlaceInfo() {
    // set up the buttons

    setState(() {
      _markers.clear();
      placeInfoList.forEach((element) {
        _markers.add(
          Marker(
            markerId: MarkerId(element.name),
            draggable: false,
            position: element.locationCoords,
            onTap: () {
              // set up the button

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Card(
                    semanticContainer: true,
                    margin: EdgeInsets.all(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    shadowColor: kSecondaryColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Text(
                            element.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                        Container(
                          child: Image.network(element.img_path),
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: MediaQuery.of(context).size.height * 0.7,
                        ),
                        Container(
                          child: Text(
                            element.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ); //這裏可以在依據資料增加顯示資訊
      });
      placeInfoList.clear();
    });
  }

  Future<void> inputData() async {
    final FirebaseUser user = await auth.currentUser();
    user_data = [user.uid, user.displayName, user.email, user.photoUrl];
    return Future.delayed(Duration(seconds: 0), () => user_data);
  }

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _gSignIn = GoogleSignIn();
    return FutureBuilder(
        future: inputData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return MaterialApp(
            home: Scaffold(
              drawer: Drawer(
                child: ListView(
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      accountName: Text(user_data[1]),
                      accountEmail: Text(user_data[2]),
                      currentAccountPicture: CircleAvatar(
                        backgroundImage: NetworkImage(user_data[3]),
                      ),
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        child: Image.asset('image/1.png'),
                        backgroundColor: Colors.white,
                      ),
                      title: Text('動物'),
                      onTap: () {
                        _getTypeInfo("動物");
                      },
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        child: Image.asset('image/2.png'),
                        backgroundColor: Colors.white,
                      ),
                      title: Text('植物'),
                      onTap: () {
                        _getTypeInfo("植物");
                      },
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        child: Image.asset('image/4.png'),
                        backgroundColor: Colors.white,
                      ),
                      title: Text('建物'),
                      onTap: () {
                        _getTypeInfo("建物");
                      },
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        child: Image.asset('image/3.png'),
                        backgroundColor: Colors.white,
                      ),
                      title: Text('地標'),
                      onTap: () {
                        _getTypeInfo("地標");
                      },
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        child: Image.asset('image/5.png'),
                        backgroundColor: Colors.white,
                      ),
                      title: Text('景點'),
                      onTap: () {
                        _getTypeInfo("景點");
                      },
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        child: Image.asset('image/6.png'),
                        backgroundColor: Colors.white,
                      ),
                      title: Text('餐廳'),
                      onTap: () {
                        _getTypeInfo("餐廳");
                      },
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        child: Image.asset('image/8.png'),
                        backgroundColor: Colors.white,
                      ),
                      title: Text('商店'),
                      onTap: () {
                        _getTypeInfo("商店");
                      },
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        child: Image.asset('image/7.png'),
                        backgroundColor: Colors.white,
                      ),
                      title: Text('其他'),
                      onTap: () {
                        _getTypeInfo("其他");
                      },
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.logout),
                        backgroundColor: Colors.white,
                      ),
                      title: Text('登出'),
                      onTap: () {
                        _gSignIn.signOut();
                        print('Signed out');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              appBar: buildAppBar(),
              body: Stack(
                children: <Widget>[
                  GoogleMap(
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: testLat,
                      zoom: 10.0,
                    ),
                    mapType: _currentMapType,
                    markers: _markers,
                    onCameraMove: _onCameraMove,
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        children: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyHomePage(),
                                  ));
                            },
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            child: const Icon(Icons.camera_alt_rounded,
                                size: 36.0),
                          ),
                          SizedBox(height: 5.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  AppBar buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: kPrimaryColor,
      title: Text('PhotoShare'),
      actions: <Widget>[],
    );
  }
}
