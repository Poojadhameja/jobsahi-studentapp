import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/common/simple_app_bar.dart';
import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../bloc/jobs_state.dart';

class CalendarViewScreen extends StatelessWidget {
  const CalendarViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JobsBloc()..add(const LoadCalendarViewEvent()),
      child: const _CalendarViewScreenView(),
    );
  }
}

class _CalendarViewScreenView extends StatelessWidget {
  const _CalendarViewScreenView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobsBloc, JobsState>(
      builder: (context, state) {
        DateTime selectedDate = DateTime(2025, 7, 25);
        DateTime focusedDate = DateTime(2025, 7, 1);

        if (state is CalendarViewLoaded) {
          selectedDate = state.selectedDate;
          focusedDate = state.focusedDate;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFAFCFF), // Light grey background
          appBar: const SimpleAppBar(
            title: 'Interview Calendar / इंटरव्यू कैलेंडर',
            showBackButton: true,
            backgroundColor: Color(0xFFFAFCFF), // Dark grey background
            titleColor: Color.fromARGB(
              255,
              11,
              83,
              125,
            ), // White text and icons
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Calendar Section
                  _buildCalendarSection(context, selectedDate, focusedDate),
                  const SizedBox(height: 24),

                  // Interview Tip Section
                  _buildInterviewTipSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the calendar section
  Widget _buildCalendarSection(
    BuildContext context,
    DateTime selectedDate,
    DateTime focusedDate,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month and Year Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  final newFocusedDate = DateTime(
                    focusedDate.year,
                    focusedDate.month - 1,
                    1,
                  );
                  context.read<JobsBloc>().add(
                    ChangeCalendarMonthEvent(newFocusedDate: newFocusedDate),
                  );
                },
                icon: const Icon(Icons.chevron_left, color: Color(0xFF64748B)),
              ),
              Text(
                '${_getMonthName(focusedDate.month)} ${focusedDate.year}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B537D),
                ),
              ),
              IconButton(
                onPressed: () {
                  final newFocusedDate = DateTime(
                    focusedDate.year,
                    focusedDate.month + 1,
                    1,
                  );
                  context.read<JobsBloc>().add(
                    ChangeCalendarMonthEvent(newFocusedDate: newFocusedDate),
                  );
                },
                icon: const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Days of Week Header
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map(
                  (day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),

          // Calendar Grid
          _buildCalendarGrid(context, selectedDate, focusedDate),
        ],
      ),
    );
  }

  /// Builds the calendar grid
  Widget _buildCalendarGrid(
    BuildContext context,
    DateTime selectedDate,
    DateTime focusedDate,
  ) {
    final firstDayOfMonth = DateTime(focusedDate.year, focusedDate.month, 1);
    final lastDayOfMonth = DateTime(focusedDate.year, focusedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Calculate the starting day (Sunday = 0, Monday = 1, etc.)
    final startDay = firstWeekday == 7 ? 0 : firstWeekday;

    List<Widget> calendarDays = [];

    // Add empty cells for days before the month starts
    for (int i = 0; i < startDay; i++) {
      calendarDays.add(const Expanded(child: SizedBox()));
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(focusedDate.year, focusedDate.month, day);
      final isSelected =
          date.day == selectedDate.day &&
          date.month == selectedDate.month &&
          date.year == selectedDate.year;
      final isToday =
          date.day == DateTime.now().day &&
          date.month == DateTime.now().month &&
          date.year == DateTime.now().year;

      calendarDays.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<JobsBloc>().add(
                SelectCalendarDateEvent(selectedDate: date),
              );
            },
            child: Container(
              height: 40,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0B537D) // Blue for selected date
                    : isToday
                    ? const Color(0xFFE3F2FD) // Light blue for today
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isToday && !isSelected
                    ? Border.all(color: const Color(0xFF0B537D), width: 1)
                    : null,
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.white : const Color(0xFF0B537D),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Fill remaining cells to complete the grid
    final remainingCells = 42 - calendarDays.length; // 6 rows * 7 days = 42
    for (int i = 0; i < remainingCells; i++) {
      calendarDays.add(const Expanded(child: SizedBox()));
    }

    // Create rows of 7 days each
    List<Widget> rows = [];
    for (int i = 0; i < calendarDays.length; i += 7) {
      rows.add(Row(children: calendarDays.sublist(i, i + 7)));
    }

    return Column(children: rows);
  }

  /// Builds the interview tip section
  Widget _buildInterviewTipSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.successColor, // Green background
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.successColor.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Lightbulb Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Interview Tip Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Interview Tip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'यहाँ क्लिक करें और इंटरव्यू की गहराई से तैयारी के सुझाव प्राप्त करें',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to get month name
  String _getMonthName(int month) {
    const monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month];
  }
}
