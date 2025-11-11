import 'package:flutter/material.dart';
import 'package:trabalho_final/src/model/planta_model.dart';
import 'package:trabalho_final/src/services/planta_dao.dart';

class PlantaProvider extends ChangeNotifier {
  final PlantaDao _dao = PlantaDao();
  List<PlantaModel> _items = [];

  List<PlantaModel> get items => _items;

  Future<void> fetchItems() async {
    final result = await _dao.getList();
    _items = result ?? [];
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    await _dao.delete(id);
    await fetchItems();
  }
}
