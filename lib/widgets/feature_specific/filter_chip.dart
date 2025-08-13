/// Filter Chip Widget

library;

import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';

class FilterChip extends StatelessWidget {
  /// Text to be displayed on the chip
  final String label;
  
  /// Whether the chip is selected (default: false)
  final bool isSelected;
  
  /// Callback function when the chip is tapped
  final VoidCallback? onTap;
  
  /// Background color of the chip
  final Color? backgroundColor;
  
  /// Text color of the chip
  final Color? textColor;
  
  /// Border color of the chip
  final Color? borderColor;

  const FilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: textColor ?? (isSelected ? Colors.white : AppConstants.textPrimaryColor),
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor ?? (isSelected ? AppConstants.primaryColor : AppConstants.cardBackgroundColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: borderColor ?? (isSelected ? AppConstants.primaryColor : AppConstants.primaryColor),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}

/// Horizontal Scrollable Filter Chips Widget
/// A horizontal scrollable list of filter chips
class HorizontalFilterChips extends StatelessWidget {
  /// List of filter options
  final List<String> filterOptions;
  
  /// Currently selected filter index
  final int selectedIndex;
  
  /// Callback function when a filter is selected
  final Function(int) onFilterSelected;
  
  /// Whether to show selection state (default: true)
  final bool showSelection;

  const HorizontalFilterChips({
    super.key,
    required this.filterOptions,
    required this.selectedIndex,
    required this.onFilterSelected,
    this.showSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filterOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(right: AppConstants.smallPadding),
            child: FilterChip(
              label: option,
              isSelected: showSelection && index == selectedIndex,
              onTap: () => onFilterSelected(index),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Filter Section Widget
/// A complete filter section with title and filter chips
class FilterSection extends StatelessWidget {
  /// Title of the filter section
  final String title;
  
  /// List of filter options
  final List<String> filterOptions;
  
  /// Currently selected filter index
  final int selectedIndex;
  
  /// Callback function when a filter is selected
  final Function(int) onFilterSelected;
  
  /// Whether to show the title (default: true)
  final bool showTitle;

  const FilterSection({
    super.key,
    required this.title,
    required this.filterOptions,
    required this.selectedIndex,
    required this.onFilterSelected,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            title,
            style: AppConstants.subheadingStyle,
          ),
          const SizedBox(height: AppConstants.smallPadding),
        ],
        HorizontalFilterChips(
          filterOptions: filterOptions,
          selectedIndex: selectedIndex,
          onFilterSelected: onFilterSelected,
        ),
      ],
    );
  }
}
