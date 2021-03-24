import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gisproj/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_downloader/image_downloader.dart';

class Upload_Data extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("上傳你的文章 ",
                  style: TextStyle(
                      color: kTextLightColor,
                      fontWeight: FontWeight.w200,
                      fontSize: 30,
                      fontFamily: 'Roboto',
                      fontStyle: FontStyle.italic)),
              SizedBox(
                height: 40,
              ),
              RegisterPet(),
            ]),
      )),
    );
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

class RegisterPet extends StatefulWidget {
  RegisterPet({Key key}) : super(key: key);

  @override
  _RegisterPetState createState() => _RegisterPetState();
}

class _RegisterPetState extends State<RegisterPet> {
  final _formKey = GlobalKey<FormState>();
  final listOfPets = ["動物", "植物", "建物", "地標", "景點", "商店", "餐廳", "其他"];
  String dropdownValue = '動物';
  final nameController = TextEditingController();
  final description = TextEditingController();
  final dbRef = FirebaseDatabase.instance.reference().child("subject");
  File _image;
  String _url;
  var _locationlat;
  var _locationlon;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
            child: Column(children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: _image == null ? null : FileImage(_image),
                    radius: 80,
                  ),
                  GestureDetector(
                      onTap: pickImage, child: Icon(Icons.camera_alt)),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "輸入標的名稱",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value.isEmpty) {
                  return '輸入標的名稱';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: DropdownButtonFormField(
              value: dropdownValue,
              icon: Icon(Icons.arrow_downward),
              decoration: InputDecoration(
                labelText: "選擇標的種類",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              items: listOfPets.map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              validator: (value) {
                if (value.isEmpty) {
                  return '請選擇';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: TextFormField(
              controller: description,
              decoration: InputDecoration(
                labelText: "對該項標的進行描述",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value.isEmpty) {
                  return '請對該項標的進行描述';
                }
                return null;
              },
            ),
          ),
          Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      gradient: LinearGradient(
                          colors: [kPrimaryColor, kSecondaryColor]),
                    ),
                    child: FlatButton(
                      onPressed: () {
                        uploadImage(context);
                      },
                      child: Text(
                        '      送出資料      ',
                        style:
                            TextStyle(fontSize: 20.0, color: kTextLightColor),
                      ),
                    ),
                  )
                ],
              )),
        ])));
  }

  @override
  void dispose() {
    super.dispose();
    description.dispose();
    nameController.dispose();
  }

  void pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  void uploadImage(context) async {
    final position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    final userName = user.displayName;
    final email = user.email;

    _locationlat = position.latitude;
    _locationlon = position.longitude;

    try {
      FirebaseStorage storage =
          FirebaseStorage(storageBucket: 'gs://gised-cc928.appspot.com');
      StorageReference ref = storage.ref().child(_image.path);
      StorageUploadTask storageUploadTask = ref.putFile(_image);
      StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;

      String url = await taskSnapshot.ref.getDownloadURL();
      _url = url;
    } catch (ex) {}
    if (_formKey.currentState.validate()) {
      dbRef.push().set({
        "name": nameController.text,
        "description": description.text,
        "type": dropdownValue,
        "img_path": _url,
        "latitude": _locationlat,
        "longitude": _locationlon,
        "userID": uid,
        "userName": userName,
        "email": email,
      }).then((_) {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Successfully Added')));
        description.clear();
        nameController.clear();
      }).catchError((onError) {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(onError)));
      });
    }
    print(email);
  }

  void loadImage() async {
    var imageId = await ImageDownloader.downloadImage(_url);
    var path = await ImageDownloader.findPath(imageId);
    File image = File(path);
    setState(() {
      _image = image;
    });
  }
}
