import 'package:flutter_crypto_wallet/application/coin_convert/coin_convert_notifier.dart';
import 'package:flutter_crypto_wallet/application/coin_convert/coin_convert_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final coinConvertNotifierProvider =
    NotifierProvider.autoDispose<CoinConvertNotifier, CoinConvertState>(
  CoinConvertNotifier.new,
);
