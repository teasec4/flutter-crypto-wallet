import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_crypto_wallet/domain/coin_failure.dart';
import 'package:flutter_crypto_wallet/domain/i_portfolio_repository.dart';
import 'package:flutter_crypto_wallet/domain/portfolio_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for the PortfolioRepository.
final portfolioRepositoryProvider = Provider<IPortfolioRepository>(
  (ref) => PortfolioRepository(),
);

/// Repository for managing user's cryptocurrency portfolio using SharedPreferences.
class PortfolioRepository implements IPortfolioRepository {
  static const String _portfolioKey = 'user_portfolio';

  @override
  Future<Either<CoinFailure, List<PortfolioItem>>> getPortfolio() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final portfolioData = prefs.getString(_portfolioKey);

      if (portfolioData == null) {
        // Return empty portfolio for new users
        return right([]);
      }

      final List<dynamic> jsonList = jsonDecode(portfolioData);
      final portfolio = jsonList
          .map((json) => PortfolioItem.fromJson(json))
          .toList();

      return right(portfolio);
    } catch (e) {
      return left(const Unexpected());
    }
  }

  @override
  Future<Either<CoinFailure, Unit>> addToPortfolio(PortfolioItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final portfolioResult = await getPortfolio();

      return portfolioResult.fold(
        (failure) => left(failure),
        (portfolio) async {
          // Check if coin already exists
          final existingIndex = portfolio.indexWhere(
            (existing) => existing.symbol == item.symbol,
          );

          if (existingIndex != -1) {
            // Update existing item
            portfolio[existingIndex] = item;
          } else {
            // Add new item
            portfolio.add(item);
          }

          final jsonList = portfolio.map((item) => item.toJson()).toList();
          await prefs.setString(_portfolioKey, jsonEncode(jsonList));
          return right(unit);
        },
      );
    } catch (e) {
      return left(const Unexpected());
    }
  }

  @override
  Future<Either<CoinFailure, Unit>> removeFromPortfolio(String symbol) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final portfolioResult = await getPortfolio();

      return portfolioResult.fold(
        (failure) => left(failure),
        (portfolio) async {
          portfolio.removeWhere((item) => item.symbol == symbol);
          final jsonList = portfolio.map((item) => item.toJson()).toList();
          await prefs.setString(_portfolioKey, jsonEncode(jsonList));
          return right(unit);
        },
      );
    } catch (e) {
      return left(const Unexpected());
    }
  }

  @override
  Future<Either<CoinFailure, Unit>> updatePortfolioItem(PortfolioItem item) async {
    // This is the same as addToPortfolio for now
    return addToPortfolio(item);
  }
}
