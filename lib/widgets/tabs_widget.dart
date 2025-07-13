import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/pages/home_page/home_page.dart';
import 'package:df_bus/pages/maps_page/bus_stop_page.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/theme_notifier.dart';
import 'package:flutter/material.dart';

class TabsMainWidget extends StatefulWidget {
  const TabsMainWidget({super.key});

  @override
  State<TabsMainWidget> createState() => _TabsMainWidgetState();
}

class _TabsMainWidgetState extends State<TabsMainWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _allowSwipe = true;

  static const List<Tab> tabs = [
    Tab(text: "Linhas"),
    Tab(text: "Mapa"),
  ];

  final searchLineController = getIt<SearchLineController>();

  final themeNotifier = getIt<ThemeNotifier>();
  final originIdNotifier =
      getIt<ValueNotifier<String>>(instanceName: 'originId');
  final destIdNotifier = getIt<ValueNotifier<String>>(instanceName: 'destId');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);

    _tabController.addListener(() {
      setState(() {
        _allowSwipe = _tabController.index != 1;
        originIdNotifier.value = '';
        destIdNotifier.value = '';
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          labelColor: Colors.amber,
          indicatorColor: Colors.amber,
          unselectedLabelColor: Colors.blueGrey,
        ),
        actions: [
          ValueListenableBuilder<bool>(
              valueListenable: themeNotifier,
              builder: (context, isDarkMode, _) {
                return IconButton(
                  onPressed: themeNotifier.toggleDarkMode,
                  icon: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.white,
                  ),
                );
              })
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        physics: _allowSwipe
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        children: [
          HomePage(),
          BusStopPage(),
        ],
      ),
    );
  }
}
