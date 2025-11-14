import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

class PurchaseService {
  static late StreamSubscription<List<PurchaseDetails>> _subscription;
  static const String _subscriptionId = 'your_subscription_product_id'; // Replace with actual product ID

  static Future<void> init() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      // The store cannot be reached or accessed
      return;
    }

    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        // Handle error here
      },
    );
  }

  static void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Handle pending purchase
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          // Deliver content and mark as delivered
          await _deliverProduct(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    }
  }

  static Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    // TODO: Implement product delivery logic
    // For example, unlock premium features, update user status, etc.
  }

  static Future<void> purchaseSubscription() async {
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails({_subscriptionId});
    if (response.productDetails.isNotEmpty) {
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: response.productDetails.first);
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  static void dispose() {
    _subscription.cancel();
  }
}