import '../../domain/coin.dart';
import '../../domain/coin_failure.dart';

/// Represents the state of coin list loading.
/// Uses sealed classes for exhaustive pattern matching.
sealed class CoinListState {
const CoinListState();

/// Pattern matching method for handling different states.
T map<T>({
required T Function() initial,
required T Function() loading,
required T Function(Loaded) loaded,
required T Function(Failure) failure,
}) {
return switch (this) {
Initial() => initial(),
Loading() => loading(),
Loaded l => loaded(l),
Failure f => failure(f),
};
}
}

/// Initial state when no data has been loaded yet.
final class Initial extends CoinListState {
const Initial();
}

/// Loading state while fetching data from API.
final class Loading extends CoinListState {
  const Loading();
}

/// Loaded state with successful coin data.
final class Loaded extends CoinListState {
  const Loaded(this.coins, this.totalDollars);

  final List<Coin> coins;
final double totalDollars;
}

/// Failure state when API request fails.
final class Failure extends CoinListState {
  const Failure(this.failure);

  final CoinFailure failure;
}
