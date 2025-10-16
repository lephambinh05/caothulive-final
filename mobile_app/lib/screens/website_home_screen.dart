import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/youtube_link.dart';
import '../models/youtube_channel.dart';
import '../models/website_link.dart';
import '../widgets/website_header.dart';
import '../widgets/website_tabs.dart';
import '../widgets/website_video_card.dart';
import '../widgets/website_channel_card.dart';
import '../widgets/website_support_page.dart';
import '../widgets/search_bar.dart';
import '../widgets/skeleton_loader.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';

class WebsiteHomeScreen extends StatefulWidget {
  const WebsiteHomeScreen({super.key});

  @override
  State<WebsiteHomeScreen> createState() => _WebsiteHomeScreenState();
}

class _WebsiteHomeScreenState extends State<WebsiteHomeScreen> {
  String activeTab = 'live';
  List<WebsiteLink> websiteLinks = [];
  String searchQuery = '';
  int selectedPriority = 0;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          WebsiteHeader(
            title: 'VideoHub Pro',
            onSupportTap: () {
              _showSupportDialog();
            },
          ),
          // Search Bar
          if (activeTab != 'favorites')
            CustomSearchBar(
              hintText: activeTab == 'live' ? 'Tìm kiếm video...' : 'Tìm kiếm kênh...',
              onSearch: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
              onClear: () {
                setState(() {
                  searchQuery = '';
                });
              },
              onPriorityFilter: (priority) {
                setState(() {
                  selectedPriority = priority;
                });
              },
              selectedPriority: selectedPriority,
              showFilters: activeTab == 'live',
            ),
          // Tabs
          WebsiteTabs(
            activeTab: activeTab,
            onTabChanged: (tab) {
              setState(() {
                activeTab = tab;
                searchQuery = '';
                selectedPriority = 0;
              });
            },
          ),
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }


  Widget _buildContent() {
    switch (activeTab) {
      case 'live':
        return _buildVideosContent();
      case 'channel':
        return _buildChannelsContent();
      case 'favorites':
        return _buildFavoritesContent();
      default:
        return _buildVideosContent();
    }
  }

  Widget _buildVideosContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('youtube_links')
          .orderBy('priority', descending: false)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget('Có lỗi xảy ra', 'Không thể tải danh sách video');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryRed),
                SizedBox(height: 16),
                Text('Đang tải danh sách video...'),
              ],
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final links = docs.map((doc) {
          return YouTubeLink.fromFirestore(doc);
        }).toList();

        if (links.isEmpty) {
          return _buildEmptyWidget(
            'Chưa có video nào',
            'Hãy đợi admin thêm video',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          color: AppTheme.primaryRed,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: links.length,
            itemBuilder: (context, index) {
              final link = links[index];
              return WebsiteVideoCard(
                link: link,
                onTap: () => _openYouTubeLink(link.url),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildChannelsContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('youtube_channels')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget('Có lỗi xảy ra', 'Không thể tải danh sách kênh');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryRed),
                SizedBox(height: 16),
                Text('Đang tải danh sách kênh...'),
              ],
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final channels = docs.map((doc) {
          return YouTubeChannel.fromFirestore(doc);
        }).toList();

        if (channels.isEmpty) {
          return _buildEmptyWidget(
            'Chưa có kênh nào',
            'Hãy đợi admin thêm kênh YouTube',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          color: AppTheme.primaryRed,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              return WebsiteChannelCard(
                channel: channel,
                onTap: () => _openChannel(channel.channelUrl),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.primaryRed,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            activeTab == 'live' ? Icons.playlist_play : Icons.subscriptions,
            size: 64,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _openYouTubeLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening YouTube link: $e');
    }
  }

  Future<void> _openChannel(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening channel: $e');
    }
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: const WebsiteSupportPage(),
        ),
      ),
    );
  }

  Widget _buildFavoritesContent() {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final favoriteVideoIds = favoritesProvider.favoriteVideoIds;
        final favoriteChannelIds = favoritesProvider.favoriteChannelIds;
        
        if (favoriteVideoIds.isEmpty && favoriteChannelIds.isEmpty) {
          return _buildEmptyFavoritesWidget();
        }

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                labelColor: AppTheme.primaryRed,
                unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
                indicatorColor: AppTheme.primaryRed,
                tabs: [
                  Tab(
                    icon: Icon(Icons.play_circle_outline),
                    text: 'Video (${favoriteVideoIds.length})',
                  ),
                  Tab(
                    icon: Icon(Icons.subscriptions),
                    text: 'Kênh (${favoriteChannelIds.length})',
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildFavoriteVideos(favoriteVideoIds),
                    _buildFavoriteChannels(favoriteChannelIds),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyFavoritesWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có video yêu thích',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm video vào danh sách yêu thích để xem lại sau',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteVideos(Set<String> favoriteVideoIds) {
    if (favoriteVideoIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 48,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có video yêu thích',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('youtube_links')
          .where(FieldPath.documentId, whereIn: favoriteVideoIds.toList())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget('Có lỗi xảy ra', 'Không thể tải video yêu thích');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SkeletonLoader(
            isLoading: true,
            child: ListSkeleton(
              itemCount: 3,
              itemBuilder: (index) => const VideoCardSkeleton(),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final links = docs.map((doc) => YouTubeLink.fromFirestore(doc)).toList();

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          color: AppTheme.primaryRed,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: links.length,
            itemBuilder: (context, index) {
              final link = links[index];
              return WebsiteVideoCard(
                link: link,
                onTap: () => _openYouTubeLink(link.url),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFavoriteChannels(Set<String> favoriteChannelIds) {
    if (favoriteChannelIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.subscriptions,
              size: 48,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có kênh yêu thích',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('youtube_channels')
          .where(FieldPath.documentId, whereIn: favoriteChannelIds.toList())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget('Có lỗi xảy ra', 'Không thể tải kênh yêu thích');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SkeletonLoader(
            isLoading: true,
            child: ListSkeleton(
              itemCount: 3,
              itemBuilder: (index) => const ChannelCardSkeleton(),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final channels = docs.map((doc) => YouTubeChannel.fromFirestore(doc)).toList();

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          color: AppTheme.primaryRed,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              return WebsiteChannelCard(
                channel: channel,
                onTap: () => _openChannel(channel.channelUrl),
              );
            },
          ),
        );
      },
    );
  }

  // Future<void> _openWebsiteLink(String url) async {
  //   try {
  //     final uri = Uri.parse(url);
  //     if (await canLaunchUrl(uri)) {
  //       await launchUrl(uri, mode: LaunchMode.externalApplication);
  //     }
  //   } catch (e) {
  //     debugPrint('Error opening website link: $e');
  //   }
  // }
}