import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/show_maps_notifier.dart';
import 'package:flutter/material.dart';

class TesteScreen extends StatefulWidget {
  const TesteScreen({super.key});

  @override
  State<TesteScreen> createState() => _TesteScreenState();
}

class _TesteScreenState extends State<TesteScreen> {
  final showMapsNotifier = getIt<ShowMapsNotifier>();

  @override
  void initState() {
    debugPrint("+++++++++++++++++++++++ Entrou na tela nova de TESTE");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "DF BUS",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showMapsNotifier.value = false;
        },
        child: Icon(Icons.close),
      ),
      body: Text("Teste"),
    );
  }
}
