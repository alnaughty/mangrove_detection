import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mangrove_classification/model/firebase_location_data.dart';
import 'package:mangrove_classification/view_model/firebase_location_vm.dart';

class FirebaseLocationService {
  final FirebaseLocationVm _infoVm = FirebaseLocationVm.instance;
  FirebaseLocationService._singleton();
  static final FirebaseLocationService _instance =
      FirebaseLocationService._singleton();
  static FirebaseLocationService get instance => _instance;
  late StreamSubscription subscription;
  CollectionReference<FirebaseLocationData> sportReference = FirebaseFirestore
      .instance
      .collection('location_data')
      .withConverter<FirebaseLocationData>(
        fromFirestore: (snapshot, _) =>
            FirebaseLocationData.fromJson(snapshot.data()!),
        toFirestore: (sport, _) => sport.toJSON(),
      );
  Stream<QuerySnapshot<FirebaseLocationData>> subscriptionlisten() =>
      sportReference.snapshots();

  StreamSubscription subscribe() =>
      subscriptionlisten().listen((QuerySnapshot<FirebaseLocationData>? event) {
        List<FirebaseLocationData> data = event!.docs
            .map(
              (e) => FirebaseLocationData(
                firebaseId: e.id,
                name: e.get('name'),
                location: LatLng(
                  double.parse(e.get('latitude').toString()),
                  double.parse(
                    e.get('longitude').toString(),
                  ),
                ),
                percentage: double.parse(e.get('percentage').toString()),
              ),
            )
            .toList();
        _infoVm.populate(data);
      });
}
