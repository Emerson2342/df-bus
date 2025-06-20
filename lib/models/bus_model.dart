class DetalheOnibus {
  final int sequencial;
  final String numero;
  final String descricao;
  final String sentido;
  final FaixaTarifaria faixaTarifaria;
  final bool ativa;
  final Bacia bacia;
  final String tipoLinha;
  final List<Operadora> operadoras;
  final List<TipoOnibus> tipoOnibus;

  DetalheOnibus({
    required this.sequencial,
    required this.numero,
    required this.descricao,
    required this.sentido,
    required this.faixaTarifaria,
    required this.ativa,
    required this.bacia,
    required this.tipoLinha,
    required this.operadoras,
    required this.tipoOnibus,
  });

  factory DetalheOnibus.fromJson(Map<String, dynamic> json) {
    return DetalheOnibus(
      sequencial: int.tryParse(json['sequencial']?.toString() ?? "") ?? 0,
      numero: json['numero']?.toString() ?? "",
      descricao: json['descricao']?.toString() ?? "",
      sentido: json['sentido']?.toString() ?? "",
      faixaTarifaria: json['faixaTarifaria'] != null
          ? FaixaTarifaria.fromJson(json['faixaTarifaria'])
          : FaixaTarifaria.empty(),
      ativa: json['ativa'] ?? false,
      bacia:
          json['bacia'] != null ? Bacia.fromJson(json['bacia']) : Bacia.empty(),
      tipoLinha: json['tipoLinha']?.toString() ?? "",
      operadoras: (json['operadoras'] as List<dynamic>? ?? [])
          .map((o) => Operadora.fromJson(o))
          .toList(),
      tipoOnibus: (json['tipoOnibus'] as List<dynamic>? ?? [])
          .map((t) => TipoOnibus.fromJson(t))
          .toList(),
    );
  }
}

class FaixaTarifaria {
  final int sequencial;
  final String descricao;
  final double tarifa;

  FaixaTarifaria(
      {required this.sequencial,
      required this.descricao,
      required this.tarifa});

  factory FaixaTarifaria.fromJson(Map<String, dynamic> json) {
    return FaixaTarifaria(
        sequencial: int.tryParse(json['sequencial']?.toString() ?? "") ?? 0,
        descricao: json['descricao']?.toString() ?? "",
        tarifa: double.tryParse(json['tarifa']?.toString() ?? "") ?? 0.0);
  }
  factory FaixaTarifaria.empty() {
    return FaixaTarifaria(sequencial: 0, descricao: '', tarifa: 0.0);
  }
}

class Bacia {
  final int sequencial;
  final String descricao;

  Bacia({required this.sequencial, required this.descricao});

  factory Bacia.fromJson(Map<String, dynamic> json) {
    return Bacia(
        sequencial: int.tryParse(json['sequencial']?.toString() ?? "") ?? 0,
        descricao: json['descricao']?.toString() ?? "");
  }
  factory Bacia.empty() {
    return Bacia(sequencial: 0, descricao: "");
  }
}

class Operadora {
  final int id;
  final String nome;
  final String sigla;
  final String razaoSocial;

  Operadora(
      {required this.id,
      required this.nome,
      required this.sigla,
      required this.razaoSocial});

  factory Operadora.fromJson(Map<String, dynamic> json) {
    return Operadora(
        id: int.tryParse(json['id']?.toString() ?? "") ?? 0,
        nome: json['nome']?.toString() ?? "",
        sigla: json['sigla']?.toString() ?? "",
        razaoSocial: json['razaoSocial']?.toString() ?? "");
  }

  factory Operadora.empty() {
    return Operadora(id: 0, nome: "", sigla: "", razaoSocial: "");
  }
}

class TipoOnibus {
  final int id;
  final String descricao;
  final int numSentados;

  TipoOnibus(
      {required this.id, required this.descricao, required this.numSentados});

  factory TipoOnibus.fromJson(Map<String, dynamic> json) {
    return TipoOnibus(
        id: int.tryParse(json['id']?.toString() ?? "") ?? 0,
        descricao: json['descricao']?.toString() ?? "",
        numSentados: int.tryParse(json['numSentados']?.toString() ?? "") ?? 0);
  }

  factory TipoOnibus.empty() {
    return TipoOnibus(id: 0, descricao: "", numSentados: 0);
  }
}

class SearchLine {
  final String numero;
  final String descricao;
  final double tarifa;

  SearchLine(
      {required this.numero, required this.descricao, required this.tarifa});

  factory SearchLine.fromJson(Map<String, dynamic> json) {
    return SearchLine(
        numero: json['numero']?.toString() ?? "",
        descricao: json['descricao']?.toString() ?? "",
        tarifa: double.tryParse(json['tarifa']?.toString() ?? "") ?? 0.0);
  }
}
