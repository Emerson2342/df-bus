class BusStop {
  final String codDftrans;
  final double lat;
  final double lng;

  BusStop({required this.codDftrans, required this.lat, required this.lng});

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      codDftrans: json['codDftrans'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}
