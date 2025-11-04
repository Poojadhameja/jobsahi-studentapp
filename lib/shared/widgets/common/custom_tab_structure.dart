/// Reusable Tab Structure Widget
/// Can be used for both Jobs and Courses sections with customizable tabs

import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';

class CustomTabStructure extends StatefulWidget {
  /// List of tab configurations
  final List<TabConfig> tabs;

  /// List of tab content widgets
  final List<Widget> tabContents;

  /// Optional callback when tab changes
  final Function(int)? onTabChanged;

  const CustomTabStructure({
    super.key,
    required this.tabs,
    required this.tabContents,
    this.onTabChanged,
  }) : assert(
         tabs.length == tabContents.length,
         'Tabs and contents must have same length',
       );

  @override
  State<CustomTabStructure> createState() => _CustomTabStructureState();
}

class _CustomTabStructureState extends State<CustomTabStructure>
    with TickerProviderStateMixin {
  TabController? _tabController;
  bool _ownsController = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Prefer an ambient DefaultTabController if available so external callers can control tabs
    final ambient = DefaultTabController.maybeOf(context);
    if (_tabController == null) {
      if (ambient != null) {
        _tabController = ambient;
        _tabController!.addListener(_onTabChanged);
        _ownsController = false;
      } else {
        _tabController = TabController(length: widget.tabs.length, vsync: this);
        _tabController!.addListener(_onTabChanged);
        _ownsController = true;
      }
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    if (_ownsController) {
      _tabController?.dispose();
    }
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController != null && _tabController!.indexIsChanging) {
      widget.onTabChanged?.call(_tabController!.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabContents,
          ),
        ),
      ],
    );
  }

  /// Builds the tab bar
  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppConstants.cardBackgroundColor,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0), // Gap between underline and border
        child: TabBar(
          controller: _tabController,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: AppConstants.textSecondaryColor,
          indicatorColor: AppConstants.primaryColor,
          indicatorWeight: 3,
          dividerColor: Colors.transparent, // Remove default divider
          tabs: widget.tabs.map((tab) => Tab(text: tab.title)).toList(),
        ),
      ),
    );
  }
}

/// Configuration for individual tabs
class TabConfig {
  /// Tab title
  final String title;

  /// Optional tab icon
  final IconData? icon;

  const TabConfig({required this.title, this.icon});
}
