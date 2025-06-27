class QuerySearch {
  String descricao;
  final int sequencialRef;
  final String tipo;

  QuerySearch(
      {required this.descricao,
      required this.sequencialRef,
      required this.tipo});

  factory QuerySearch.fromJson(Map<String, dynamic> json) {
    return QuerySearch(
        descricao: json['descricao']?.toString() ?? "",
        sequencialRef:
            int.tryParse(json['sequencialRef']?.toString() ?? "") ?? 0,
        tipo: json['tipo']?.toString() ?? "");
  }
}
