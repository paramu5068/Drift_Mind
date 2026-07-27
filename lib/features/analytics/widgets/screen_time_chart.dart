import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScreenTimeChart extends StatefulWidget {
  final List<Duration> weeklyData;
  final Function(int) onDaySelected;
  final int initialSelectedIndex;

  const ScreenTimeChart({
    super.key,
    required this.weeklyData,
    required this.onDaySelected,
    this.initialSelectedIndex = 6, // Default to today
  });

  @override
  State<ScreenTimeChart> createState() => _ScreenTimeChartState();
}

class _ScreenTimeChartState extends State<ScreenTimeChart> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.weeklyData.isEmpty) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));

    final maxMinutes = widget.weeklyData.map((d) => d.inMinutes).reduce((a, b) => a > b ? a : b).toDouble();
    final chartMax = (maxMinutes < 60) ? 60.0 : maxMinutes;
    
    final days = _getLast7Days();
    final selectedDuration = widget.weeklyData[_selectedIndex];
    final selectedDayLabel = _getDayLabel(_selectedIndex);

    return Column(
      children: [
        // Selection Indicator Text
        Column(
          children: [
            Text(
              '${selectedDuration.inHours} hrs, ${selectedDuration.inMinutes % 60} mins',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            Text(
              selectedDayLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // The Chart
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              // Grid Lines
              _buildGridLines(chartMax),
              // Bars
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final minutes = widget.weeklyData[index].inMinutes.toDouble();
                  final heightFactor = (minutes / chartMax).clamp(0.02, 1.0);
                  final isSelected = index == _selectedIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedIndex = index);
                        widget.onDaySelected(index);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 32,
                            height: 150 * heightFactor,
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? Theme.of(context).colorScheme.primaryContainer 
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              border: isSelected 
                                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                                : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            days[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Date Selector Bottom
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _selectedIndex > 0 ? () {
                setState(() => _selectedIndex--);
                widget.onDaySelected(_selectedIndex);
              } : null,
            ),
            Text(
              DateFormat('EEE, d MMM').format(DateTime.now().subtract(Duration(days: 6 - _selectedIndex))),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _selectedIndex < 6 ? () {
                setState(() => _selectedIndex++);
                widget.onDaySelected(_selectedIndex);
              } : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridLines(double max) {
    final steps = [max, max * 0.8, max * 0.6, max * 0.4, max * 0.2, 0.0];
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: steps.map((s) => Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.1), height: 1)),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '${(s / 60).toInt()}h',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      )).toList(),
    );
  }

  List<String> _getLast7Days() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DateFormat('E').format(date);
    });
  }

  String _getDayLabel(int index) {
    if (index == 6) return 'Today';
    if (index == 5) return 'Yesterday';
    return DateFormat('EEEE').format(DateTime.now().subtract(Duration(days: 6 - index)));
  }
}
