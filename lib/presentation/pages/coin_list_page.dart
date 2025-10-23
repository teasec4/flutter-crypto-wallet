import 'package:flutter_crypto_wallet/application/coin_list/coin_list_provider.dart';
import 'package:flutter_crypto_wallet/domain/coin.dart';
import 'package:flutter_crypto_wallet/presentation/core/widgets/coin_item.dart';
import 'package:flutter_crypto_wallet/presentation/core/widgets/critical_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoinListPage extends StatefulWidget {
  const CoinListPage({Key? key}) : super(key: key);

  @override
  State<CoinListPage> createState() => _CoinListPageState();
}

class _CoinListPageState extends State<CoinListPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search all cryptocurrencies...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                    if (_searchQuery.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h, left: 8.w),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final state = ref.watch(coinNotifierProvider);
                            return state.map(
                            initial: () => const SizedBox.shrink(),
                            loading: () => const SizedBox.shrink(),
                              loaded: (loaded) {
                                final totalCoins = loaded.coins.length;
                                final filteredCoins = _filterCoins(loaded.coins);
                                return Text(
                                  'Found ${filteredCoins.length} of $totalCoins coins',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                              failure: (_) => const SizedBox.shrink(),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              // Coin List
              Expanded(
                child: Consumer(builder: (context, ref, child) {
                  final state = ref.watch(coinNotifierProvider);
                  return state.map(
                      initial: () {
                        return Container();
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      loaded: (e) => SuccesContent(
                            coins: _filterCoins(e.coins),
                            onAddCoin: (coin) => _showAddCoinDialog(context, ref, coin),
                          ),
                      failure: (e) => CriticalFailure(
                            onRetry: () {
                              ref.read(coinNotifierProvider.notifier).getCoins();
                            },
                          ));
                }),
              ),
            ],
          ),
        ));
  }

  List<Coin> _filterCoins(List<Coin> coins) {
    if (_searchQuery.isEmpty) {
      return coins;
    }
    return coins.where((coin) =>
      coin.name.toLowerCase().contains(_searchQuery) ||
      coin.symbol.toLowerCase().contains(_searchQuery)
    ).toList();
  }

  void _showAddCoinDialog(BuildContext context, WidgetRef ref, Coin coin) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isInPortfolio = coin.amount != null && coin.amount! > 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isInPortfolio ? 'Add more' : 'Add'} ${coin.name} to Portfolio'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              hintText: 'Enter amount of ${coin.symbol}',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid positive amount';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final amount = double.parse(amountController.text);
                if (isInPortfolio) {
                  // Add more to existing holdings
                  final newAmount = coin.amount! + amount;
                  ref.read(coinNotifierProvider.notifier).addCoinToPortfolio(coin.symbol, newAmount);
                } else {
                  // Add new coin to portfolio
                  ref.read(coinNotifierProvider.notifier).addCoinToPortfolio(coin.symbol, amount);
                }
                Navigator.of(context).pop();
              }
            },
            child: Text(isInPortfolio ? 'Add More' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class SuccesContent extends StatelessWidget {
  const SuccesContent({
    Key? key,
    required List<Coin> coins,
    required Function(Coin) onAddCoin,
  })  : _coins = coins,
        _onAddCoin = onAddCoin,
        super(key: key);
  final List<Coin> _coins;
  final Function(Coin) _onAddCoin;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          toolbarHeight: 140.h,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Image.asset(
            'assets/belo.png',
            height: 150.h,
          ),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final coin = _coins[index];
              return CoinItem(
                coin: coin,
                showAddButton: true,
                onAddToPortfolio: () => _onAddCoin(coin),
              );
            }, childCount: _coins.length))
      ],
    );
  }
}
