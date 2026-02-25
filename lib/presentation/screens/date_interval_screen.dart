import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/enums/neumorphic_style.dart';
import '../../theme/typography.dart';
import '../providers/theme_provider.dart';
import '../widgets/common/neumorphic_container.dart';
import '../widgets/common/neumorphic_button.dart';
import '../../core/enums/button_type.dart';

/// Types of date calculations
enum DateMode {
  daysUntil, // Days until a specific date
  ageCalculator, // Calculate age from birthday
  timeZone, // Time zone offset calculator
}

extension DateModeExtension on DateMode {
  String get displayName {
    switch (this) {
      case DateMode.daysUntil:
        return 'Days Until';
      case DateMode.ageCalculator:
        return 'Age Calculator';
      case DateMode.timeZone:
        return 'Time Zones';
    }
  }

  String get description {
    switch (this) {
      case DateMode.daysUntil:
        return 'How many days until a date?';
      case DateMode.ageCalculator:
        return 'Calculate age from birthday';
      case DateMode.timeZone:
        return 'Compare times across time zones';
    }
  }
}

/// Date interval calculator screen
class DateIntervalScreen extends StatefulWidget {
  const DateIntervalScreen({super.key});

  @override
  State<DateIntervalScreen> createState() => _DateIntervalScreenState();
}

/// Common time zones with their UTC offsets in hours
class TimeZoneInfo {
  final String name;
  final String abbreviation;
  final double offsetHours;

  const TimeZoneInfo(this.name, this.abbreviation, this.offsetHours);
}

const List<TimeZoneInfo> _timeZones = [
  TimeZoneInfo('UTC', 'UTC', 0),
  TimeZoneInfo('London', 'GMT', 0),
  TimeZoneInfo('Paris', 'CET', 1),
  TimeZoneInfo('Berlin', 'CET', 1),
  TimeZoneInfo('Rome', 'CET', 1),
  TimeZoneInfo('Moscow', 'MSK', 3),
  TimeZoneInfo('Dubai', 'GST', 4),
  TimeZoneInfo('Mumbai', 'IST', 5.5),
  TimeZoneInfo('Bangkok', 'ICT', 7),
  TimeZoneInfo('Singapore', 'SGT', 8),
  TimeZoneInfo('Hong Kong', 'HKT', 8),
  TimeZoneInfo('Tokyo', 'JST', 9),
  TimeZoneInfo('Sydney', 'AEST', 10),
  TimeZoneInfo('Auckland', 'NZST', 12),
  TimeZoneInfo('New York', 'EST', -5),
  TimeZoneInfo('Chicago', 'CST', -6),
  TimeZoneInfo('Denver', 'MST', -7),
  TimeZoneInfo('Los Angeles', 'PST', -8),
  TimeZoneInfo('Anchorage', 'AKST', -9),
  TimeZoneInfo('Honolulu', 'HST', -10),
  TimeZoneInfo('São Paulo', 'BRT', -3),
];

class _DateIntervalScreenState extends State<DateIntervalScreen> {
  DateMode _mode = DateMode.daysUntil;

  // Date components for target date
  String _day = '';
  String _month = '';
  String _year = '';

  // Which field is being edited: 0=day, 1=month, 2=year
  int _activeField = 0;

  // Time zone mode state
  int _fromZoneIndex = 0; // UTC
  int _toZoneIndex = 14; // New York
  String _hours = '';
  String _minutes = '';
  int _activeTimeField = 0; // 0=hours, 1=minutes

  DateTime? get _targetDate {
    final day = int.tryParse(_day);
    final month = int.tryParse(_month);
    final year = int.tryParse(_year);

    if (day == null || month == null || year == null) return null;
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > _daysInMonth(month, year)) return null;
    if (year < 1900 || year > 2200) return null;

