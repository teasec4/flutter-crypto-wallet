import 'package:flutter_crypto_wallet/application/coin_list/coin_list_notifier.dart';
import 'package:flutter_crypto_wallet/application/coin_list/coin_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final coinNotifierProvider =
    NotifierProvider<CoinListNotifier, CoinListState>(
  CoinListNotifier.new,
);
