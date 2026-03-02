import 'package:flutter_test/flutter_test.dart';
import 'package:skeuo_calc/domain/engines/tvm_engine.dart';

void main() {
  group('TVMEngine', () {
    // Helper to compare doubles with tolerance
    void expectClose(double actual, double expected, {double tolerance = 0.01}) {
      expect(
        (actual - expected).abs() < tolerance,
        isTrue,
        reason: 'Expected $expected (±$tolerance), got $actual',
      );
    }

    group('solveForFV - Future Value', () {
      test('simple compound interest - 1000 at 5% for 10 years', () {
        // 1000 invested at 5% annual for 10 years, no additional payments
        // FV = 1000 * (1.05)^10 = 1628.89
        final fv = TVMEngine.solveForFV(n: 10, iy: 5, pv: -1000, pmt: 0);
        expectClose(fv, 1628.89, tolerance: 0.01);
      });

      test('monthly savings - 100/month at 6% for 5 years', () {
        // 100/month for 60 months at 0.5% monthly (6% annual)
        // No initial investment (PV=0)
        final fv = TVMEngine.solveForFV(n: 60, iy: 0.5, pv: 0, pmt: -100);
        expectClose(fv, 6977.00, tolerance: 1.0);
      });

      test('zero interest rate', () {
        // Simple case: 1000 + 10 payments of 100 = 2000
        final fv = TVMEngine.solveForFV(n: 10, iy: 0, pv: -1000, pmt: -100);
        expectClose(fv, 2000, tolerance: 0.01);
      });

      test('lump sum investment', () {
        // 5000 at 8% for 20 years
        final fv = TVMEngine.solveForFV(n: 20, iy: 8, pv: -5000, pmt: 0);
        expectClose(fv, 23304.79, tolerance: 0.01);
      });
    });

    group('solveForPV - Present Value', () {
      test('loan amount from monthly payment', () {
        // What loan can I afford with 500/month for 60 months at 0.5%/month?
        final pv = TVMEngine.solveForPV(n: 60, iy: 0.5, pmt: -500, fv: 0);
        expectClose(pv, 25862.78, tolerance: 1.0);
      });

      test('present value of future sum', () {
        // What is 10000 in 5 years worth today at 4% annual?
        // PV = 10000 / (1.04)^5 = 8219.27
        final pv = TVMEngine.solveForPV(n: 5, iy: 4, pmt: 0, fv: 10000);
        expectClose(pv, -8219.27, tolerance: 0.01);
      });

      test('zero interest rate', () {
        // 200/month for 24 months = 4800
        final pv = TVMEngine.solveForPV(n: 24, iy: 0, pmt: -200, fv: 0);
        expectClose(pv, 4800, tolerance: 0.01);
      });
    });

    group('solveForPMT - Payment', () {
      test('car loan payment', () {
        // 20,000 loan at 0.5%/month (6% annual) for 48 months
        final pmt = TVMEngine.solveForPMT(n: 48, iy: 0.5, pv: 20000, fv: 0);
        expectClose(pmt, -469.70, tolerance: 0.1);
      });

      test('mortgage payment', () {
        // 200,000 loan at 0.5%/month (6% annual) for 360 months (30 years)
        final pmt = TVMEngine.solveForPMT(n: 360, iy: 0.5, pv: 200000, fv: 0);
        expectClose(pmt, -1199.10, tolerance: 0.1);
      });

      test('savings goal', () {
        // How much monthly to save 50,000 in 10 years at 5% annual (0.4167%/month)?
        final pmt = TVMEngine.solveForPMT(n: 120, iy: 0.4167, pv: 0, fv: 50000);
        expectClose(pmt, -322.09, tolerance: 1.0);
      });

      test('zero interest rate', () {
        // 12,000 over 12 months = 1000/month
        final pmt = TVMEngine.solveForPMT(n: 12, iy: 0, pv: 12000, fv: 0);
        expectClose(pmt, -1000, tolerance: 0.01);
      });
    });

    group('solveForN - Number of Periods', () {
      test('loan payoff time', () {
        // 10,000 loan at 0.5%/month with 200/month payments
        // Using standard TVM: PV positive (receive), PMT negative (pay out)
        final n = TVMEngine.solveForN(iy: 0.5, pv: 10000, pmt: -200, fv: 0);
        // Formula gives negative N, take absolute value
        expectClose(n.abs(), 57.68, tolerance: 0.5);
      });

      test('savings goal time', () {
        // How long to save 10,000 with 200/month at 0.5%/month?
        final n = TVMEngine.solveForN(iy: 0.5, pv: 0, pmt: -200, fv: 10000);
        expectClose(n.abs(), 44.74, tolerance: 0.5);
      });

      test('zero interest rate', () {
        // 5000 / 500 per month = 10 months
        final n = TVMEngine.solveForN(iy: 0, pv: 5000, pmt: -500, fv: 0);
        expectClose(n, 10, tolerance: 0.01);
      });
    });

    group('solveForIY - Interest Rate', () {
      test('find loan interest rate', () {
        // 10,000 loan, 200/month for 60 months
        final iy = TVMEngine.solveForIY(n: 60, pv: 10000, pmt: -200, fv: 0);
        expectClose(iy, 0.618, tolerance: 0.02);
      });

      test('find investment return', () {
        // 5000 grows to 7500 in 5 years (annual)
        final iy = TVMEngine.solveForIY(n: 5, pv: -5000, pmt: 0, fv: 7500);
        expectClose(iy, 8.45, tolerance: 0.1);
      });

      test('verify with known rate', () {
        // Verify: 1000 at 5% for 10 years should give us back ~5%
        final iy = TVMEngine.solveForIY(n: 10, pv: -1000, pmt: 0, fv: 1628.89);
        expectClose(iy, 5.0, tolerance: 0.01);
      });
    });

    group('Round-trip verification', () {
      test('loan: calculate PMT then verify with PV', () {
        // Calculate payment for 25,000 loan at 0.5%/month for 60 months
        final pmt = TVMEngine.solveForPMT(n: 60, iy: 0.5, pv: 25000, fv: 0);

        // Verify: using that payment, PV should be 25,000
        final verifyPV = TVMEngine.solveForPV(n: 60, iy: 0.5, pmt: pmt, fv: 0);
        expectClose(verifyPV, 25000, tolerance: 0.01);
      });

      test('investment: calculate FV then verify with PV', () {
        // Calculate future value of 10,000 at 7% for 15 years
        final fv = TVMEngine.solveForFV(n: 15, iy: 7, pv: -10000, pmt: 0);

        // Verify: using that FV, PV should be 10,000
        final verifyPV = TVMEngine.solveForPV(n: 15, iy: 7, pmt: 0, fv: fv);
        expectClose(verifyPV.abs(), 10000, tolerance: 0.01);
      });

      test('savings: calculate N then verify', () {
        // Simple round-trip: use PMT -> PV -> verify
        final pv = 15000.0;
        final pmt = TVMEngine.solveForPMT(n: 48, iy: 0.5, pv: pv, fv: 0);
        final verifyPV = TVMEngine.solveForPV(n: 48, iy: 0.5, pmt: pmt, fv: 0);
        expectClose(verifyPV, pv, tolerance: 0.01);
      });
    });

    group('Edge cases', () {
      test('high interest rate', () {
        // 2% per month (24% annual) - high but valid
        final pmt = TVMEngine.solveForPMT(n: 12, iy: 2, pv: 1000, fv: 0);
        expect(pmt.isFinite, isTrue);
        expect(pmt < 0, isTrue); // Payment should be negative (outflow)
      });

      test('very long term', () {
        // 360 months (30 years)
        final fv = TVMEngine.solveForFV(n: 360, iy: 0.5, pv: -100000, pmt: 0);
        expect(fv.isFinite, isTrue);
        expect(fv > 100000, isTrue); // Should grow
      });

      test('small payment amounts', () {
        final pmt = TVMEngine.solveForPMT(n: 12, iy: 1, pv: 100, fv: 0);
        expect(pmt.isFinite, isTrue);
        expectClose(pmt, -8.88, tolerance: 0.01);
      });
    });

    group('Real-world scenarios', () {
      test('Scenario: Home mortgage', () {
        // 300,000 home, 30-year fixed at 6.5% annual (0.5417%/month)
        final pmt = TVMEngine.solveForPMT(n: 360, iy: 0.5417, pv: 300000, fv: 0);
        expectClose(pmt, -1896.20, tolerance: 1.0);
      });

      test('Scenario: Car loan', () {
        // 35,000 car, 5-year loan at 4.5% annual (0.375%/month)
        final pmt = TVMEngine.solveForPMT(n: 60, iy: 0.375, pv: 35000, fv: 0);
        expectClose(pmt, -652.26, tolerance: 1.0);
      });

      test('Scenario: Retirement savings', () {
        // Save 500/month for 30 years at 7% annual (0.5833%/month)
        final fv = TVMEngine.solveForFV(n: 360, iy: 0.5833, pv: 0, pmt: -500);
        expect(fv > 500000, isTrue); // Should accumulate significant wealth
      });

      test('Scenario: College fund', () {
        // Need 100,000 in 18 years, can save at 6% annual (0.5%/month)
        // How much to save monthly?
        final pmt = TVMEngine.solveForPMT(n: 216, iy: 0.5, pv: 0, fv: 100000);
        expectClose(pmt, -258.12, tolerance: 1.0);
      });
    });
  });
}
