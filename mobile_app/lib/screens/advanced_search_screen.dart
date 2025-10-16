import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/youtube_link.dart';
import '../models/youtube_channel.dart';
import '../services/search_service.dart';
import '../widgets/website_video_card.dart';
import '../widgets/website_channel_card.dart';
import '../theme/app_theme.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  
  // Search state
  String _currentQuery = '';
  int _selectedPriority = 0;
  String _selectedCategory = 'Tất cả';
  String _selectedSort = 'Mới nhất';
  bool _isSearching = false;
  
  // Results
  List<YouTubeLink> _videoResults = [];
  List<YouTubeChannel> _channelResults = [];
  List<String> _searchSuggestions = [];
  List<String> _searchHistory = [];
  List<String> _popularSearches = [];
  List<Map<String, dynamic>> _trendingCategories = [];
  
  // UI state
  bool _showSuggestions = false;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final history = await SearchService.getSearchHistory();
    final popular = await SearchService.getPopularSearches();
    final trending = await SearchService.getTrendingCategories();
    
    setState(() {
      _searchHistory = history;
      _popularSearches = popular;
      _trendingCategories = trending;
    });
  }

  Future<void> _performSearch() async {
    if (_currentQuery.trim().isEmpty) return;
    
    setState(() {
      _isSearching = true;
      _showSuggestions = false;
    });

    try {
      if (_tabController.index == 0) {
        // Search videos
        final videos = await SearchService.searchVideos(
          query: _currentQuery,
          priorityFilter: _selectedPriority,
          categoryFilter: _selectedCategory,
          sortBy: _selectedSort,
        );
        setState(() {
          _videoResults = videos;
        });
      } else {
        // Search channels
        final channels = await SearchService.searchChannels(
          query: _currentQuery,
          sortBy: _selectedSort,
        );
        setState(() {
          _channelResults = channels;
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _onSearchChanged(String query) async {
    setState(() {
      _currentQuery = query;
    });

    if (query.isNotEmpty) {
      final suggestions = await SearchService.getSearchSuggestions(query);
      setState(() {
        _searchSuggestions = suggestions;
        _showSuggestions = true;
      });
    } else {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    setState(() {
      _currentQuery = suggestion;
      _showSuggestions = false;
    });
    _performSearch();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentQuery = '';
      _showSuggestions = false;
      _videoResults.clear();
      _channelResults.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm nâng cao'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Video', icon: Icon(Icons.video_library)),
            Tab(text: 'Kênh', icon: Icon(Icons.subscriptions)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          
          // Filters
          if (_showFilters) _buildFilters(),
          
          // Results
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVideoResults(),
                _buildChannelResults(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: (_) => _performSearch(),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm video hoặc kênh...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _currentQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Search Button
              ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
                child: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.search),
              ),
              const SizedBox(width: 8),
              // Filters Button
              IconButton(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                ),
                tooltip: 'Bộ lọc',
              ),
            ],
          ),
          
          // Search Suggestions
          if (_showSuggestions && _searchSuggestions.isNotEmpty)
            _buildSearchSuggestions(),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Gợi ý tìm kiếm',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ..._searchSuggestions.map((suggestion) => ListTile(
            leading: const Icon(Icons.search, size: 20),
            title: Text(suggestion),
            onTap: () => _onSuggestionTap(suggestion),
          )),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bộ lọc tìm kiếm',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Priority Filter
          if (_tabController.index == 0) ...[
            Text(
              'Độ ưu tiên:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: SearchService.getPriorityFilters().map((filter) {
                final index = SearchService.getPriorityFilters().indexOf(filter);
                final isSelected = _selectedPriority == index;
                return FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPriority = selected ? index : 0;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          // Category Filter
          Text(
            'Danh mục:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: SearchService.getCategoryFilters().take(8).map((filter) {
              final isSelected = _selectedCategory == filter;
              return FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? filter : 'Tất cả';
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          
          // Sort Options
          Text(
            'Sắp xếp:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: SearchService.getSortOptions().map((sort) {
              final isSelected = _selectedSort == sort;
              return FilterChip(
                label: Text(sort),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedSort = selected ? sort : 'Mới nhất';
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoResults() {
    if (_currentQuery.isEmpty) {
      return _buildEmptyState('video');
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_videoResults.isEmpty) {
      return _buildNoResults();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _videoResults.length,
      itemBuilder: (context, index) {
        final video = _videoResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WebsiteVideoCard(
            link: video,
            onTap: () {
              // Handle video tap
              debugPrint('Video tapped: ${video.videoTitle}');
            },
          ),
        );
      },
    );
  }

  Widget _buildChannelResults() {
    if (_currentQuery.isEmpty) {
      return _buildEmptyState('kênh');
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_channelResults.isEmpty) {
      return _buildNoResults();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _channelResults.length,
      itemBuilder: (context, index) {
        final channel = _channelResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WebsiteChannelCard(
            channel: channel,
            onTap: () {
              // Handle channel tap
              debugPrint('Channel tapped: ${channel.channelName}');
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String type) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search History
          if (_searchHistory.isNotEmpty) ...[
            _buildSection(
              'Lịch sử tìm kiếm',
              Icons.history,
              _searchHistory.map((query) => _buildHistoryItem(query)).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          // Popular Searches
          if (_popularSearches.isNotEmpty) ...[
            _buildSection(
              'Tìm kiếm phổ biến',
              Icons.trending_up,
              _popularSearches.map((query) => _buildPopularItem(query)).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          // Trending Categories
          if (_trendingCategories.isNotEmpty) ...[
            _buildSection(
              'Danh mục xu hướng',
              Icons.category,
              _trendingCategories.map((category) => _buildCategoryItem(category)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildHistoryItem(String query) {
    return ListTile(
      leading: const Icon(Icons.history, size: 20),
      title: Text(query),
      onTap: () => _onSuggestionTap(query),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 16),
        onPressed: () async {
          // Remove from history
          final history = await SearchService.getSearchHistory();
          history.remove(query);
          // Update UI
          setState(() {
            _searchHistory = history;
          });
        },
      ),
    );
  }

  Widget _buildPopularItem(String query) {
    return ListTile(
      leading: const Icon(Icons.trending_up, size: 20),
      title: Text(query),
      onTap: () => _onSuggestionTap(query),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    return ListTile(
      leading: Icon(category['icon'], size: 20),
      title: Text(category['name']),
      subtitle: Text('${category['count']} video'),
      onTap: () => _onSuggestionTap(category['name']),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy kết quả',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Thử tìm kiếm với từ khóa khác',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
