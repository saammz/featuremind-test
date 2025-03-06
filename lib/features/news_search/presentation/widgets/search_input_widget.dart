import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchInputWidget extends ConsumerWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final bool isLoading;

  const SearchInputWidget({
    super.key,
    required this.controller,
    required this.onSearch,
    this.isLoading = false,
  });

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search for news...',
        suffixIcon: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _validateAndSearch(context),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (value) => _validateAndSearch(context),
      enabled: !isLoading,
    );
  }
}
