import 'package:animated_toggle/animated_toggle.dart';
import 'package:flutter/material.dart';

class SearchLineInputWidget extends StatefulWidget {
  final void Function(String) onAddLine;

  const SearchLineInputWidget({super.key, required this.onAddLine});

  @override
  State<SearchLineInputWidget> createState() => _SearchLineInputWidgetState();
}

class _SearchLineInputWidgetState extends State<SearchLineInputWidget> {
  final TextEditingController _controller = TextEditingController();
  int selectedIndex = 0;
  List<String> options = ['Linha', 'Referência'];

  void _onSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onAddLine(text);
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: AnimatedHorizontalToggle(
            taps: options,
            width: MediaQuery.of(context).size.width - 100,
            height: 40,
            duration: Duration(milliseconds: 200),
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
        if (selectedIndex == 0)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Digite a linha',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _onSubmit(),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                  size: 35,
                ),
                onPressed: _onSubmit,
              )
            ],
          ),
        if (selectedIndex == 1)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Origem',
                    border: OutlineInputBorder(),
                  ),
                  //onSubmitted: (_) => _onSubmit(),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Destino',
                    border: OutlineInputBorder(),
                  ),
                  //onSubmitted: (_) => _onSubmit(),
                ),
              ),
            ],
          )
      ],
    );
  }
}
