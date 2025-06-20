import 'package:flutter/material.dart';

class SearchLineInputWidget extends StatefulWidget {
  final void Function(String) onAddLine;

  const SearchLineInputWidget({super.key, required this.onAddLine});

  @override
  State<SearchLineInputWidget> createState() => _SearchLineInputWidgetState();
}

class _SearchLineInputWidgetState extends State<SearchLineInputWidget> {
  final TextEditingController _controller = TextEditingController();

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
    return Row(
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
    );
  }
}
