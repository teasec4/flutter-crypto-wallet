import 'package:flutter_crypto_wallet/domain/coin.dart';
import 'package:flutter_crypto_wallet/domain/i_coin_repository.dart';
import 'package:flutter_crypto_wallet/domain/i_portfolio_repository.dart';
import 'package:flutter_crypto_wallet/domain/portfolio_item.dart';
import 'package:flutter_crypto_wallet/repository/coin_repository.dart';
import 'package:flutter_crypto_wallet/repository/portfolio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'coin_list_state.dart';

class CoinListNotifier extends Notifier<CoinListState> {
  @override
  CoinListState build() {
    Future.microtask(() => getCoins());
    return const Initial();
  }

  ICoinRepository get _coinRepository => ref.read(coinRepositoryProvider);
  IPortfolioRepository get _portfolioRepository => ref.read(portfolioRepositoryProvider);

  Future<void> getCoins() async {
    state = const Loading();

    // Load portfolio and coins in parallel
    final portfolioResult = await _portfolioRepository.getPortfolio();
    final coinsResult = await _coinRepository.get();

    state = coinsResult.fold(
      (failure) => Failure(failure),
      (coins) {
        return portfolioResult.fold(
          (failure) => Failure(failure),
          (portfolio) {
            var totalDollars = 0.0;
            for (var portfolioItem in portfolio) {
              var index = coins.indexWhere(
                (coin) => portfolioItem.symbol == coin.symbol,
              );
              if (index != -1) {
                final amount = portfolioItem.amount;
                final dollars = coins[index].currentPrice * amount;
                totalDollars += dollars;
                coins[index] =
                    coins[index].copyWith(amount: amount, dollars: dollars);
              }
            }
            return Loaded(coins, totalDollars);
          },
        );
      },
    );
  }

  void coinsChanged(List<Coin> coins) async {
    final actualCoins = (state as Loaded).coins;
    var total = (state as Loaded).totalDollars;

    // Actualizo los valores actuales de la lista
    for (var coin in coins) {
      var index = actualCoins.indexWhere((item) => coin.symbol == item.symbol);
      if (index != -1) {
        if (actualCoins[index].amount == 0) {
          total += coin.dollars!;
        } else {
          total -= actualCoins[index].dollars!;
          total += coin.dollars!;
        }
        actualCoins[index] = coin;
      }
    }
    state = Loaded(actualCoins, total);
  }

  Future<void> addCoinToPortfolio(String symbol, double amount) async {
    if (state is! Loaded) return;

    final loadedState = state as Loaded;
    final coinIndex = loadedState.coins.indexWhere((coin) => coin.symbol == symbol);
    if (coinIndex == -1) return; // Coin not found

    final coin = loadedState.coins[coinIndex];
    final portfolioItem = PortfolioItem(symbol: symbol, amount: amount);

    final result = await _portfolioRepository.addToPortfolio(portfolioItem);
    result.fold(
      (failure) {
        // Handle error - could emit a failure state or show error
        state = Failure(failure);
      },
      (_) {
        // Update local state
        final updatedCoin = coin.copyWith(
          amount: amount,
          dollars: coin.currentPrice * amount,
        );
        final updatedCoins = List<Coin>.from(loadedState.coins);
        updatedCoins[coinIndex] = updatedCoin;

        final newTotal = loadedState.totalDollars + (coin.currentPrice * amount);
        state = Loaded(updatedCoins, newTotal);
      },
    );
  }

  Future<void> removeCoinFromPortfolio(String symbol) async {
    if (state is! Loaded) return;

    final loadedState = state as Loaded;
    final coinIndex = loadedState.coins.indexWhere((coin) => coin.symbol == symbol);
    if (coinIndex == -1) return; // Coin not found

    final coin = loadedState.coins[coinIndex];
    final result = await _portfolioRepository.removeFromPortfolio(symbol);
    result.fold(
      (failure) {
        state = Failure(failure);
      },
      (_) {
        // Update local state
        final updatedCoin = coin.copyWith(amount: null, dollars: null);
        final updatedCoins = List<Coin>.from(loadedState.coins);
        updatedCoins[coinIndex] = updatedCoin;

        final newTotal = loadedState.totalDollars - (coin.dollars ?? 0);
        state = Loaded(updatedCoins, newTotal);
      },
    );
  }
}


