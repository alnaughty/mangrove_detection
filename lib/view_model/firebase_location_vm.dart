import 'package:mangrove_classification/model/firebase_location_data.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseLocationVm {
  FirebaseLocationVm._singleton();
  static final FirebaseLocationVm _instance = FirebaseLocationVm._singleton();
  static FirebaseLocationVm get instance => _instance;

  BehaviorSubject<List<FirebaseLocationData>>? _subject = BehaviorSubject();
  Stream<List<FirebaseLocationData>>? get stream$ => _subject!.stream;
  List<FirebaseLocationData>? get current => _subject!.value;
  void populate(List<FirebaseLocationData> data) {
    _subject!.add(data);
  }

  void append(FirebaseLocationData data) {
    current!.add(data);
    _subject!.add(current!);
  }
}
