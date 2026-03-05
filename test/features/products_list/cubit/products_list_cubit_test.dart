import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog_app/data/repositories/products_repository.dart';
import 'package:product_catalog_app/features/products_list/cubit/products_list_cubit.dart';
import 'package:product_catalog_app/features/products_list/cubit/products_list_state.dart';

void main() {
  group('ProductsListCubit', () {
    late ProductsRepository repository;

    setUp(() {
      repository = ProductsRepository();
    });

    test('initial state is ProductsListState.initial', () {
      final cubit = ProductsListCubit(repository: repository);
      expect(cubit.state.status, ProductsListStatus.initial);
      expect(cubit.state.products, isEmpty);
      expect(cubit.state.categories, isEmpty);
      expect(cubit.state.selectedCategory, isNull);
      expect(cubit.state.searchQuery, '');
      expect(cubit.state.hasMore, true);
      cubit.close();
    });

    blocTest<ProductsListCubit, ProductsListState>(
      'setSearchQuery updates searchQuery',
      build: () => ProductsListCubit(repository: repository),
      act: (c) => c.setSearchQuery('phone'),
      expect: () => [
        isA<ProductsListState>()
            .having((s) => s.searchQuery, 'searchQuery', 'phone'),
      ],
    );

    blocTest<ProductsListCubit, ProductsListState>(
      'setCategory updates selectedCategory',
      build: () => ProductsListCubit(repository: repository),
      act: (c) => c.setCategory('smartphones'),
      expect: () => [
        isA<ProductsListState>()
            .having((s) => s.selectedCategory, 'selectedCategory', 'smartphones'),
      ],
    );

    blocTest<ProductsListCubit, ProductsListState>(
      'setCategory null clears selection',
      build: () => ProductsListCubit(repository: repository),
      act: (c) {
        c.setCategory('smartphones');
        c.setCategory(null);
      },
      skip: 1,
      expect: () => [
        isA<ProductsListState>()
            .having((s) => s.selectedCategory, 'selectedCategory', isNull),
      ],
    );
  });
}
