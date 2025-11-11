import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trabalho_final/src/model/planta_model.dart';

class PlantaDao {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> add(PlantaModel plantaModel) async {
    try {
      await _firestore.collection("plantas").add(plantaModel.toMap());
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> update(PlantaModel plantaModel) async {
    try {
      final snapshot = _firestore.collection("plantas").doc(plantaModel.id);
      await snapshot.update(plantaModel.toMap());
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> delete(String id) async {
    try {
      final snapshot = _firestore.collection("plantas").doc(id);
      await snapshot.delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<PlantaModel>?> getList() async {
    List<PlantaModel> lista = [];
    try {
      final snapshot = await _firestore.collection("plantas").get();
      for (var doc in snapshot.docs) {
        print(doc.toString());
        lista.add(PlantaModel.fromMap(doc.data(), doc.id));
      }
      return lista;
    } catch (e) {
      print(e.toString());
      return lista;
    }
  }
}
