import 'package:flutter/material.dart';
import 'package:trabalho_final/main.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class IdentificacaoImagemView extends StatefulWidget {
  const IdentificacaoImagemView({super.key});

  @override
  State<IdentificacaoImagemView> createState() =>
      _IdentificacaoImagemViewState();
}

class _IdentificacaoImagemViewState extends State<IdentificacaoImagemView> {
  InputImage? inputImage;
  bool isScanning = false;
  XFile? imageFile;
  String result = "";

  // Tradutor local (Inglês → Português)
  late OnDeviceTranslator onDeviceTranslator;
  final modelManager = OnDeviceTranslatorModelManager();

  @override
  void initState() {
    super.initState();
    inicializarTradutor();
  }

  /// Inicializa o tradutor e garante o download dos modelos de tradução
  Future<void> inicializarTradutor() async {
    // Faz o download dos modelos se necessário
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            imageFile == null ? Container() : Image.file(File(imageFile!.path)),
            const SizedBox(height: 40.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                result,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(height: 40.0),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: ElevatedButton(
                onPressed: () {
                  showImageSourceDialog(context);
                },
                child: const Text("Checar Imagem"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Escolhe imagem da galeria ou câmera
  void pickImage(ImageSource source) async {
    var pickedImage = await ImagePicker().pickImage(
      source: source,
      maxHeight: 200,
      maxWidth: 200,
    );
    Navigator.of(context).pop();

    try {
      if (pickedImage != null) {
        imageFile = pickedImage;
        setState(() {});
        processImage(pickedImage);
      }
    } catch (e) {
      isScanning = false;
      imageFile = null;
      result = "Erro ao processar imagem!";
      setState(() {});
      debugPrint("Exception: $e");
    }
  }

  /// Processa a imagem e faz a tradução dos rótulos
  Future<void> processImage(XFile image) async {
    setState(() {
      isScanning = true;
      result = "Processando imagem...";
    });

    final inputImage = InputImage.fromFilePath(image.path);
    final imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.75),
    );

    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    final StringBuffer sb = StringBuffer();

    for (ImageLabel imgLabel in labels) {
      final String lblText = imgLabel.label;
      final double confidence = imgLabel.confidence;

      // Tradução do rótulo detectado
      final String translatedLabel = await onDeviceTranslator.translateText(
        lblText,
      );

      sb.write("$translatedLabel ");
      sb.write(" : ");
      sb.write((confidence * 100).toStringAsFixed(2));
      sb.write("%\n");
    }

    imageLabeler.close();

    setState(() {
      result = sb.isEmpty ? "Nenhum objeto reconhecido." : sb.toString();
      isScanning = false;
    });
  }

  /// Mostra o diálogo para escolher a origem da imagem
  void showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Como deseja importar a imagem?",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
