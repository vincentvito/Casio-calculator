import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feedback_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/common/neumorphic_toggle.dart';
import '../widgets/mode_switcher/calculator_type_toggle.dart';
import '../widgets/surfaces/metallic_body.dart';
import '../../theme/typography.dart';
import 'basic_calculator_screen.dart';
import 'scientific_calculator_screen.dart';
import 'currency_converter_screen.dart';
import 'unit_converter_screen.dart';
import 'tvm_solver_screen.dart';
import 'percentage_calculator_screen.dart';
import 'date_interval_screen.dart';
import 'theme_picker_screen.dart';

enum ScreenMode { calculator, currency, units, tvm, percentage, dateInterval }

/// Main screen container with mode switching
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSettings = false;
  bool _isScientific = false;
  ScreenMode _screenMode = ScreenMode.calculator;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: MetallicBody(
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Column(
              children: [
                const SizedBox(height: 8),

                // Calculator type toggle (Basic/Scientific) - only show for calculator mode
                if (_screenMode == ScreenMode.calculator)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: CalculatorTypeToggle(
                            isScientific: _isScientific,
                            onChanged: (value) {
                              setState(() {
                                _isScientific = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 48), // Space for settings button
                      ],
                    ),
                  ),

                // Title for converter screens
                if (_screenMode != ScreenMode.calculator)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 64, 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.read<FeedbackProvider>().lightTap();
                            setState(() => _screenMode = ScreenMode.calculator);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: theme.textSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getScreenTitle(),
                          style: AppTypography.settingsTitle(theme.textPrimary),
                        ),
                      ],
                    ),
                  ),

                // Main screen area
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _buildCurrentScreen(),
                  ),
                ),
              ],
            ),

            // Settings button (top right)
            Positioned(
              top: 12,
              right: 16,
              child: GestureDetector(
                onTap: () => setState(() => _showSettings = !_showSettings),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.surfaceColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowDark.withAlpha(100),
                        offset: const Offset(2, 2),
                        blurRadius: 6,
                      ),
                      BoxShadow(
                        color: theme.shadowLight.withAlpha(120),
                        offset: const Offset(-1, -1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    _showSettings ? Icons.close : Icons.settings,
                    color: theme.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ),

            // Settings overlay
            if (_showSettings)
              Positioned(
                top: 56,
                right: 16,
                child: _SettingsPanel(
                  onClose: () => setState(() => _showSettings = false),
                  onCurrencyTap: () {
                    setState(() {
                      _screenMode = ScreenMode.currency;
                      _showSettings = false;
                    });
                  },
                  onUnitsTap: () {
                    setState(() {
                      _screenMode = ScreenMode.units;
                      _showSettings = false;
                    });
                  },
                  onTVMTap: () {
                    setState(() {
                      _screenMode = ScreenMode.tvm;
                      _showSettings = false;
                    });
                  },
                  onPercentageTap: () {
                    setState(() {
                      _screenMode = ScreenMode.percentage;
                      _showSettings = false;
                    });
                  },
                  onDateIntervalTap: () {
                    setState(() {
                      _screenMode = ScreenMode.dateInterval;
                      _showSettings = false;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getScreenTitle() {
    switch (_screenMode) {
      case ScreenMode.calculator:
        return '';
      case ScreenMode.currency:
        return 'Currency Exchange';
      case ScreenMode.units:
        return 'Unit Converter';
      case ScreenMode.tvm:
        return 'TVM Solver';
      case ScreenMode.percentage:
        return 'Percentage';
      case ScreenMode.dateInterval:
        return 'Date Interval';
    }
  }

  Widget _buildCurrentScreen() {
    switch (_screenMode) {
      case ScreenMode.calculator:
        return _isScientific
            ? const ScientificCalculatorScreen(key: ValueKey('scientific'))
            : const BasicCalculatorScreen(key: ValueKey('basic'));
      case ScreenMode.currency:
        return const CurrencyConverterScreen(key: ValueKey('currency'));
      case ScreenMode.units:
        return const UnitConverterScreen(key: ValueKey('units'));
      case ScreenMode.tvm:
        return const TVMSolverScreen(key: ValueKey('tvm'));
      case ScreenMode.percentage:
        return const PercentageCalculatorScreen(key: ValueKey('percentage'));
      case ScreenMode.dateInterval:
        return const DateIntervalScreen(key: ValueKey('dateInterval'));
    }
  }
}

class _SettingsPanel extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onCurrencyTap;
  final VoidCallback onUnitsTap;
  final VoidCallback onTVMTap;
  final VoidCallback onPercentageTap;
  final VoidCallback onDateIntervalTap;

  const _SettingsPanel({
    required this.onClose,
    required this.onCurrencyTap,
    required this.onUnitsTap,
    required this.onTVMTap,
    required this.onPercentageTap,
    required this.onDateIntervalTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;
    final settings = context.watch<SettingsProvider>();

    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowDark.withAlpha(128),
            offset: const Offset(4, 4),
            blurRadius: 16,
          ),
          BoxShadow(
            color: theme.shadowLight.withAlpha(128),
            offset: const Offset(-2, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SETTINGS',
            style: AppTypography.modeIndicator(theme.textSecondary),
          ),
          const SizedBox(height: 16),

          // Dark mode toggle
          _SettingsRow(
            label: 'Dark Mode',
            child: NeumorphicToggle(
              value: settings.isDarkMode,
              onChanged: (value) {
                settings.updateIsDarkMode(value);
              },
            ),
          ),

          const SizedBox(height: 12),

          // Sound toggle
          _SettingsRow(
            label: 'Sound',
            child: NeumorphicToggle(
              value: settings.soundEnabled,
              onChanged: (value) {
                settings.updateSoundEnabled(value);
              },
            ),
          ),

          const SizedBox(height: 12),

          // Haptic toggle
          _SettingsRow(
            label: 'Haptics',
            child: NeumorphicToggle(
              value: settings.hapticEnabled,
              onChanged: (value) {
                settings.updateHapticEnabled(value);
              },
            ),
          ),

          const SizedBox(height: 20),

          // Themes section
          Text(
            'THEMES',
            style: AppTypography.modeIndicator(theme.textSecondary),
          ),
          const SizedBox(height: 12),

          _ToolButton(
            icon: Icons.palette_outlined,
            label: 'Themes',
            onTap: () {
              onClose();
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const ThemePickerScreen()),
              );
            },
          ),

          const SizedBox(height: 20),

          // Tools section
          Text(
            'TOOLS',
            style: AppTypography.modeIndicator(theme.textSecondary),
          ),
          const SizedBox(height: 12),

          // Currency Exchange button
          _ToolButton(
            icon: Icons.currency_exchange,
            label: 'Currency Exchange',
            onTap: onCurrencyTap,
          ),

          const SizedBox(height: 8),

          // Unit Converter button
          _ToolButton(
            icon: Icons.straighten,
            label: 'Unit Converter',
            onTap: onUnitsTap,
          ),

          const SizedBox(height: 8),

          // TVM Solver button
          _ToolButton(
            icon: Icons.account_balance,
            label: 'TVM Solver',
            onTap: onTVMTap,
          ),

          const SizedBox(height: 8),

          // Percentage button
          _ToolButton(
            icon: Icons.percent,
            label: 'Percentage',
            onTap: onPercentageTap,
          ),

          const SizedBox(height: 8),

          // Date Interval button
          _ToolButton(
            icon: Icons.calendar_today,
            label: 'Date Interval',
            onTap: onDateIntervalTap,
          ),

          const SizedBox(height: 20),

          // History section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HISTORY',
                style: AppTypography.modeIndicator(theme.textSecondary),
              ),
              Consumer<HistoryProvider>(
                builder: (context, history, _) {
                  if (history.isEmpty) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: () {
                      context.read<FeedbackProvider>().lightTap();
                      history.clearHistory();
                    },
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // History list
          Consumer<HistoryProvider>(
            builder: (context, history, _) {
              if (history.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No calculations yet',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              }

              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 150),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: history.count > 5 ? 5 : history.count,
                  itemBuilder: (context, index) {
                    final entry = history.history[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(
                        '${entry.expression} ${entry.result}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textPrimary,
                          fontFamily: 'JetBrains Mono',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return GestureDetector(
      onTap: () {
        context.read<FeedbackProvider>().lightTap();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.accentColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.label(theme.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _SettingsRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.settingsTitle(theme.textPrimary),
        ),
        child,
      ],
    );
  }
}
