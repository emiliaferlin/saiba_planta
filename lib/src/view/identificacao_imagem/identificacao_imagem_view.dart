import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import 'package:trabalho_final/main.dart';
import 'package:trabalho_final/src/components/textfield_personalizado.dart';
import 'package:trabalho_final/src/model/planta_model.dart';
import 'package:trabalho_final/src/services/planta_dao.dart';

class IdentificacaoImagemView extends StatefulWidget {
  const IdentificacaoImagemView({super.key});

  @override
  State<IdentificacaoImagemView> createState() =>
      _IdentificacaoImagemViewState();
}

class _IdentificacaoImagemViewState extends State<IdentificacaoImagemView> {
  TextEditingController? controladorNome = TextEditingController();
  bool isScanning = false;
  bool isPickingImage = false;
  bool contemPlanta = false;

  XFile? imageFile;
  String result = "";
  String nomeDetectado = "";

  late OnDeviceTranslator onDeviceTranslator;
  final modelManager = OnDeviceTranslatorModelManager();

  @override
  void initState() {
    super.initState();
    inicializarTradutor();
  }

  Future<void> inicializarTradutor() async {
    await modelManager.downloadModel(TranslateLanguage.english.bcpCode);
    await modelManager.downloadModel(TranslateLanguage.portuguese.bcpCode);

    onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.portuguese,
    );
  }

  @override
  void dispose() {
    onDeviceTranslator.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "Identificação de Imagens",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              imageFile == null
                  ? const SizedBox()
                  : Image.file(File(imageFile!.path), height: 200),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  result,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 40),
              Visibility(
                visible: contemPlanta,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 16.0,
                    left: 32.0,
                    right: 32.0,
                  ),
                  child: TextfieldPersonalizado(
                    controlador: controladorNome,
                    rotulo: "Nome da planta",
                  ),
                ),
              ),
              if (contemPlanta)
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: ElevatedButton(
                    onPressed:
                        isScanning
                            ? null
                            : () async {
                              if (imageFile != null) {
                                if (controladorNome?.text.isNotEmpty == true) {
                                  await cadastrarPlanta(
                                    controladorNome?.text ?? nomeDetectado,
                                    imageFile!,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Insira um nome antes! "),
                                    ),
                                  );
                                }
                              }
                            },
                    child:
                        isScanning
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text("Cadastrar planta"),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: ElevatedButton(
                  onPressed:
                      isScanning
                          ? null
                          : () async {
                            await showImageSourceDialog(context);
                          },
                  child:
                      isScanning
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Checar Imagem"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pega a imagem da galeria ou câmera
  void pickImage(ImageSource source) async {
    if (isPickingImage) return;
    isPickingImage = true;

    try {
      final pickedImage = await ImagePicker().pickImage(
        source: source,
        maxHeight: 200,
        maxWidth: 200,
      );
      Navigator.of(context).pop();

      if (pickedImage != null) {
        imageFile = pickedImage;
        setState(() {});
        await processImage(pickedImage);
      }
    } catch (e) {
      setState(() => result = "Erro ao processar imagem!");
    } finally {
      isPickingImage = false;
    }
  }

  /// Processa a imagem e identifica se é planta
  processImage(XFile image) async {
    setState(() {
      isScanning = true;
      result = "Processando imagem...";
    });

    final inputImage = InputImage.fromFilePath(image.path);
    final imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.75),
    );
    final labels = await imageLabeler.processImage(inputImage);

    final StringBuffer sb = StringBuffer();
    contemPlanta = false;

    for (final label in labels) {
      final translatedLabel = await onDeviceTranslator.translateText(
        label.label,
      );
      sb.writeln(
        "$translatedLabel : ${(label.confidence * 100).toStringAsFixed(2)}%",
      );

      if (translatedLabel.toLowerCase().contains("planta") ||
          translatedLabel.toLowerCase().contains("flor") ||
          translatedLabel.toLowerCase().contains("árvore") ||
          translatedLabel.toLowerCase().contains("folha")) {
        contemPlanta = true;
        nomeDetectado = translatedLabel;
      }
    }

    imageLabeler.close();

    setState(() {
      result = sb.isEmpty ? "Nenhum objeto reconhecido." : sb.toString();
      isScanning = false;
    });
  }

  /// Cadastra planta e envia imagem para Firebase Storage
  cadastrarPlanta(String nome, XFile imagemSelecionada) async {
    try {
      setState(() => isScanning = true);

      //Upload da imagem para o Storage
      final storageRef = FirebaseStorage.instance.ref();
      final fileName =
          'planta_${DateTime.now().millisecondsSinceEpoch}${path.extension(imagemSelecionada.path)}';
      final imageRef = storageRef.child('plantas/$fileName');

      await imageRef.putFile(File(imagemSelecionada.path));

      //Pega URL pública da imagem
      final imageUrl = await imageRef.getDownloadURL();

      // Gera características e cuidados com Gemini
      final caracteristicas = await Gemini.instance.prompt(
        parts: [
          Part.text(
            "Liste em formato de tópicos 3 características principais da planta $nome. "
            "Responda de forma curta e fácil de entender e coloque os tópicos em números (1., 2., 3.).",
          ),
        ],
      );

      final cuidados = await Gemini.instance.prompt(
        parts: [
          Part.text(
            "Liste em formato de tópicos 3 cuidados essenciais para cultivar a planta $nome. "
            "Inclua dicas práticas e curtas e coloque os tópicos em números (1., 2., 3.).",
          ),
        ],
      );

      // Cria objeto e salva no Firestore
      final novaPlanta = PlantaModel(
        id: "",
        timestamp: DateTime.now(),
        nome: nome,
        caracteristicas: caracteristicas?.output ?? "",
        cuidados: cuidados?.output ?? "",
        imagemUrl: imageUrl,
      );

      await PlantaDao().add(novaPlanta);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Planta '$nome' cadastrada com sucesso!")),
        );
      }
    } catch (e) {
      debugPrint("Erro ao cadastrar planta: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao cadastrar planta")),
        );
      }
    } finally {
      setState(() => isScanning = false);
    }
  }

  /// Mostra diálogo para escolher origem da imagem
  showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Como deseja importar a imagem?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Galeria de fotos'),
              onTap: () => pickImage(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Câmera'),
              onTap: () => pickImage(ImageSource.camera),
            ),
          ],
        );
      },
    );
  }
}
