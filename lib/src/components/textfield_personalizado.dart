import 'package:flutter/material.dart';

class TextfieldPersonalizado extends StatelessWidget {
  final TextEditingController? controlador;
  final String? rotulo;
  final String? dica;
  final IconData? icone;
  const TextfieldPersonalizado({
    this.controlador,
    this.rotulo,
    this.dica,
    this.icone,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controlador,
      style: TextStyle(fontSize: 20.0),
      decoration: InputDecoration(
        icon: icone != null ? Icon(icone) : null,
        labelText: rotulo,
        hintText: dica,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Campo obrigatório";
        }
        return null;
      },
    );
  }
}
