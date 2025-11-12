import 'package:flutter/material.dart';
import 'package:trabalho_final/main.dart';
import 'package:trabalho_final/src/components/textfield_personalizado.dart';
import 'package:trabalho_final/src/model/planta_model.dart';
import 'package:trabalho_final/src/services/planta_dao.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

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
  String? imagemUrl;
  String? id;
  PlantaDao service = PlantaDao();
  bool carregandoResposta = false;

  @override
  void initState() {
    super.initState();
    if (widget.plantaModel != null) {
      id = widget.plantaModel?.id;
      controladorNome.text = widget.plantaModel?.nome ?? "";
      controladorCaracteristicas.text =
          widget.plantaModel?.caracteristicas ?? "";
      controladorCuidados.text = widget.plantaModel?.cuidados ?? "";
      imagemUrl = widget.plantaModel?.imagemUrl ?? "";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.plantaModel?.nome != null
              ? "Editar Planta"
              : "Cadastrar Planta",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
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
          child: const Text(
            "Salvar",
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        ),
      ),
      body:
          carregandoResposta
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextfieldPersonalizado(
                          controlador: controladorNome,
                          rotulo: "Nome da planta",
                        ),
                      ),

                      // Exibir imagem da internet (PNG)
                      if (imagemUrl != null && imagemUrl!.isNotEmpty)
                        Center(
                          child: Image.network(
                            imagemUrl!,
                            width: 300,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),

                      if (controladorCaracteristicas.text.isNotEmpty)
                        _buildInfoCard(
                          titulo: "Características",
                          texto: controladorCaracteristicas.text,
                          icone: Icons.eco,
                          corIcone: Colors.green,
                        ),

                      if (controladorCuidados.text.isNotEmpty)
                        _buildInfoCard(
                          titulo: "Cuidados",
                          texto: controladorCuidados.text,
                          icone: Icons.water_drop,
                          corIcone: Colors.blueAccent,
                        ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildInfoCard({
    required String titulo,
    required String texto,
    required IconData icone,
    required Color corIcone,
  }) {
    final itens =
        texto
            .replaceAll(RegExp(r'(\*\*|\*)'), '')
            .split(RegExp(r'\d+\.\s'))
            .where((item) => item.trim().isNotEmpty)
            .toList();

    if (itens.isNotEmpty) itens.removeAt(0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(itens.length, (index) {
                final numero = index + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: corIcone.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icone, size: 16, color: corIcone),
                            const SizedBox(width: 4),
                            Text(
                              "$numero.",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: corIcone,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(itens[index].trim())),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> gravar(BuildContext context) async {
    setState(() => carregandoResposta = true);

    try {
      final caracteristicas = await Gemini.instance.prompt(
        parts: [
          Part.text(
            "Liste em formato de tópicos 3 características principais da planta ${controladorNome.text}. "
            "Responda de forma curta e fácil de entender e coloque os tópicos em números (1., 2., 3.).",
          ),
        ],
      );

      final cuidados = await Gemini.instance.prompt(
        parts: [
          Part.text(
            "Liste em formato de tópicos 3 cuidados essenciais para cultivar a planta ${controladorNome.text}. "
            "Inclua dicas práticas e curtas e coloque os tópicos em números (1., 2., 3.).",
          ),
        ],
      );

      setState(() {
        controladorCaracteristicas.text = caracteristicas?.output ?? "";
        controladorCuidados.text = cuidados?.output ?? "";
        carregandoResposta = false;
      });

      final item = PlantaModel(
        id: id ?? "",
        nome: controladorNome.text,
        caracteristicas: controladorCaracteristicas.text,
        cuidados: controladorCuidados.text,
        imagemUrl: imagemUrl ?? "",
        timestamp: DateTime.now(),
      );

      if (id != null) {
        await service.update(item);
      } else {
        await service.add(item);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Operação realizada com sucesso")),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => carregandoResposta = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao salvar planta: $e")));
    }
  }
}
