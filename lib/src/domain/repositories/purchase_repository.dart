import 'package:in_app_purchase/in_app_purchase.dart';

abstract class PurchaseRepository {
  Stream<List<PurchaseDetails>> purchaseStream();
  Future<List<ProductDetails>> fetchProducts();
  Future<void> buy(ProductDetails product);
  Future<void> restore();
}
