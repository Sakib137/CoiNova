enum TransactionType {
  send,
  receive,
  swap,
  stake,
}

enum TransactionStatus {
  completed,
  pending,
  failed,
}

class TransactionModel {
  final String id;
  final TransactionType type;
  final String assetSymbol;
  final double amount;
  final double fiatAmount;
  final DateTime timestamp;
  final String recipientOrSender;
  final TransactionStatus status;
  final String txHash;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.assetSymbol,
    required this.amount,
    required this.fiatAmount,
    required this.timestamp,
    required this.recipientOrSender,
    required this.status,
    required this.txHash,
  });

  String get typeLabel {
    switch (type) {
      case TransactionType.send:
        return 'Sent';
      case TransactionType.receive:
        return 'Received';
      case TransactionType.swap:
        return 'Swapped';
      case TransactionType.stake:
        return 'Staked';
    }
  }

  bool get isCredit => type == TransactionType.receive;
}
