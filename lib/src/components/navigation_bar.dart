import 'package:flutter/material.dart';
import 'package:trabalho_final/main.dart';
import 'package:trabalho_final/src/view/cadastro_planta/cadastro_planta_view.dart';
import 'package:trabalho_final/src/view/identificacao_imagem/identificacao_imagem_view.dart';
import 'package:trabalho_final/src/view/logout/logout_view.dart';

class BottomNavigationBarApp extends StatefulWidget {
  final int indexPage;
  const BottomNavigationBarApp({super.key, required this.indexPage});

  @override
  State<BottomNavigationBarApp> createState() => _BottomNavigationBarAppState();
}

class _BottomNavigationBarAppState extends State<BottomNavigationBarApp> {
  int indexPage = 0;

  static const List<Widget> pagesOptions = <Widget>[
    CadastroPlantaView(),
    IdentificacaoImagemView(),
    LogoutView(),
  ];

  void selectPage(int index) {
    setState(() {
      indexPage = index;
    });
  }

  @override
  void initState() {
    setState(() {
      indexPage = widget.indexPage;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: pagesOptions.elementAt(indexPage)),
      bottomNavigationBar: BottomNavigationBar(
        // Altera a cor do ícone e do label quando o item é selecionado
        selectedItemColor: primaryColor,
        // Altera a cor do ícone e do label quando o item não é selecionado
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.eco_outlined),
            label: 'Plantas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image_outlined),
            label: 'Imagem',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout_outlined),
            label: 'Sair',
          ),
        ],
        currentIndex: indexPage,
        onTap: selectPage,
      ),
    );
  }
}
