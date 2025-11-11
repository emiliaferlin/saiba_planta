import 'package:flutter/material.dart';
import 'package:trabalho_final/main.dart';
import 'package:trabalho_final/src/components/textfield_personalizado.dart';
import 'package:trabalho_final/src/model/planta_model.dart';
import 'package:trabalho_final/src/services/planta_dao.dart';

class CadastroPlantaForm extends StatefulWidget {
  final PlantaModel? plantaModel;

  const CadastroPlantaForm({super.key, this.plantaModel});
  @override
  CadastroPlantaFormState createState() => CadastroPlantaFormState();
}

class CadastroPlantaFormState extends State<CadastroPlantaForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController controladorNome = TextEditingController();
  TextEditingController controladorCaracteristicas = TextEditingController();
  TextEditingController controladorCuidados = TextEditingController();
  String? id;
  PlantaDao service = PlantaDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.plantaModel?.nome != null
              ? "Editar Planta"
              : "Cadastra Planta",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 18.0, left: 28.0, right: 28.0),
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              gravar(context);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: Text(
            "Salvar",
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: TextfieldPersonalizado(
                    controlador: controladorNome,
                    rotulo: "Nome da planta",
                  ),
                ),
                Visibility(
                  visible: controladorCaracteristicas.text.isNotEmpty,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: TextfieldPersonalizado(
                      controlador: controladorCaracteristicas,
                      rotulo: "Características",
                    ),
                  ),
                ),
                Visibility(
                  visible: controladorCuidados.text.isNotEmpty,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: TextfieldPersonalizado(
                      controlador: controladorCuidados,
                      rotulo: "Cuidados",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  gravar(BuildContext context) async {
    if (id != null) {
      // alteração
      final item = PlantaModel(
        id: id!,
        nome: controladorNome.text,
        caracteristicas: controladorCaracteristicas.text,
        cuidados: controladorCuidados.text,
        timestamp: DateTime.now(),
      );
      await service.update(item).then((value) => Navigator.pop(context));
    } else {
      // inclusão
      final item = PlantaModel(
        id: "",
        nome: controladorNome.text,
        caracteristicas: controladorCaracteristicas.text,
        cuidados: controladorCuidados.text,
        timestamp: DateTime.now(),
      );
      await service.add(item).then((value) => Navigator.pop(context));
    }
    final SnackBar snackBar = SnackBar(
      content: Text("Operação realizada com sucesso"),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    if (widget.plantaModel != null) {
      // alteração
      id = widget.plantaModel!.id;
      controladorNome.text = widget.plantaModel?.nome ?? "";
      controladorCaracteristicas.text =
          widget.plantaModel?.caracteristicas ?? "";
      controladorCuidados.text = widget.plantaModel?.cuidados ?? "";
    }
  }
}
