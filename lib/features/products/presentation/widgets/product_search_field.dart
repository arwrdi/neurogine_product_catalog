import 'package:flutter/material.dart';

import '../../../../core/utils/debounce.dart';

class ProductSearchField extends StatefulWidget {
  const ProductSearchField({
    super.key,
    this.initialQuery = '',
    required this.onSearch,
  });

  final String initialQuery;
  final ValueChanged<String> onSearch;

  @override
  State<ProductSearchField> createState() => _ProductSearchFieldState();
}

class _ProductSearchFieldState extends State<ProductSearchField> {
  final _debounce = Debounce();
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialQuery);
  }

  void _onChanged(String value) {
    setState(() {});
    _debounce(() {
      if (mounted) widget.onSearch(value.trim());
    });
  }

  void _clear() {
    _debounce.cancel();
    _textController.clear();
    setState(() {});
    widget.onSearch('');
  }

  @override
  void dispose() {
    _debounce.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _textController,
    onChanged: _onChanged,
    textInputAction: TextInputAction.search,
    onSubmitted: (value) {
      _debounce.cancel();
      widget.onSearch(value.trim());
    },
    decoration: InputDecoration(
      labelText: 'Search products',
      hintText: 'Try phone or mascara',
      prefixIcon: const Icon(Icons.search),
      border: const OutlineInputBorder(),
      suffixIcon:
          _textController.text.isEmpty
              ? null
              : IconButton(
                tooltip: 'Clear search',
                onPressed: _clear,
                icon: const Icon(Icons.close),
              ),
    ),
  );
}