    return DateTime(year, month, day);
  }

  int _daysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  String get _currentFieldValue {
    switch (_activeField) {
      case 0:
        return _day;
      case 1:
        return _month;
      case 2:
        return _year;
      default:
        return '';
    }
  }

  int get _maxFieldLength {
    switch (_activeField) {
      case 0:
      case 1:
        return 2;
      case 2:
        return 4;
      default:
        return 2;
    }
  }

  void _inputDigit(String digit) {
    setState(() {
      String currentValue = _currentFieldValue;
      if (currentValue.length < _maxFieldLength) {
        currentValue += digit;
        _setCurrentFieldValue(currentValue);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _setCurrentFieldValue(String value) {
    switch (_activeField) {
      case 0:
        _day = value;
      case 1:
        _month = value;
      case 2:
        _year = value;
    }
  }

  void _backspace() {
    setState(() {
      String currentValue = _currentFieldValue;
      if (currentValue.isNotEmpty) {
        currentValue = currentValue.substring(0, currentValue.length - 1);
        _setCurrentFieldValue(currentValue);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _clearAll() {
    setState(() {
      _day = '';
      _month = '';
      _year = '';
      _activeField = 0;
    });
    HapticFeedback.mediumImpact();
  }

  void _nextField() {
    setState(() {
      _activeField = (_activeField + 1) % 3;
    });
    HapticFeedback.selectionClick();
  }

  void _setToday() {
    final now = DateTime.now();
    setState(() {
      _day = now.day.toString().padLeft(2, '0');
      _month = now.month.toString().padLeft(2, '0');
      _year = now.year.toString();
    });
    HapticFeedback.mediumImpact();
  }

  // Time zone helpers
  void _inputTimeDigit(String digit) {
    setState(() {
      if (_activeTimeField == 0) {
        // Hours (max 2 digits, 0-23)
        if (_hours.length < 2) {
          final newVal = _hours + digit;
          final intVal = int.tryParse(newVal) ?? 0;
          if (intVal <= 23) {
            _hours = newVal;
          }
        }
      } else {
        // Minutes (max 2 digits, 0-59)
        if (_minutes.length < 2) {
          final newVal = _minutes + digit;
          final intVal = int.tryParse(newVal) ?? 0;
          if (intVal <= 59) {
            _minutes = newVal;
          }
        }
      }
    });
    HapticFeedback.lightImpact();
  }

  void _backspaceTime() {
    setState(() {
      if (_activeTimeField == 0) {
        if (_hours.isNotEmpty) {
          _hours = _hours.substring(0, _hours.length - 1);
        }
      } else {
        if (_minutes.isNotEmpty) {
          _minutes = _minutes.substring(0, _minutes.length - 1);
        }
      }
    });
    HapticFeedback.lightImpact();
  }

  void _clearTime() {
    setState(() {
      _hours = '';
      _minutes = '';
      _activeTimeField = 0;
    });
    HapticFeedback.mediumImpact();
  }

  void _setCurrentTime() {
    final now = DateTime.now();
    setState(() {
      _hours = now.hour.toString().padLeft(2, '0');
      _minutes = now.minute.toString().padLeft(2, '0');
    });
    HapticFeedback.mediumImpact();
  }

  void _swapTimeZones() {
    setState(() {
      final temp = _fromZoneIndex;
      _fromZoneIndex = _toZoneIndex;
      _toZoneIndex = temp;
    });
    HapticFeedback.mediumImpact();
  }

  Map<String, dynamic> get _timeZoneResult {
    final h = int.tryParse(_hours);
    final m = int.tryParse(_minutes) ?? 0;

    if (h == null || _hours.isEmpty) {
      return {'valid': false};
    }

    final fromZone = _timeZones[_fromZoneIndex];
    final toZone = _timeZones[_toZoneIndex];

    // Calculate offset difference
    final offsetDiff = toZone.offsetHours - fromZone.offsetHours;

    // Convert to total minutes for easier calculation
    final totalMinutesFrom = h * 60 + m;
    final offsetMinutes = (offsetDiff * 60).round();
    var totalMinutesTo = totalMinutesFrom + offsetMinutes;

    // Handle day boundary
    int dayChange = 0;
    if (totalMinutesTo >= 1440) {
      dayChange = 1;
      totalMinutesTo -= 1440;
    } else if (totalMinutesTo < 0) {
      dayChange = -1;
      totalMinutesTo += 1440;
    }

    final toHours = totalMinutesTo ~/ 60;
    final toMinutes = totalMinutesTo % 60;

    return {
      'valid': true,
      'fromHours': h,
      'fromMinutes': m,
      'toHours': toHours,
      'toMinutes': toMinutes,
      'dayChange': dayChange,
      'offsetDiff': offsetDiff,
    };
  }

  // Calculate result based on mode
  Map<String, dynamic> get _result {
    final target = _targetDate;
    if (target == null) {
      return {'valid': false};
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(target.year, target.month, target.day);

    switch (_mode) {
      case DateMode.daysUntil:
        final difference = targetDay.difference(today).inDays;
        return {
          'valid': true,
          'days': difference.abs(),
          'isPast': difference < 0,
          'isToday': difference == 0,
        };

      case DateMode.ageCalculator:
        if (targetDay.isAfter(today)) {
          return {'valid': false, 'error': 'Birthday cannot be in the future'};
        }

        int years = today.year - targetDay.year;
        int months = today.month - targetDay.month;
        int days = today.day - targetDay.day;

        if (days < 0) {
          months--;
          days += _daysInMonth(today.month - 1 == 0 ? 12 : today.month - 1,
                               today.month - 1 == 0 ? today.year - 1 : today.year);
        }

        if (months < 0) {
          years--;
          months += 12;
        }

        // Calculate total days lived
        final totalDays = today.difference(targetDay).inDays;

        // Calculate next birthday
        DateTime nextBirthday = DateTime(today.year, targetDay.month, targetDay.day);
        if (nextBirthday.isBefore(today) || nextBirthday.isAtSameMomentAs(today)) {
          nextBirthday = DateTime(today.year + 1, targetDay.month, targetDay.day);
        }
        final daysUntilBirthday = nextBirthday.difference(today).inDays;

        return {
          'valid': true,
          'years': years,
          'months': months,
          'days': days,
          'totalDays': totalDays,
          'daysUntilBirthday': daysUntilBirthday,
        };

      case DateMode.timeZone:
        // Time zone mode uses _timeZoneResult instead
        return {'valid': false};
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return Container(
      color: theme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Mode selector
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: DateMode.values.length,
              itemBuilder: (context, index) {
                final mode = DateMode.values[index];
                final isSelected = mode == _mode;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _mode = mode;
                        _clearAll();
                      });
                      HapticFeedback.selectionClick();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.accentColor.withAlpha(30)
                            : theme.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? theme.accentColor
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          mode.displayName,
                          style: AppTypography.label(
                            isSelected ? theme.accentColor : theme.textSecondary,
                          ).copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            _mode.description,
            style: AppTypography.label(theme.textSecondary),
          ),

          const SizedBox(height: 16),

          // Content area - different for time zone mode
          if (_mode == DateMode.timeZone) ...[
            // Time zone specific UI
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // Time zone selectors with swap button
                  _buildTimeZoneSelectors(theme),

                  const SizedBox(height: 8),

                  // Time input
                  _TimeInputRow(
                    hours: _hours,
                    minutes: _minutes,
                    activeField: _activeTimeField,
                    onFieldTap: (index) {
                      setState(() => _activeTimeField = index);
                      HapticFeedback.selectionClick();
                    },
                  ),

                  const SizedBox(height: 8),

                  // Result display
                  Expanded(
                    child: _buildTimeZoneResultDisplay(theme),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Keypad for time zone
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _buildTimeKeypadRow(['7', '8', '9', 'AC']),
                  _buildTimeKeypadRow(['4', '5', '6', '⌫']),
                  _buildTimeKeypadRow(['1', '2', '3', '⇄']),
                  _buildTimeKeypadRow(['NOW', '0', '', '']),
                ],
              ),
            ),
          ] else ...[
            // Date input section (original)
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // Date label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _mode == DateMode.daysUntil ? 'Target Date' : 'Birthday',
                      style: AppTypography.label(theme.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date input fields
                  _DateInputRow(
                    day: _day,
                    month: _month,
                    year: _year,
                    activeField: _activeField,
                    onFieldTap: (index) {
                      setState(() => _activeField = index);
                      HapticFeedback.selectionClick();
                    },
                  ),

                  const SizedBox(height: 16),

                  // Result display
                  Expanded(
                    child: _buildResultDisplay(theme),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Keypad
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _buildKeypadRow(['7', '8', '9', 'AC']),
                  _buildKeypadRow(['4', '5', '6', '⌫']),
                  _buildKeypadRow(['1', '2', '3', '→']),
                  _buildKeypadRow(['TODAY', '0', '', '']),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultDisplay(dynamic theme) {
    final result = _result;

    // Always use the same container structure to keep size fixed
    return NeumorphicContainer(
      style: result['valid'] == true ? NeumorphicStyle.convex : NeumorphicStyle.concave,
      borderRadius: 16,
      color: theme.displayBackground,
      padding: const EdgeInsets.all(12),
      child: _buildResultContent(theme, result),
    );
  }

  Widget _buildResultContent(dynamic theme, Map<String, dynamic> result) {
    if (!result['valid']) {
      final error = result['error'] as String?;
      return Center(
        child: Text(
          error ?? 'Enter a valid date',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 16,
            color: theme.displayTextDim,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_mode == DateMode.daysUntil) {
      final days = result['days'] as int;
      final isPast = result['isPast'] as bool;
      final isToday = result['isToday'] as bool;

      String message;
      if (isToday) {
        message = "That's today!";
      } else if (isPast) {
        message = '$days days ago';
      } else {
        message = '$days days from now';
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isToday ? '0' : days.toString(),
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 48,
                fontWeight: FontWeight.w500,
                color: theme.displayText,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: theme.displayTextDim,
              ),
            ),
          ],
        ),
      );
    } else {
      // Age calculator result
      final years = result['years'] as int;
      final months = result['months'] as int;
      final days = result['days'] as int;
      final totalDays = result['totalDays'] as int;
      final daysUntilBirthday = result['daysUntilBirthday'] as int;

      return Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main age display
              Text(
                '$years years, $months mo, $days d',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: theme.displayText,
                ),
              ),

              const SizedBox(height: 6),

              // Additional info row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_formatNumber(totalDays)} days lived',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                      color: theme.displayTextDim,
                    ),
                  ),
                  Text(
                    '  •  ',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.displayTextDim,
                    ),
                  ),
                  Text(
                    '$daysUntilBirthday days to birthday',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                      color: theme.displayTextDim,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  Widget _buildTimeZoneSelectors(dynamic theme) {
    final fromZone = _timeZones[_fromZoneIndex];
    final toZone = _timeZones[_toZoneIndex];

    return Row(
      children: [
        // From zone
        Expanded(
          child: _TimeZoneSelector(
            label: 'From',
            zone: fromZone,
            onTap: () => _showTimeZonePicker(true),
          ),
        ),

        // Swap button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: _swapTimeZones,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                shape: BoxShape.circle,
                boxShadow: theme.convexShadows,
              ),
              child: Icon(
                Icons.swap_horiz,
                color: theme.accentColor,
                size: 20,
              ),
            ),
          ),
        ),

        // To zone
        Expanded(
          child: _TimeZoneSelector(
            label: 'To',
            zone: toZone,
            onTap: () => _showTimeZonePicker(false),
          ),
        ),
      ],
    );
  }

  void _showTimeZonePicker(bool isFrom) {
    final theme = context.read<ThemeProvider>().neumorphicTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isFrom ? 'From Time Zone' : 'To Time Zone',
              style: AppTypography.settingsTitle(theme.textPrimary),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _timeZones.length,
                itemBuilder: (context, index) {
                  final zone = _timeZones[index];
                  final isSelected = isFrom
                      ? index == _fromZoneIndex
                      : index == _toZoneIndex;

                  final offsetStr = zone.offsetHours >= 0
                      ? '+${zone.offsetHours.toStringAsFixed(zone.offsetHours == zone.offsetHours.truncate() ? 0 : 1)}'
                      : zone.offsetHours.toStringAsFixed(zone.offsetHours == zone.offsetHours.truncate() ? 0 : 1);

                  return ListTile(
                    title: Text(
                      zone.name,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? theme.accentColor : theme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${zone.abbreviation} (UTC$offsetStr)',
                      style: TextStyle(color: theme.textSecondary),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: theme.accentColor)
                        : null,
                    onTap: () {
                      setState(() {
                        if (isFrom) {
                          _fromZoneIndex = index;
                        } else {
                          _toZoneIndex = index;
                        }
                      });
                      Navigator.pop(context);
                      HapticFeedback.selectionClick();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeZoneResultDisplay(dynamic theme) {
    final result = _timeZoneResult;

    return NeumorphicContainer(
      style: result['valid'] == true ? NeumorphicStyle.convex : NeumorphicStyle.concave,
      borderRadius: 16,
      color: theme.displayBackground,
      padding: const EdgeInsets.all(12),
      child: _buildTimeZoneResultContent(theme, result),
    );
  }

  Widget _buildTimeZoneResultContent(dynamic theme, Map<String, dynamic> result) {
    if (!result['valid']) {
      return Center(
        child: Text(
          '--:--',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 36,
            fontWeight: FontWeight.w500,
            color: theme.displayTextDim,
          ),
        ),
      );
    }

    final toHours = result['toHours'] as int;
    final toMinutes = result['toMinutes'] as int;
    final dayChange = result['dayChange'] as int;

    String dayIndicator = '';
    if (dayChange == 1) {
      dayIndicator = ' +1';
    } else if (dayChange == -1) {
      dayIndicator = ' -1';
    }

    return Center(
      child: Text(
        '${toHours.toString().padLeft(2, '0')}:${toMinutes.toString().padLeft(2, '0')}$dayIndicator',
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 36,
          fontWeight: FontWeight.w500,
          color: theme.displayText,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildTimeKeypadRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((key) {
          if (key.isEmpty) {
            return const Expanded(child: SizedBox());
          }

          final isWide = key == 'NOW';

          return Expanded(
            flex: isWide ? 2 : 1,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: NeumorphicButton(
                label: key,
                buttonType: key == 'AC' || key == '⌫' || key == '⇄' || key == 'NOW'
                    ? ButtonType.function
                    : ButtonType.number,
                onPressed: () {
                  switch (key) {
                    case 'AC':
                      _clearTime();
                    case '⌫':
                      _backspaceTime();
                    case '⇄':
                      _swapTimeZones();
                    case 'NOW':
                      _setCurrentTime();
                    default:
                      _inputTimeDigit(key);
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((key) {
          if (key.isEmpty) {
            return const Expanded(child: SizedBox());
          }

          final isWide = key == 'TODAY';

          return Expanded(
            flex: isWide ? 2 : 1,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: NeumorphicButton(
                label: key,
                buttonType: key == 'AC' || key == '⌫' || key == '→' || key == 'TODAY'
                    ? ButtonType.function
                    : ButtonType.number,
                onPressed: () {
                  switch (key) {
                    case 'AC':
                      _clearAll();
                    case '⌫':
                      _backspace();
                    case '→':
                      _nextField();
                    case 'TODAY':
                      _setToday();
                    default:
                      _inputDigit(key);
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DateInputRow extends StatelessWidget {
  final String day;
  final String month;
  final String year;
  final int activeField;
  final Function(int) onFieldTap;

  const _DateInputRow({
    required this.day,
    required this.month,
    required this.year,
    required this.activeField,
    required this.onFieldTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return Row(
      children: [
        // Day
        Expanded(
          child: _DateField(
            label: 'DD',
            value: day,
            isActive: activeField == 0,
            onTap: () => onFieldTap(0),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '/',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: theme.textSecondary,
            ),
          ),
        ),

        // Month
        Expanded(
          child: _DateField(
            label: 'MM',
            value: month,
            isActive: activeField == 1,
            onTap: () => onFieldTap(1),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '/',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: theme.textSecondary,
            ),
          ),
        ),

        // Year
        Expanded(
          flex: 2,
          child: _DateField(
            label: 'YYYY',
            value: year,
            isActive: activeField == 2,
            onTap: () => onFieldTap(2),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final bool isActive;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        style: isActive ? NeumorphicStyle.concave : NeumorphicStyle.flat,
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.isEmpty ? label : value,
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: value.isEmpty
                    ? theme.textSecondary.withAlpha(100)
                    : (isActive ? theme.accentColor : theme.textPrimary),
                letterSpacing: 2,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 20,
                height: 2,
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimeZoneSelector extends StatelessWidget {
  final String label;
  final TimeZoneInfo zone;
  final VoidCallback onTap;

  const _TimeZoneSelector({
    required this.label,
    required this.zone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        style: NeumorphicStyle.flat,
        borderRadius: 10,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      color: theme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    zone.abbreviation,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: theme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeInputRow extends StatelessWidget {
  final String hours;
  final String minutes;
  final int activeField;
  final Function(int) onFieldTap;

  const _TimeInputRow({
    required this.hours,
    required this.minutes,
    required this.activeField,
    required this.onFieldTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hours
        Expanded(
          child: _TimeField(
            label: 'HH',
            value: hours,
            isActive: activeField == 0,
            onTap: () => onFieldTap(0),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            ':',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: theme.textSecondary,
            ),
          ),
        ),

        // Minutes
        Expanded(
          child: _TimeField(
            label: 'MM',
            value: minutes,
            isActive: activeField == 1,
            onTap: () => onFieldTap(1),
          ),
        ),
      ],
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final bool isActive;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.value,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        style: isActive ? NeumorphicStyle.concave : NeumorphicStyle.flat,
        borderRadius: 10,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.isEmpty ? label : value.padLeft(2, '0'),
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: value.isEmpty
                    ? theme.textSecondary.withAlpha(100)
                    : (isActive ? theme.accentColor : theme.textPrimary),
                letterSpacing: 2,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 16,
                height: 2,
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
