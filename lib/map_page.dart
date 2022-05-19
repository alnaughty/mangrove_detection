import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mangrove_classification/global.dart';
import 'package:mangrove_classification/model/firebase_location_data.dart';
import 'package:mangrove_classification/view_model/firebase_location_vm.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final FirebaseLocationVm _vm = FirebaseLocationVm.instance;
  // final _controller = Completer<GoogleMapController>();
  // CameraPosition cameraPosition = CameraPosition(
  //   target: LatLng(currentPosition!.latitude, currentPosition!.longitude),
  //   zoom: 14.4746,
  // );
  // late  _shapeSource;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MAP PAGE"),
      ),
      body: StreamBuilder<List<FirebaseLocationData>>(
          stream: _vm.stream$,
          builder: (_, snapshot) {
            final MapShapeSource _shapeSource = MapShapeSource.asset(
              'assets/calbayog.geojson',
              shapeDataField: "NAME_3",
              dataCount: snapshot.data!.length,
              primaryValueMapper: (index) => snapshot.data![index].name,
              // shapeColorMappers: [
              //   MapColorMapper(
              //     color: Colors.red,
              //   ),
              // ],
            );
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "CITY OF CALBAYOG",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      height: 1,
                    ),
                  ),
                  Text(
                    "Mangrove Map".toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.black38,
                      height: 1,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SfMaps(
                    layers: [
                      MapShapeLayer(
                        // legend: MapLegend.bar(source),
                        tooltipSettings: const MapTooltipSettings(
                            color: Colors.white,
                            strokeColor: Color.fromRGBO(252, 187, 15, 1),
                            strokeWidth: 1.5),
                        markerTooltipBuilder: (context, index) =>
                            Text(snapshot.data![index].name),
                        initialMarkersCount: snapshot.data!.length,
                        showDataLabels: true,
                        source: _shapeSource,
                        zoomPanBehavior: MapZoomPanBehavior(
                          enableDoubleTapZooming: true,
                        ),
                        onWillZoom: (f) {
                          print(f.focalLatLng);
                          return true;
                          // return MapZoomDetails();
                        },
                        dataLabelSettings: MapDataLabelSettings(
                          overflowMode: MapLabelOverflow.hide,
                          textStyle: TextStyle(
                            color: Colors.grey.shade800,
                          ),
                        ),
                        markerBuilder: (_, index) => MapMarker(
                          latitude: snapshot.data![index].location.latitude,
                          longitude: snapshot.data![index].location.longitude,
                          // iconColor: Colors.red,
                          // iconStrokeWidth: 2,
                          // iconStrokeColor: Colors.black,
                          // iconType: MapIconType.circle,
                          child: Image.asset(
                            "assets/mangrove.png",
                            width: 15,
                            height: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    child: Text(
                      "List of recorded mangroves :",
                      style: TextStyle(
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (_, index) => const Divider(),
                      itemBuilder: (_, index) => ListTile(
                        leading: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.red,
                        ),
                        title: Text(snapshot.data![index].name),
                        subtitle: Text(
                            "${snapshot.data![index].location.latitude}, ${snapshot.data![index].location.longitude}"),
                      ),
                      itemCount: snapshot.data!.length,
                    ),
                  ),
                ],
              ),
            );
          }
          // builder: (_, snapshot) {
          //   Set<Marker> _markers = {};
          //   if (snapshot.hasData && !snapshot.hasError) {
          //     for (FirebaseLocationData e in snapshot.data!) {
          //       _markers.add(
          //         Marker(
          //           markerId: MarkerId(e.firebaseId),
          //           infoWindow: InfoWindow(
          //             title: e.name,
          //           ),
          //           position: e.location,
          //         ),
          //       );
          //     }
          //   }
          //   return GoogleMap(
          //     myLocationEnabled: false,
          //     zoomControlsEnabled: false,
          //     myLocationButtonEnabled: false,
          //     mapType: MapType.normal,
          //     //  camera position
          //     initialCameraPosition: cameraPosition,
          //     onMapCreated: (GoogleMapController controller) {
          //       _controller.complete(controller);
          //     },
          //     onCameraMoveStarted: () {},
          //     onCameraMove: (cameraPosition) {
          //       this.cameraPosition = cameraPosition;
          //     },
          //     markers: _markers,
          //   );
          // },
          ),
    );
  }

  // static List<MapModel> _getMapModel() {
  //   return <MapModel>[
  //     for()
  //   ];
  // }
}
