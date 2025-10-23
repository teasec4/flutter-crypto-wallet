import 'package:dartz/dartz.dart';

import 'portfolio_item.dart';
import 'coin_failure.dart';

/// Repository interface for managing user's cryptocurrency portfolio.
abstract class IPortfolioRepository {
  /// Gets all portfolio items.
  Future<Either<CoinFailure, List<PortfolioItem>>> getPortfolio();

  /// Adds or updates a coin in the portfolio.
  Future<Either<CoinFailure, Unit>> addToPortfolio(PortfolioItem item);

  /// Removes a coin from the portfolio.
  Future<Either<CoinFailure, Unit>> removeFromPortfolio(String symbol);

  /// Updates the amount of a coin in the portfolio.
  Future<Either<CoinFailure, Unit>> updatePortfolioItem(PortfolioItem item);
}
