import 'package:animated_toggle/animated_toggle.dart';
import 'package:df_bus/controller/search_line_controller.dart';
import 'package:df_bus/pages/home_page/widgets/search_by_line_widget.dart';
import 'package:df_bus/pages/home_page/widgets/search_by_reference_widget.dart';
import 'package:df_bus/services/service_locator.dart';
import 'package:flutter/material.dart';

class SearchLineInputWidget extends StatefulWidget {
  const SearchLineInputWidget({super.key});

  @override
  State<SearchLineInputWidget> createState() => _SearchLineInputWidgetState();
}

class _SearchLineInputWidgetState extends State<SearchLineInputWidget> {
  final searchLineController = getIt<SearchLineController>();

  int selectedIndex = 0;
  List<String> options = ['Linha', 'Referência'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: AnimatedHorizontalToggle(
            taps: options,
            width: MediaQuery.of(context).size.width - 100,
            height: 40,
            duration: Duration(milliseconds: 100),
            activeColor: Theme.of(context).colorScheme.secondary,
            initialIndex: 0,
            onChange: (currentIndex, targetIndex) {
              setState(() {
                selectedIndex = currentIndex;
              });
            },
          ),
        ),
        SizedBox(height: 15),
        IndexedStack(
          index: selectedIndex,
          children: [SearchByLineWidget(), SearchByRefWidget()],
        )
        // if (selectedIndex == 0) SearchByLineWidget(),
        // if (selectedIndex == 1) SearchByRefWidget()
      ],
    );
  }
}
