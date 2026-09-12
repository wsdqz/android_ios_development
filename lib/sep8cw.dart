void main() {
  print(processOrder(orderId: 1, itemPrice: 10000, promoCode: 'SAVE10'));
  print(
    processOrder(
      orderId: 2,
      itemPrice: 10000,
      promoCode: 'SAVE10',
      deliveryFee: 300
    ),
  );
}

double processOrder({
  required int orderId,
  required double itemPrice,
  String? promoCode,
  double? deliveryFee,
}) {
  double finalDeliveryFee = deliveryFee ?? 500.0;
  double deliveryFeeTemp = finalDeliveryFee < 500 ? 500 : finalDeliveryFee;
  var discountPrice = promoCode == 'SAVE10' ? itemPrice * 0.9 : itemPrice;
  var finalPrice = discountPrice + deliveryFeeTemp;
  return finalPrice;
}
