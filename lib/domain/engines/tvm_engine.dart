import 'dart:math' as math;

/// Time Value of Money (TVM) calculation engine
///
/// TVM Formula: PV + PMT * ((1 - (1 + i)^-n) / i) + FV * (1 + i)^-n = 0
/// Where i = I/Y / 100 (interest rate as decimal)
///
/// Sign conventions (standard financial calculator convention):
/// - PV: negative = cash outflow (loan/investment), positive = cash inflow
/// - PMT: negative = cash outflow (payment), positive = cash inflow
/// - FV: negative = cash outflow, positive = cash inflow
class TVMEngine {
  /// Solve for N (number of periods)
  ///
  /// Example: How many months to pay off a $10,000 loan at 6% annual with $200/month payments?
  /// n = solveForN(iy: 0.5, pv: 10000, pmt: -200, fv: 0) ≈ 56.08 months
  static double solveForN({
    required double iy,   // Interest rate per period (%)
    required double pv,   // Present Value
    required double pmt,  // Payment per period
    required double fv,   // Future Value
  }) {
    final i = iy / 100;
    if (i == 0) {
      // Simple case: no interest
      if (pmt == 0) throw ArgumentError('PMT cannot be 0 when interest is 0');
      return -(pv + fv) / pmt;
    }
    // n = -ln((pmt - i*fv) / (pmt + i*pv)) / ln(1+i)
    final numerator = pmt - i * fv;
    final denominator = pmt + i * pv;
    if (denominator == 0) throw ArgumentError('Invalid values: division by zero');
    final ratio = numerator / denominator;
    if (ratio <= 0) throw ArgumentError('Invalid values: cannot compute logarithm');
    return -math.log(ratio) / math.log(1 + i);
  }

  /// Solve for I/Y (interest rate per period as percentage)
  /// Uses Newton-Raphson iteration method
  ///
  /// Example: What interest rate for $10,000 loan with $200/month for 60 months?
  /// iy = solveForIY(n: 60, pv: 10000, pmt: -200, fv: 0) ≈ 0.758% per month
  static double solveForIY({
    required double n,    // Number of periods
    required double pv,   // Present Value
    required double pmt,  // Payment per period
    required double fv,   // Future Value
  }) {
    // Newton-Raphson method to solve for interest rate
    double i = 0.1; // Initial guess: 10%
    const maxIterations = 100;
    const tolerance = 1e-10;

    for (int iteration = 0; iteration < maxIterations; iteration++) {
      final f = _tvmEquation(n, i, pv, pmt, fv);
      final fPrime = _tvmDerivative(n, i, pv, pmt, fv);

      if (fPrime.abs() < tolerance) break;

      final newI = i - f / fPrime;

      if ((newI - i).abs() < tolerance) {
        return newI * 100; // Convert to percentage
      }

      i = newI;
    }

    return i * 100;
  }

  /// Solve for PV (Present Value)
  ///
  /// Example: What loan amount can I afford with $500/month for 60 months at 5% annual?
  /// pv = solveForPV(n: 60, iy: 0.4167, pmt: -500, fv: 0) ≈ $26,513
  static double solveForPV({
    required double n,    // Number of periods
    required double iy,   // Interest rate per period (%)
    required double pmt,  // Payment per period
    required double fv,   // Future Value
  }) {
    final i = iy / 100;
    if (i == 0) {
      return -pmt * n - fv;
    }
    final factor = math.pow(1 + i, -n);
    return -pmt * (1 - factor) / i - fv * factor;
  }

  /// Solve for PMT (Payment per period)
  ///
  /// Example: What monthly payment for $20,000 loan at 6% annual for 48 months?
  /// pmt = solveForPMT(n: 48, iy: 0.5, pv: 20000, fv: 0) ≈ -$469.70
  static double solveForPMT({
    required double n,    // Number of periods
    required double iy,   // Interest rate per period (%)
    required double pv,   // Present Value
    required double fv,   // Future Value
  }) {
    final i = iy / 100;
    if (i == 0) {
      if (n == 0) throw ArgumentError('N cannot be 0');
      return -(pv + fv) / n;
    }
    final factor = math.pow(1 + i, -n);
    final denominator = (1 - factor) / i;
    if (denominator == 0) throw ArgumentError('Invalid values');
    return -(pv + fv * factor) / denominator;
  }

  /// Solve for FV (Future Value)
  ///
  /// Example: What will $1,000 invested at 5% annual be worth in 10 years?
  /// fv = solveForFV(n: 10, iy: 5, pv: -1000, pmt: 0) ≈ $1,628.89
  static double solveForFV({
    required double n,    // Number of periods
    required double iy,   // Interest rate per period (%)
    required double pv,   // Present Value
    required double pmt,  // Payment per period
  }) {
    final i = iy / 100;
    if (i == 0) {
      return -pv - pmt * n;
    }
    final factor = math.pow(1 + i, n);
    return -pv * factor - pmt * (factor - 1) / i;
  }

  /// TVM equation: should equal 0 when all values are correct
  static double _tvmEquation(double n, double i, double pv, double pmt, double fv) {
    if (i == 0) {
      return pv + pmt * n + fv;
    }
    final factor = math.pow(1 + i, -n);
    return pv + pmt * (1 - factor) / i + fv * factor;
  }

  /// Derivative of TVM equation with respect to i (for Newton-Raphson)
  static double _tvmDerivative(double n, double i, double pv, double pmt, double fv) {
    if (i.abs() < 1e-10) {
      return pmt * n * (n + 1) / 2 - fv * n;
    }
    final factor = math.pow(1 + i, -n);
    final term1 = pmt * (factor * n / (i * (1 + i)) - (1 - factor) / (i * i));
    final term2 = -fv * n * factor / (1 + i);
    return term1 + term2;
  }
}
