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

enum SearchType { linha, referencia }

class _SearchLineInputWidgetState extends State<SearchLineInputWidget> {
  final searchLineController = getIt<SearchLineController>();
  SearchType _type = SearchType.linha;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            searchTypeOptions(context, "Linha"),
            searchTypeOptions(context, "Origem/Destino")
          ],
        ),
        IndexedStack(
          index: _type.index,
          children: [SearchByLineWidget(), SearchByRefWidget()],
        )
      ],
    );
  }

  Expanded searchTypeOptions(BuildContext context, String title) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _type = title == "Linha" ? SearchType.linha : SearchType.referencia;
          });
        },
        child: Row(
          children: [
            Radio<SearchType>(
              value:
                  title == "Linha" ? SearchType.linha : SearchType.referencia,
              groupValue: _type,
              activeColor: Theme.of(context).colorScheme.secondary,
              onChanged: (SearchType? value) {
                setState(() {
                  if (value != null) _type = value;
                });
              },
            ),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
