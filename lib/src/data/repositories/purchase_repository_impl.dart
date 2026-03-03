import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/constants.dart';
import '../../domain/repositories/purchase_repository.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  PurchaseRepositoryImpl(this._iap);

  final InAppPurchase _iap;

  @override
  Stream<List<PurchaseDetails>> purchaseStream() => _iap.purchaseStream;

  @override
  Future<List<ProductDetails>> fetchProducts() async {
    final response = await _iap.queryProductDetails(
      {AppConstants.monthlySubId, AppConstants.yearlySubId},
    );
    if (response.error != null) {
      return [];
    }
    return response.productDetails;
  }

  @override
  Future<void> buy(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<void> restore() async {
    await _iap.restorePurchases();
  }
}
