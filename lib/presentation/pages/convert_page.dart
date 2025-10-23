import 'package:flutter_crypto_wallet/application/coin_convert/coin_convert_notifier.dart';
import 'package:flutter_crypto_wallet/application/coin_convert/coin_convert_provider.dart';
import 'package:flutter_crypto_wallet/domain/coin.dart';
import 'package:flutter_crypto_wallet/presentation/core/utils.dart';
import 'package:flutter_crypto_wallet/presentation/core/widgets/image_coin.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../application/coin_convert/coin_convert_state.dart';

class ConvertPage extends ConsumerStatefulWidget {
  const ConvertPage({super.key});

  @override
  ConsumerState<ConvertPage> createState() => _ConvertPageState();
}

class _ConvertPageState extends ConsumerState<ConvertPage> {
  static const _color = Color(0xfff3a00ff);

  @override
  Widget build(BuildContext context) {
    ref.listen(coinConvertNotifierProvider, (previous, next) {
      if (next.isPreview) {
        context.go('/confirmation');
      }
    });
    final state = ref.watch(coinConvertNotifierProvider);
    final notifier = ref.read(coinConvertNotifierProvider.notifier);
    final msg1 = state.from?.dollars != null ? '${Utils.getPrice(state.from!.dollars!)} disponible' : 'Select a coin';
    final validationText = state.from == null ? '' : state.validation.fold(
      () => 'Tienes ' + Utils.getCoinAmount(state.from!.amount!, state.from!.symbol) + ' disponible.',
      (validation) => validation.map(
        empty: (_) => 'Ingrese una cantidad mayor',
        invalid: (_) => 'No tienes suficientes ' + state.from!.symbol.toUpperCase(),
      ),
    );
    if (state.isLoading) {
      return Scaffold(
        body: Center(
          child: Container(
            color: Colors.white,
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }
    if (state.from == null || state.to == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: true,
          leading: IconButton(
            color: Colors.black,
            iconSize: 45.h,
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/'),
          ),
          title: const Text('Convertir',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No coins in portfolio',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add some coins to your portfolio first to start converting',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/coins'),
                child: const Text('Browse Coins'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          color: Colors.black,
          iconSize: 45.h,
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
        title: Column(
          children: [
            Text('Convertir ' + (state.from?.name ?? ''),
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              height: 5.h,
            ),
            Text(msg1,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 110.h),
                Text('\$${state.amount}',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: _color,
                          fontSize: 126.sp,
                          fontWeight: FontWeight.normal)),
                      SizedBox(height: 15.h),
                Text(
                validationText,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                color: Colors.black54,
                fontSize: 32.sp,
                fontWeight: FontWeight.normal)),
                SizedBox(height: 110.h),
                _ExchangeCoin(
                from: state.from!,
                to: state.to!,
                state: state,
                notifier: notifier,
                ref: ref,
                onCoinTap: (isFrom) => _showCoinSelector(context, ref, isFrom),
                onSwap: () {
                    final temp = state.from!;
                    notifier.fromChanged(state.to!);
                    notifier.toChanged(temp);
                  },
                ),
                SizedBox(
                  height: 70.h,
                ),
                _Keyboard(notifier: notifier),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCoinSelector(BuildContext context, WidgetRef ref, bool isFrom) {
    final state = ref.read(coinConvertNotifierProvider);
    final notifier = ref.read(coinConvertNotifierProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Select ${isFrom ? 'From' : 'To'} Coin',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: state.all?.length ?? 0,
                    itemBuilder: (context, index) {
                      final coin = state.all![index];
                      final isSelected = isFrom ? coin.id == state.from?.id : coin.id == state.to?.id;

                      return ListTile(
                        leading: Image.network(
                          'https://assets.coingecko.com/coins/images/${coin.id}/thumb/${coin.id}.png',
                          width: 40.w,
                          height: 40.h,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.currency_bitcoin, size: 40),
                        ),
                        title: Text(
                          coin.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          coin.symbol.toUpperCase(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: _ConvertPageState._color,
                                size: 24.sp,
                              )
                            : coin.amount != null && coin.amount! > 0
                                ? Text(
                                    '${coin.amount!.toStringAsFixed(4)} ${coin.symbol.toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : null,
                        onTap: () {
                          if (isFrom) {
                            notifier.fromChanged(coin);
                          } else {
                            notifier.toChanged(coin);
                          }
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ExchangeCoin extends StatelessWidget {
  const _ExchangeCoin({
    required this.from,
    required this.to,
    required this.state,
    required this.notifier,
    required this.ref,
    required this.onCoinTap,
    required this.onSwap,
  });

  final Coin from, to;
  final CoinConvertState state;
  final CoinConvertNotifier notifier;
  final WidgetRef ref;
  final Function(bool) onCoinTap;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
        flex: 1,
        child: GestureDetector(
        onTap: () => onCoinTap(true),
        child: _CoinColumn(
        coin: from,
        isFrom: true,
        notifier: notifier,
        ),
        ),
        ),
        Flexible(
          flex: 0,
          child: IconButton(
            onPressed: onSwap,
            icon: Icon(
              Icons.swap_horiz,
              size: 40.sp,
              color: _ConvertPageState._color,
            ),
          ),
        ),
        Flexible(
        flex: 1,
        child: GestureDetector(
        onTap: () => onCoinTap(false),
        child: _CoinColumn(
        coin: to,
        isFrom: false,
        notifier: notifier,
        ),
        ),
        ),
      ],
    );
  }
}

class _CoinColumn extends StatelessWidget {
  const _CoinColumn({
    required this.coin,
    required this.isFrom,
    required this.notifier,
  });

  final Coin coin;
  final bool isFrom;
  final CoinConvertNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ImageCoin(imageUrl: coin.id),
        SizedBox(height: 10.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            coin.name,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: isFrom ? _ConvertPageState._color : Colors.black54,
            ),
            maxLines: 1,
          ),
        ),
        SizedBox(height: 5.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            coin.symbol.toUpperCase(),
            style: TextStyle(
              fontSize: 24.sp,
              color: Colors.black54,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class _Keyboard extends StatelessWidget {
  const _Keyboard({required this.notifier});

  final CoinConvertNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _KeyboardButton(text: '1', onPressed: () => notifier.onKeyboardTap('1')),
        _KeyboardButton(text: '2', onPressed: () => notifier.onKeyboardTap('2')),
        _KeyboardButton(text: '3', onPressed: () => notifier.onKeyboardTap('3')),
        _KeyboardButton(text: '4', onPressed: () => notifier.onKeyboardTap('4')),
        _KeyboardButton(text: '5', onPressed: () => notifier.onKeyboardTap('5')),
        _KeyboardButton(text: '6', onPressed: () => notifier.onKeyboardTap('6')),
        _KeyboardButton(text: '7', onPressed: () => notifier.onKeyboardTap('7')),
        _KeyboardButton(text: '8', onPressed: () => notifier.onKeyboardTap('8')),
        _KeyboardButton(text: '9', onPressed: () => notifier.onKeyboardTap('9')),
        _KeyboardButton(text: '0', onPressed: () => notifier.onKeyboardTap('0')),
        _KeyboardButton(text: '.', onPressed: () => notifier.onKeyboardTap('.')),
        IconButton(
          iconSize: 35.h,
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => notifier.onKeyboardDelete(),
        ),
      ],
    );
  }
}



class _KeyboardButton extends StatelessWidget {
  const _KeyboardButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade100,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          minimumSize: Size(80.w, 80.h),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
