import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceInfo {
  String name;
  String img_path;
  String description;
  LatLng locationCoords;
  String type;
  String email;
  String userID;
  String userName;

  PlaceInfo(
      {this.name,
      this.img_path,
      this.description,
      this.locationCoords,
      this.type,
      this.email,
      this.userID,
      this.userName});
}
