class PlantaModel {
  String id;
  String nome;
  String caracteristicas;
  String cuidados;
  String imagemUrl;
  DateTime timestamp;

  PlantaModel({
    required this.id,
    required this.nome,
    required this.caracteristicas,
    required this.cuidados,
    required this.imagemUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      "nome": nome,
      "caracteristicas": caracteristicas,
      "cuidados": cuidados,
      "imagemUrl": imagemUrl,
      "timestamp": timestamp.toIso8601String(),
    };
  }

  factory PlantaModel.fromMap(Map<String, dynamic> map, String id) {
    return PlantaModel(
      id: id,
      nome: map["nome"],
      caracteristicas: map["caracteristicas"],
      cuidados: map["cuidados"],
      imagemUrl: map["imagemUrl"],
      timestamp: DateTime.parse(map["timestamp"].toString()),
    );
  }
}
