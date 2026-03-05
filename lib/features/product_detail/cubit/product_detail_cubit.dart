import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/products_repository.dart';
import 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit({ProductsRepository? repository})
      : _repository = repository ?? ProductsRepository(),
        super(const ProductDetailState());

  final ProductsRepository _repository;

  Future<void> loadProduct(int id) async {
    emit(state.copyWith(status: ProductDetailStatus.loading, errorMessage: null));
    try {
      final product = await _repository.getProductById(id);
      if (product == null) {
        emit(state.copyWith(
          status: ProductDetailStatus.error,
          errorMessage: 'Product not found',
        ));
        return;
      }
      emit(state.copyWith(status: ProductDetailStatus.loaded, product: product));
    } catch (e) {
      emit(state.copyWith(
        status: ProductDetailStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void clear() {
    emit(const ProductDetailState());
  }
}
