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
        properties: json['properties'] != null
            ? PropertyRoute.fromJson(json['properties'])
            : PropertyRoute.empty());
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
  final int seqLinha;
  final String codLinha;

  PropertyRoute(
      {required this.sentido, required this.seqLinha, required this.codLinha});

  factory PropertyRoute.fromJson(Map<String, dynamic> json) {
    return PropertyRoute(
      sentido: json['sentido']?.toString() ?? "",
      seqLinha: int.tryParse(json['seqLinha']?.toString() ?? "") ?? 0,
      codLinha: json['codLinha']?.toString() ?? "",
    );
  }

  factory PropertyRoute.empty() {
    return PropertyRoute(sentido: "", seqLinha: 0, codLinha: "");
  }
}

class PropertyLocation {
  final String numero;
  final int horario;
  final String linha;
  final String operadora;
  final int idOperadora;

  PropertyLocation({
    required this.numero,
    required this.horario,
    required this.linha,
    required this.operadora,
    required this.idOperadora,
  });

  factory PropertyLocation.fromJson(Map<String, dynamic> json) {
    return PropertyLocation(
      numero: json['numero']?.toString() ?? "",
      horario: int.tryParse(json['horario']?.toString() ?? "") ?? 0,
      linha: json['linha']?.toString() ?? "",
      operadora: json['operadora']?.toString() ?? "",
      idOperadora: int.tryParse(json['idOperadora']?.toString() ?? "") ?? 0,
    );
  }
}

class BusDirection {
  final String origem;
  final String destino;
  final String sentido;
  final double extensao;
  final List<Itinerario> itinerario;

  BusDirection({
    required this.origem,
    required this.destino,
    required this.sentido,
    required this.extensao,
    required this.itinerario,
  });

  factory BusDirection.fromJson(Map<String, dynamic> json) {
    return BusDirection(
        origem: json['origem'] ?? '',
        destino: json['destino'] ?? '',
        sentido: json['sentido'] ?? '',
        extensao: double.tryParse(json['extensao']?.toString() ?? "0") ?? 0.0,
        itinerario: ((json['itinerario'] ?? []) as List)
            .map((i) => Itinerario.fromJson(i))
            .toList());
  }
}

class Itinerario {
  final int sequencial;
  final String via;
  final String localidade;

  Itinerario(
      {required this.sequencial, required this.via, required this.localidade});

  factory Itinerario.fromJson(Map<String, dynamic> json) {
    return Itinerario(
        sequencial: int.tryParse(json['sequencial']?.toString() ?? "") ?? 0,
        via: json['via'] ?? "",
        localidade: json['localidade'] ?? "");
  }
}
