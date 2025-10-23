import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/caothulive_theme.dart';

class CustomSearchBar extends StatefulWidget {
  final String? hintText;
  final Function(String)? onSearch;
  final Function()? onClear;
  final bool showFilters;
  final Function(int)? onPriorityFilter;
  final int? selectedPriority;
  final bool showAdvancedSearch;

  const CustomSearchBar({
    super.key,
    this.hintText,
    this.onSearch,
    this.onClear,
    this.showFilters = true,
    this.onPriorityFilter,
    this.selectedPriority,
    this.showAdvancedSearch = true,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    widget.onSearch?.call(value);
    if (value.isNotEmpty && !_isExpanded) {
      setState(() => _isExpanded = true);
      _animationController.forward();
    } else if (value.isEmpty && _isExpanded) {
      setState(() => _isExpanded = false);
      _animationController.reverse();
    }
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
    setState(() => _isExpanded = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Input
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? CaoThuLiveTheme.backgroundCard : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: widget.hintText ?? 'Tìm kiếm video...',
                      hintStyle: TextStyle(
                        color: isDark ? CaoThuLiveTheme.textMuted : CaoThuLiveTheme.textMuted,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? CaoThuLiveTheme.textMuted : CaoThuLiveTheme.textMuted,
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: isDark ? CaoThuLiveTheme.textMuted : CaoThuLiveTheme.textMuted,
                              ),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    style: TextStyle(
                      color: isDark ? CaoThuLiveTheme.textPrimary : CaoThuLiveTheme.textPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Priority Filters
          if (widget.showFilters) ...[
            const SizedBox(height: 12),
            _buildPriorityFilters(),
          ],
          
          // Advanced Search Button
          if (widget.showAdvancedSearch) ...[
            const SizedBox(height: 12),
            _buildAdvancedSearchButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildPriorityFilters() {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Tất cả', 0, Icons.all_inclusive),
          const SizedBox(width: 8),
          ...List.generate(5, (index) {
            final priority = index + 1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                'Mức $priority',
                priority,
                _getPriorityIcon(priority),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int priority, IconData icon) {
    final isSelected = widget.selectedPriority == priority;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPriorityFilter?.call(priority);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? CaoThuLiveTheme.primaryRed 
              : (isDark ? CaoThuLiveTheme.backgroundCard : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? CaoThuLiveTheme.primaryRed 
                : (isDark ? CaoThuLiveTheme.textMuted : Colors.grey.shade300),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (priority > 0) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white 
                      : CaoThuLiveTheme.getPriorityColor(priority),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? Colors.white 
                  : (isDark ? CaoThuLiveTheme.textMuted : CaoThuLiveTheme.textMuted),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : (isDark ? CaoThuLiveTheme.textMuted : CaoThuLiveTheme.textMuted),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icons.priority_high;
      case 2:
        return Icons.trending_up;
      case 3:
        return Icons.star;
      case 4:
        return Icons.bookmark;
      case 5:
        return Icons.bookmark_border;
      default:
        return Icons.star;
    }
  }

  Widget _buildAdvancedSearchButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/advanced-search');
        },
        icon: const Icon(Icons.tune, size: 18),
        label: const Text('Tìm kiếm nâng cao'),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? CaoThuLiveTheme.backgroundCard : Colors.white,
          foregroundColor: isDark ? CaoThuLiveTheme.textPrimary : CaoThuLiveTheme.textPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }
}
