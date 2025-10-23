/// Represents a cryptocurrency holding in the user's portfolio.
class PortfolioItem {
  const PortfolioItem({
    required this.symbol,
    required this.amount,
  });

  final String symbol;
  final double amount;

  /// Creates a PortfolioItem from JSON for persistence.
  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      symbol: json['symbol'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  /// Converts this PortfolioItem to JSON for persistence.
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'amount': amount,
    };
  }

  PortfolioItem copyWith({
    String? symbol,
    double? amount,
  }) {
    return PortfolioItem(
      symbol: symbol ?? this.symbol,
      amount: amount ?? this.amount,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PortfolioItem &&
      symbol == other.symbol &&
      amount == other.amount;

  @override
  int get hashCode => Object.hash(symbol, amount);

  @override
  String toString() => 'PortfolioItem(symbol: $symbol, amount: $amount)';
}
