import 'dart:async';

import 'package:geolocator/geolocator.dart';

late StreamSubscription<Position?> positionStream;
Position? currentPosition;
