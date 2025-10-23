sealed class CoinFailure {
  const CoinFailure();

  T maybeMap<T>({
    required T Function() orElse,
    T Function(Unexpected)? unexpected,
    T Function(TimeLimitExceeded)? timeLimitExceeded,
  }) {
    return switch (this) {
      Unexpected() => unexpected?.call(this as Unexpected) ?? orElse(),
      TimeLimitExceeded() => timeLimitExceeded?.call(this as TimeLimitExceeded) ?? orElse(),
    };
  }
}

final class Unexpected extends CoinFailure {
  const Unexpected();
}

final class TimeLimitExceeded extends CoinFailure {
  const TimeLimitExceeded();
}
