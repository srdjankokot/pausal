import 'package:pausal_calculator/screens/app/client.dart';

class ClientShare {
  const ClientShare({
    required this.client,
    required this.amount,
    required this.share,
  });

  final Client client;
  final double amount;
  final double share;
}