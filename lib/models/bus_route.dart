class FeatureBusRoute {
  final List<FeatureRoute> features;
  final String type;

  FeatureBusRoute({required this.features, required this.type});

  factory FeatureBusRoute.fromJson(Map<String, dynamic> json) {
    return FeatureBusRoute(
      features: json['features'] != null
          ? (json['features'] as List)
              .map((f) => FeatureRoute.fromJson(f))
              .toList()
          : [],
      type: json['type']?.toString() ?? "",
    );
  }
}

class FeatureRoute {
  final Geometry geometry;
  final String type;
  final PropertyRoute properties;

  FeatureRoute(
      {required this.geometry, required this.type, required this.properties});

  factory FeatureRoute.fromJson(Map<String, dynamic> json) {
    return FeatureRoute(
        geometry: json['geometry'] != null
            ? Geometry.fromJson(json['geometry'])
            : Geometry.empty(),
        type: json['type']?.toString() ?? "",
        properties: json['properties']);
  }
  factory FeatureRoute.empty() {
    return FeatureRoute(
        geometry: Geometry.empty(),
        type: "",
        properties: PropertyRoute.empty());
  }
}

class Geometry {
  final List<List<double>> coordinates;
  final String type;

  Geometry({required this.coordinates, required this.type});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
        coordinates: (json['coordinates'] as List)
            .map((coord) => (coord as List)
                .map((value) => (value as num).toDouble())
                .toList())
            .toList(),
        type: json['type']?.toString() ?? "");
  }

  factory Geometry.empty() {
    return Geometry(coordinates: [], type: "");
  }
}

class PropertyRoute {
  final String sentido;
  final String seqLinha;
  final String codLinha;

  PropertyRoute(
      {required this.sentido, required this.seqLinha, required this.codLinha});

  factory PropertyRoute.fromJson(Map<String, dynamic> json) {
    return PropertyRoute(
      sentido: json['sentido']?.toString() ?? "",
      seqLinha: json['seqLinha']?.toString() ?? "",
      codLinha: json['codLinha']?.toString() ?? "",
    );
  }

  factory PropertyRoute.empty() {
    return PropertyRoute(sentido: "", seqLinha: "", codLinha: "");
  }
}
