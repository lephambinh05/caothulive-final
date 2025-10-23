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
import '../widgets/skeleton_loader.dart';
import '../providers/favorites_provider.dart';
import '../theme/caothulive_theme.dart';
import '../services/ai_content_discovery_service.dart';

class WebsiteHomeScreen extends StatefulWidget {
  const WebsiteHomeScreen({super.key});

  @override
  State<WebsiteHomeScreen> createState() => _WebsiteHomeScreenState();
}

class _WebsiteHomeScreenState extends State<WebsiteHomeScreen> {
  String activeTab = 'live';
  List<WebsiteLink> websiteLinks = [];
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: WebsiteHeader(
              title: 'CaoThuLive',
              onSupportTap: () {
                _showSupportDialog();
              },
              onRouteChanged: (route) {
                Navigator.pushNamed(context, route);
              },
            ),
          ),
          // Tabs
          SliverToBoxAdapter(
            child: WebsiteTabs(
              activeTab: activeTab,
              onTabChanged: (tab) {
                setState(() {
                  activeTab = tab;
                });
              },
            ),
          ),
          // Content
          _buildSliverContent(),
        ],
      ),
    );
  }


  Widget _buildSliverContent() {
    switch (activeTab) {
      case 'live':
        return _buildSliverVideosContent();
      case 'channel':
        return _buildSliverChannelsContent();
      case 'favorites':
        return _buildSliverFavoritesContent();
      default:
        return _buildSliverVideosContent();
    }
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

  Widget _buildSliverVideosContent() {
    // Build query
    Query query = FirebaseFirestore.instance.collection('youtube_links');
    
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: _buildErrorWidget('Có lỗi xảy ra', 'Không thể tải danh sách video: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: CaoThuLiveTheme.primaryRed),
                  SizedBox(height: 16),
                  Text('Đang tải danh sách video...'),
                ],
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        
        final links = docs.map((doc) {
          try {
            return YouTubeLink.fromFirestore(doc);
          } catch (e) {
            return null;
          }
        }).where((link) => link != null).cast<YouTubeLink>().toList();
        
        if (links.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyWidget(
              'Chưa có video nào',
              'Hãy đợi admin thêm video',
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final link = links[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: WebsiteVideoCard(
                  link: link,
                  onTap: () => _openYouTubeLinkWithTracking(link),
                ),
              );
            },
            childCount: links.length,
          ),
        );
      },
    );
  }

  Widget _buildVideosContent() {
    // Build query
    Query query = FirebaseFirestore.instance.collection('youtube_links');
    
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget('Có lỗi xảy ra', 'Không thể tải danh sách video: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: CaoThuLiveTheme.primaryRed),
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
          color: CaoThuLiveTheme.primaryRed,
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

  Widget _buildSliverChannelsContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('youtube_channels')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: _buildErrorWidget('Có lỗi xảy ra', 'Không thể tải danh sách kênh: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: CaoThuLiveTheme.primaryRed),
                  SizedBox(height: 16),
                  Text('Đang tải danh sách kênh...'),
                ],
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final channels = docs.map((doc) {
          return YouTubeChannel.fromFirestore(doc);
        }).toList();

        if (channels.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyWidget(
              'Chưa có kênh nào',
              'Hãy đợi admin thêm kênh YouTube',
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final channel = channels[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: WebsiteChannelCard(
                  channel: channel,
                  onTap: () => _openChannel(channel.channelUrl),
                ),
              );
            },
            childCount: channels.length,
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
                CircularProgressIndicator(color: CaoThuLiveTheme.primaryRed),
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
          color: CaoThuLiveTheme.primaryRed,
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
            color: CaoThuLiveTheme.primaryRed,
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
              color: CaoThuLiveTheme.textMuted,
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
            color: CaoThuLiveTheme.textMuted,
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
              color: CaoThuLiveTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _openYouTubeLinkWithTracking(YouTubeLink link) async {
    try {
      // Track click for trending analytics
      if (link.id != null) {
        await AIContentDiscoveryService.trackVideoClick(link.id!);
      }
      
      // Open YouTube link
      final uri = Uri.parse(link.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening YouTube link: $e');
    }
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

  Widget _buildSliverFavoritesContent() {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final favoriteVideoIds = favoritesProvider.favoriteVideoIds;
        final favoriteChannelIds = favoritesProvider.favoriteChannelIds;
        
        if (favoriteVideoIds.isEmpty && favoriteChannelIds.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyFavoritesWidget(),
          );
        }

        return SliverToBoxAdapter(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelColor: CaoThuLiveTheme.primaryRed,
                  unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
                  indicatorColor: CaoThuLiveTheme.primaryRed,
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
                SizedBox(
                  height: 400, // Fixed height for TabBarView
                  child: TabBarView(
                    children: [
                      _buildFavoriteVideos(favoriteVideoIds),
                      _buildFavoriteChannels(favoriteChannelIds),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                labelColor: CaoThuLiveTheme.primaryRed,
                unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
                indicatorColor: CaoThuLiveTheme.primaryRed,
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
          color: CaoThuLiveTheme.primaryRed,
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
          color: CaoThuLiveTheme.primaryRed,
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