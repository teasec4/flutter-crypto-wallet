import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_crypto_wallet/application/coin_list/coin_list_provider.dart';
import 'package:flutter_crypto_wallet/application/coin_list/coin_list_state.dart';
import 'package:flutter_crypto_wallet/domain/coin.dart';
import 'package:flutter_crypto_wallet/presentation/core/widgets/coin_item.dart';
import 'package:flutter_crypto_wallet/presentation/core/widgets/critical_failure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_builder/responsive_builder.dart';


import '../core/utils.dart';

class BalancePage extends ConsumerWidget {
  const BalancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(coinNotifierProvider);
    return state.map(
        initial: () {
          return Container();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (e) => _SuccessContent(loaded: e),
        failure: (e) => CriticalFailure(
            color: Colors.white,
            onRetry: () {
              ref.read(coinNotifierProvider.notifier).getCoins();
            }));
  }
}

class _SuccessContent extends StatefulWidget {
  const _SuccessContent({Key? key, required Loaded loaded})
      : _loaded = loaded,
        super(key: key);

  final Loaded _loaded;
  @override
  __SuccessContentState createState() => __SuccessContentState();
}

class __SuccessContentState extends State<_SuccessContent> {
  final _color = const Color(0XFFF3A00FF);
  bool visibility = true;

  @override
  Widget build(BuildContext context) {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    final isDesktop = deviceType == DeviceScreenType.desktop;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: _color,
          elevation: 0,
          centerTitle: true,

          title: AnimatedCrossFade(
            crossFadeState: visibility
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.centerLeft,
            firstCurve: Curves.easeInCirc,
            secondChild: Text(Utils.getPrice(widget._loaded.totalDollars),
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 46.sp,
                    fontWeight: FontWeight.bold)),
            firstChild: Text('Mi Portafolio',
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 46.sp,
                    fontWeight: FontWeight.bold)),
          )),
      backgroundColor: _color,
      body: isDesktop && ScreenUtil().orientation == Orientation.landscape
          ? Row(
              children: [
                _HeaderSection(
                  isDesktop: true,
                  total: Utils.getPrice(widget._loaded.totalDollars),
                ),
                Expanded(child: _BalanceSection(coins: widget._loaded.coins, onRemoveCoin: _showRemoveCoinDialog))
              ],
            )
          : Stack(
              children: [
                _HeaderSection(
                  total: Utils.getPrice(widget._loaded.totalDollars),
                ),
                NotificationListener<DraggableScrollableNotification>(
                    onNotification:
                        (DraggableScrollableNotification dsNotification) {
                      if (visibility && dsNotification.extent >= 0.75) {
                        setState(() {
                          visibility = false;
                        });
                      } else if (!visibility && dsNotification.extent <= 0.75) {
                        setState(() {
                          visibility = true;
                        });
                      }
                      return true;
                    },
                    child: DraggableScrollableSheet(
                        minChildSize: 0.45,
                        maxChildSize: 1,
                        initialChildSize: 0.45,
                        builder: (context, scrollController) {
                          return _BalanceSection(
                              scrollController: scrollController,
                              coins: widget._loaded.coins,
                              onRemoveCoin: _showRemoveCoinDialog);
                        }))
              ],
            ),
    );
    }

  void _showRemoveCoinDialog(BuildContext context, WidgetRef ref, Coin coin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${coin.name} from Portfolio'),
        content: Text('Are you sure you want to remove ${coin.name} (${coin.symbol}) from your portfolio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(coinNotifierProvider.notifier).removeCoinFromPortfolio(coin.symbol);
              Navigator.of(context).pop();
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _BalanceSection extends StatelessWidget {
  const _BalanceSection({
    Key? key,
    ScrollController? scrollController,
    required List<Coin> coins,
    required Function(BuildContext, WidgetRef, Coin) onRemoveCoin,
  })  : _scrollController = scrollController,
        _coins = coins,
        _onRemoveCoin = onRemoveCoin,
        super(key: key);

  final ScrollController? _scrollController;
  final List<Coin> _coins;
  final Function(BuildContext, WidgetRef, Coin) _onRemoveCoin;

  @override
  Widget build(BuildContext context) {
    final portfolioCoins = _coins.where((coin) => (coin.amount ?? 0) > 0).toList();
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30), topLeft: Radius.circular(30)),
      child: Container(
        color: Colors.white,
        child: ListView.builder(
          padding: EdgeInsets.only(top: 20.h),
          controller: _scrollController,
          itemBuilder: (context, index) {
            final coin = portfolioCoins[index];
            return Consumer(
              builder: (context, ref, child) {
                return CoinItem(
                  coin: coin,
                  isPortafolio: true,
                  showAddButton: true,
                  onAddToPortfolio: () => _onRemoveCoin(context, ref, coin),
                );
              },
            );
          },
          itemCount: portfolioCoins.length,
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({Key? key, required this.total, this.isDesktop = false})
      : super(key: key);
  final String total;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Animate(
          child: SizedBox(
            height: isDesktop ? 1000.h : 500.h,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Lottie.asset(
                  'assets/animation.json',
                ),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('En mi Billetera',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 22.sp,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500)),
                      SizedBox(
                        height: 10.h,
                      ),
                      SizedBox(
                        width: 300.w,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(total,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 46.sp,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            context.go('/convert');
          },
          child: PhysicalModel(
            shadowColor: Colors.white,
            elevation: 4,
            color: const Color(0XFFF01FFB2),
            borderRadius: BorderRadius.circular(25),
            child: Container(
              alignment: Alignment.center,
              height: 70.h,
              width: 600.w,
              constraints: const BoxConstraints(maxWidth: 400),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sync_alt,
                    color: const Color(0XFFF3A00FF),
                    size: 35.h,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Text('Convertir',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: const Color(0XFFF3A00FF),
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        )
        ],
        );
        }
}
