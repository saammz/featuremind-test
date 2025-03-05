import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchInputWidget extends ConsumerWidget {
  final TextEditingController controller;
  final Function(String) onSearch;

  const SearchInputWidget({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search for news...',
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _validateAndSearch(context),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (value) => _validateAndSearch(context),
    );
  }

  void _validateAndSearch(BuildContext context) {
    final query = controller.text.trim();
    if (query.isNotEmpty) {
      onSearch(query);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search term')),
      );
    }
  }
}
