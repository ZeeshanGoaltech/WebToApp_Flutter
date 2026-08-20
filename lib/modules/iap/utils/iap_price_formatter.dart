import 'package:in_app_purchase/in_app_purchase.dart';

class IapPriceFormatter {
  IapPriceFormatter._();

  static String formatPerWeek(ProductDetails yearly) {
    final perWeek = yearly.rawPrice / 52;
    return _formatAmount(perWeek, yearly);
  }

  static String _formatAmount(double amount, ProductDetails product) {
    final symbol = product.currencySymbol;
    if (symbol.isNotEmpty) {
      final formatted = amount == amount.roundToDouble()
          ? amount.toStringAsFixed(0)
          : amount.toStringAsFixed(2);
      return '$symbol$formatted';
    }

    return amount.toStringAsFixed(2);
  }
}
