class FeatureBusLocation {
  final List<FeatureLocation> features;
  final String type;

  FeatureBusLocation({required this.features, required this.type});

  factory FeatureBusLocation.fromJson(Map<String, dynamic> json) {
    return FeatureBusLocation(
        features: ((json['features'] ?? []) as List)
            .map((f) => FeatureLocation.fromJson(f))
            .toList(),
        type: json['type']?.toString() ?? "");
  }
}

class FeatureLocation {
  final GeometryLocation geometry;
  final String type;
  final PropertiesLocation properties;

  FeatureLocation(
      {required this.geometry, required this.type, required this.properties});

  factory FeatureLocation.fromJson(Map<String, dynamic> json) {
    return FeatureLocation(
        geometry: json['geometry'] != null
            ? GeometryLocation.fromJson(json['geometry'])
            : GeometryLocation.empty(),
        type: json['type']?.toString() ?? "",
        properties: json['properties'] != null
            ? PropertiesLocation.fromJson(json['properties'])
            : PropertiesLocation.empty());
  }
}

class GeometryLocation {
  final List<double> coordinates;
  final String type;

  GeometryLocation({required this.coordinates, required this.type});

  factory GeometryLocation.fromJson(Map<String, dynamic> json) {
    return GeometryLocation(
        coordinates: ((json['coordinates'] ?? []) as List)
            .map((c) => (c as num).toDouble())
            .toList(),
        type: json['type']?.toString() ?? "");
  }

  factory GeometryLocation.empty() {
    return GeometryLocation(coordinates: [], type: "");
  }
}

class PropertiesLocation {
  final String numero;
  final int horario;
  final String linha;
  final String operadora;
  final int idOperadora;

  PropertiesLocation({
    required this.numero,
    required this.horario,
    required this.linha,
    required this.operadora,
    required this.idOperadora,
  });

  factory PropertiesLocation.fromJson(Map<String, dynamic> json) {
    return PropertiesLocation(
      numero: json['numero']?.toString() ?? "",
      horario: int.tryParse(json['horario']?.toString() ?? "") ?? 0,
      linha: json['linha']?.toString() ?? "",
      operadora: json['operadora']?.toString() ?? "",
      idOperadora: int.tryParse(json['id_operadora']?.toString() ?? "") ?? 0,
    );
  }

  factory PropertiesLocation.empty() {
    return PropertiesLocation(
      numero: "",
      horario: 0,
      linha: "",
      operadora: "",
      idOperadora: 0,
    );
  }
}
