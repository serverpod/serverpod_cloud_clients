import 'package:ground_control_client/ground_control_client.dart';

class OrderTreeBuilder {
  bool _fulfilled = false;

  OrderTreeBuilder withFulfilled([bool fulfilled = true]) {
    _fulfilled = fulfilled;
    return this;
  }

  OrderTree build() {
    return OrderTree(
      id: const Uuid().v4obj(),
      ownerId: const Uuid().v4obj(),
      productType: ProductType.project,
      origin: OrderOrigin.client,
      kind: OrderKind.provisioning,
      fulfilled: _fulfilled,
      children: const [],
    );
  }
}
