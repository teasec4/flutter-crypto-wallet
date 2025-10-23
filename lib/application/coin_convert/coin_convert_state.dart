import 'package:dartz/dartz.dart';
import '../../domain/coin.dart';
import '../../domain/coin_failure.dart';
import '../../presentation/core/models/confirm_model.dart';

/// Represents validation errors for coin conversion amounts.
/// Uses sealed classes for exhaustive pattern matching.
sealed class ValidationError {
  const ValidationError();

  /// Pattern matching method for handling different validation errors.
  T map<T>({
    required T Function(Empty) empty,
    required T Function(Invalid) invalid,
  }) {
    return switch (this) {
      Empty() => empty(this as Empty),
      Invalid() => invalid(this as Invalid),
    };
  }
}

/// Error when the amount is empty or zero.
final class Empty extends ValidationError {
  const Empty();
}

/// Error when the amount exceeds available balance.
final class Invalid extends ValidationError {
  const Invalid();
}

/// State for the coin conversion feature.
/// Manages selected coins, amounts, validation, and conversion results.
class CoinConvertState {
  const CoinConvertState({
    this.from,
    this.to,
    this.all,
    this.portafolio,
    this.confirm,
    required this.amount,
    required this.isLoading,
    required this.isPreview,
    required this.validation,
    required this.convertFailureOrSuccessOption,
  });

  final Coin? from;
  final Coin? to;
  final List<Coin>? all;
  final List<Coin>? portafolio;
  final ConfirmModel? confirm;
  final String amount;
  final bool isLoading;
  final bool isPreview;
  final Option<ValidationError> validation;
  final Option<Either<CoinFailure, Unit>> convertFailureOrSuccessOption;

  factory CoinConvertState.initial() => const CoinConvertState(
        isLoading: true,
        amount: '0',
        isPreview: false,
        validation: None(),
        convertFailureOrSuccessOption: None(),
      );

  CoinConvertState copyWith({
    Coin? from,
    Coin? to,
    List<Coin>? all,
    List<Coin>? portafolio,
    ConfirmModel? confirm,
    String? amount,
    bool? isLoading,
    bool? isPreview,
    Option<ValidationError>? validation,
    Option<Either<CoinFailure, Unit>>? convertFailureOrSuccessOption,
  }) {
    return CoinConvertState(
      from: from ?? this.from,
      to: to ?? this.to,
      all: all ?? this.all,
      portafolio: portafolio ?? this.portafolio,
      confirm: confirm ?? this.confirm,
      amount: amount ?? this.amount,
      isLoading: isLoading ?? this.isLoading,
      isPreview: isPreview ?? this.isPreview,
      validation: validation ?? this.validation,
      convertFailureOrSuccessOption:
          convertFailureOrSuccessOption ?? this.convertFailureOrSuccessOption,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CoinConvertState &&
      from == other.from &&
      to == other.to &&
      all == other.all &&
      portafolio == other.portafolio &&
      confirm == other.confirm &&
      amount == other.amount &&
      isLoading == other.isLoading &&
      isPreview == other.isPreview &&
      validation == other.validation &&
      convertFailureOrSuccessOption == other.convertFailureOrSuccessOption;

  @override
  int get hashCode => Object.hash(from, to, all, portafolio, confirm, amount,
      isLoading, isPreview, validation, convertFailureOrSuccessOption);

  @override
  String toString() =>
      'CoinConvertState(from: $from, to: $to, all: $all, portafolio: $portafolio, confirm: $confirm, amount: $amount, isLoading: $isLoading, isPreview: $isPreview, validation: $validation, convertFailureOrSuccessOption: $convertFailureOrSuccessOption)';
}
