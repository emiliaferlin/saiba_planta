import 'package:flutter/material.dart';
import 'package:trabalho_final/main.dart';
import 'package:provider/provider.dart';
import 'package:trabalho_final/src/model/planta_model.dart';
import 'package:trabalho_final/src/provider/planta_provider.dart';
import 'package:trabalho_final/src/view/cadastro_planta/cadastro_planta_form.dart';
import 'package:intl/intl.dart';

class CadastroPlantaView extends StatefulWidget {
  const CadastroPlantaView({super.key});

  @override
  State<CadastroPlantaView> createState() => _CadastroPlantaViewState();
}

class _CadastroPlantaViewState extends State<CadastroPlantaView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<PlantaProvider>(context, listen: false).fetchItems(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          "Cadastro de Plantas",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CadastroPlantaForm()),
          );
          Future.microtask(
            () =>
                Provider.of<PlantaProvider>(
                  context,
                  listen: false,
                ).fetchItems(),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<PlantaProvider>(
        builder: (context, provider, child) {
          if (provider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final item = provider.items[index];
              return _buildItem(context, item, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    PlantaModel item,
    PlantaProvider provider,
  ) {
    return Card(
      child: ListTile(
        title: Text(item.nome),
        subtitle: Text(
          'Data: ${DateFormat('dd/MM/yyyy').format(item.timestamp)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle, color: Colors.red),
          onPressed: () => _confirmarExclusao(context, provider, item.id),
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CadastroPlantaForm(plantaModel: item),
            ),
          ).then((value) async {
            await provider.fetchItems();
          });
        },
      ),
    );
  }

  void _confirmarExclusao(
    BuildContext context,
    PlantaProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Confirmação Exclusão"),
            content: Text("Deseja realmente excluir este item?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () async {
                  await provider.deleteItem(id);
                  Navigator.pop(context);
                },
                child: Text("Excluir"),
              ),
            ],
          ),
    );
  }
}
