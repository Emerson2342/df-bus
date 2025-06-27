class Referencia {
  final String descricao;
  final int sequencialRef;
  final String tipo;

  Referencia(
      {required this.descricao,
      required this.sequencialRef,
      required this.tipo});

  factory Referencia.fromJson(Map<String, dynamic> json) {
    return Referencia(
        descricao: json['descricao']?.toString() ?? "",
        sequencialRef:
            int.tryParse(json['sequencialRef']?.toString() ?? "") ?? 0,
        tipo: json['tipo']?.toString() ?? "");
  }
}
