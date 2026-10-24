import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/home_category_use_case.dart';
import '../../domain/usecases/home_products_use_case.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeCategoryUseCase homeCategoryUseCase;
  final HomeProductsUseCase homeProductsUseCase;

  HomeCubit({
    required this.homeCategoryUseCase,
    required this.homeProductsUseCase,
  }) : super(HomeInitial());

  Future<void> loadHome() async {
    emit(HomeLoadingState());

    final categoryResult = await homeCategoryUseCase();
    categoryResult.when(
      success: (categoryList) async {
        emit(CategorySuccess(categoryList));
        if (categoryList.isEmpty) {
          emit(HomeProductsSuccessState(const []));
          return;
        }

        final productResult = await homeProductsUseCase(categoryList.first.id);
        productResult.when(
          success: (products) => emit(HomeProductsSuccessState(products)),
          failure: (message) => emit(HomeProductsFailureState(message)),
        );
      },
      failure: (message) => emit(HomeFailureState(message)),
    );
  }

  Future<void> getProducts(int? categoryId) async {
    emit(HomeProductsLoadingState());

    final productResult = await homeProductsUseCase(categoryId);
    productResult.when(
      success: (products) => emit(HomeProductsSuccessState(products)),
      failure: (message) => emit(HomeProductsFailureState(message)),
    );
  }
}
