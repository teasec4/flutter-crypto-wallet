import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_crypto_wallet/domain/coin.dart';
import 'package:flutter_crypto_wallet/domain/coin_failure.dart';
import 'package:flutter_crypto_wallet/domain/i_coin_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for the CoinRepository, providing access to coin data operations.
final coinRepositoryProvider = Provider<ICoinRepository>(
  (ref) => CoinRepository(),
);

/// Repository for fetching cryptocurrency data from CoinGecko API with caching support.
class CoinRepository implements ICoinRepository {
  static const String _cacheKey = 'coins_cache';
  static const Duration _cacheDuration = Duration(minutes: 5);

  @override
  Future<Either<CoinFailure, List<Coin>>> get() async {
    try {
      // Check cache first
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      final cacheTime = prefs.getInt('${_cacheKey}_time');

      if (cachedData != null && cacheTime != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - cacheTime;
        if (cacheAge < _cacheDuration.inMilliseconds) {
          // Use cached data
          final List<dynamic> jsonList = jsonDecode(cachedData);
          final coins = jsonList.map((json) => Coin.fromJson(json)).toList();
          return right(coins);
        }
      }

      // Fetch from API using Dio
      final dio = Dio(BaseOptions(
        baseUrl: 'https://api.coingecko.com/api/v3',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await dio.get(
        '/coins/markets',
        queryParameters: {
          'vs_currency': 'usd',
          'ids': 'bitcoin,ethereum,tether,cardano,binancecoin,ripple,dogecoin,usd-coin,polkadot,internet-computer,uniswap',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        final coins = data.map((json) => Coin.fromJson(json)).toList();

        // Cache the data
        await prefs.setString(_cacheKey, jsonEncode(data));
        await prefs.setInt('${_cacheKey}_time', DateTime.now().millisecondsSinceEpoch);

        return right(coins);
      } else {
        return left(const Unexpected());
      }
    } catch (e) {
      return left(const Unexpected());
    }
  }

  /// Simulates updating the portfolio after a conversion.
  /// In a real implementation, this would persist changes to a backend or local storage.
  @override
  Future<Either<CoinFailure, Unit>> updatePortafolio(Coin to, Coin from) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return right(unit);
  }
}
