import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../providers/category_providers.dart';
import '../widgets/category_card_widget.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories & Cuisines'),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const AppEmptyState(
              icon: Icons.category_rounded,
              title: 'No Categories Available',
              description: 'Categories will appear here once loaded.',
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryCardWidget(
                category: category,
                onTap: () {
                  context.pushNamed(
                    RouteNames.categoryRecipes,
                    pathParameters: {'id': category.id},
                  );
                },
              );
            },
          );
        },
        loading: () => const AppLoadingIndicator(message: 'Loading categories...'),
        error: (err, _) => AppErrorState(
          message: err.toString(),
          onRetry: () => ref.refresh(categoriesProvider),
        ),
      ),
    );
  }
}
