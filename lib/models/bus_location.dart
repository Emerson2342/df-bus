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

  factory FeatureBusLocation.empty() {
    return FeatureBusLocation(features: [], type: "");
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

class AllBusLocation {
  final Operadora operadora;
  final List<Veiculo> veiculos;

  AllBusLocation({required this.operadora, required this.veiculos});

  factory AllBusLocation.fromJson(Map<String, dynamic> json) {
    return AllBusLocation(
        operadora: json['operadora'] != null
            ? Operadora.fromJson(json['operadora'])
            : Operadora.empty(),
        veiculos: ((json['veiculos'] ?? []) as List)
            .map((v) => Veiculo.fromJson(v))
            .toList());
  }
}

class Operadora {
  final int id;

  Operadora({required this.id});

  factory Operadora.fromJson(Map<String, dynamic> json) {
    return Operadora(id: json["id"] ?? 0);
  }
  factory Operadora.empty() {
    return Operadora(id: 0);
  }
}

class Veiculo {
  final String numero;
  final String linha;
  final int horario;
  final Localizacao localizacao;
  final String sentido;
  final double direcao;

  Veiculo(
      {required this.numero,
      required this.linha,
      required this.horario,
      required this.localizacao,
      required this.sentido,
      required this.direcao});

  factory Veiculo.fromJson(Map<String, dynamic> json) {
    return Veiculo(
      numero: json['numero'] ?? "",
      linha: json['linha'] ?? "",
      horario: int.tryParse(json['horario']?.toString() ?? "") ?? 0,
      localizacao: json['localizacao'] != null
          ? Localizacao.fromJson(json['localizacao'])
          : Localizacao.empty(),
      sentido: json['sentido'] ?? "",
      direcao: double.tryParse(json['direcao']?.toString() ?? "") ?? 0,
    );
  }
}

class Localizacao {
  final double latitude;
  final double longitude;

  Localizacao({required this.latitude, required this.longitude});

  factory Localizacao.fromJson(Map<String, dynamic> json) {
    return Localizacao(
        latitude: double.tryParse(json['latitude']?.toString() ?? "") ?? 0,
        longitude: double.tryParse(json['longitude']?.toString() ?? "") ?? 0);
  }

  factory Localizacao.empty() {
    return Localizacao(latitude: 0, longitude: 0);
  }
}
