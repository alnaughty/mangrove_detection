import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mangrove_classification/global.dart';
import 'package:mangrove_classification/model/firebase_location_data.dart';
import 'package:mangrove_classification/view_model/firebase_location_vm.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final FirebaseLocationVm _vm = FirebaseLocationVm.instance;
  final _controller = Completer<GoogleMapController>();
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(currentPosition!.latitude, currentPosition!.longitude),
    zoom: 14.4746,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MAP PAGE"),
      ),
      body: StreamBuilder<List<FirebaseLocationData>>(
        stream: _vm.stream$,
        builder: (_, snapshot) {
          Set<Marker> _markers = {};
          if (snapshot.hasData && !snapshot.hasError) {
            for (FirebaseLocationData e in snapshot.data!) {
              _markers.add(
                Marker(
                  markerId: MarkerId(e.firebaseId),
                  infoWindow: InfoWindow(
                    title: e.name,
                  ),
                  position: e.location,
                ),
              );
            }
          }
          return GoogleMap(
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            //  camera position
            initialCameraPosition: cameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onCameraMoveStarted: () {},
            onCameraMove: (cameraPosition) {
              this.cameraPosition = cameraPosition;
            },
            markers: _markers,
          );
        },
      ),
    );
  }
}
