import 'package:featuremind/core/usecases/usecases.dart';
import 'package:featuremind/features/news_search/presentation/providers/news_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchHistoryWidget extends ConsumerWidget {
  final Function(String) onHistoryItemTap;

  const SearchHistoryWidget({
    super.key,
    required this.onHistoryItemTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyUseCase = ref.watch(getSearchHistoryUseCaseProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<List<String>>(
      future: historyUseCase(NoParams()).then((result) => result.fold(
          (failure) => <String>[], // Return empty list on failure
          (history) => history // Return successful history
          )),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Searches',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: snapshot.data!.map((query) {
                return ActionChip(
                  label: Text(query),
                  onPressed: () => onHistoryItemTap(query),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
