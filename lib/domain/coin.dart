/// Represents a cryptocurrency coin with its market data and optional portfolio amounts.
/// Used throughout the app for displaying coin information and handling conversions.
class Coin {
  const Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.image,
    required this.currentPrice,
    required this.priceChange,
    this.amount,
    this.dollars,
  });

  final String id;
  final String name;
  final String symbol;
  final String image;
  final double currentPrice;
  final double priceChange;
  final double? amount;
  final double? dollars;

  /// Creates a Coin from CoinGecko API JSON response.
  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      image: json['image'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      priceChange: (json['price_change_percentage_24h'] as num).toDouble(),
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      dollars: json['dollars'] != null ? (json['dollars'] as num).toDouble() : null,
    );
  }

  /// Converts this Coin to JSON for caching/storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'image': image,
      'current_price': currentPrice,
      'price_change_percentage_24h': priceChange,
      'amount': amount,
      'dollars': dollars,
    };
  }

  Coin copyWith({
    String? id,
    String? name,
    String? symbol,
    String? image,
    double? currentPrice,
    double? priceChange,
    double? amount,
    double? dollars,
  }) {
    return Coin(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      image: image ?? this.image,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChange: priceChange ?? this.priceChange,
      amount: amount ?? this.amount,
      dollars: dollars ?? this.dollars,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Coin &&
      id == other.id &&
      name == other.name &&
      symbol == other.symbol &&
      image == other.image &&
      currentPrice == other.currentPrice &&
      priceChange == other.priceChange &&
      amount == other.amount &&
      dollars == other.dollars;

  @override
  int get hashCode => Object.hash(
      id, name, symbol, image, currentPrice, priceChange, amount, dollars);

  @override
  String toString() =>
      'Coin(id: $id, name: $name, symbol: $symbol, image: $image, currentPrice: $currentPrice, priceChange: $priceChange, amount: $amount, dollars: $dollars)';
}
