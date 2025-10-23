import 'package:flutter_crypto_wallet/domain/coin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils.dart';
import 'image_coin.dart';

class CoinItem extends StatelessWidget {
  const CoinItem({
    Key? key,
    required Coin coin,
    bool isPortafolio = false,
    VoidCallback? onTap,
    VoidCallback? onAddToPortfolio,
    bool showAddButton = false,
  })  : _coin = coin,
        _onTap = onTap,
        _isPortafolio = isPortafolio,
        _onAddToPortfolio = onAddToPortfolio,
        _showAddButton = showAddButton,
        super(key: key);

  final Coin _coin;
  final bool _isPortafolio;
  final VoidCallback? _onTap;
  final VoidCallback? _onAddToPortfolio;
  final bool _showAddButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: Colors.grey.shade200,
      ))),
      child: ListTile(
        onTap: _onTap,
        leading: ImageCoin(
          imageUrl: _coin.id,
        ),
        title: Text(
          _coin.name,
          style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w500),
        ),
        subtitle: !_isPortafolio
            ? Text(_coin.symbol, style: TextStyle(fontSize: 28.sp))
            : null,
        trailing: FittedBox(
        fit: BoxFit.scaleDown,
        child: !_isPortafolio
        ? _showAddButton
        ? IconButton(
            icon: Icon(
              _coin.amount != null && _coin.amount! > 0 ? Icons.add_circle : Icons.add,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: _onAddToPortfolio,
        )
        : Column(
        crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Text('\$${_coin.currentPrice}',
                      style: TextStyle(
                      fontSize: 28.sp, fontWeight: FontWeight.w500)),
              _PriceVariation(price: _coin.priceChange),
            ],
        )
        : Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text(Utils.getPrice(_coin.dollars ?? 0.0),
        style: TextStyle(
        fontSize: 28.sp, fontWeight: FontWeight.w500)),
          Text(Utils.getCoinAmount(_coin.amount ?? 0.0, _coin.symbol),
                style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54)),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PriceVariation extends StatelessWidget {
  const _PriceVariation({Key? key, required double price})
      : _price = price,
        super(key: key);
  final double _price;

  @override
  Widget build(BuildContext context) {
    return Text(Utils.getPriceChange(_price),
        textAlign: TextAlign.end,
        style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w500,
            color: _price >= 0 ? Colors.green : Colors.redAccent));
  }
}
