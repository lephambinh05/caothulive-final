import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/youtube_link.dart';
import '../models/youtube_channel.dart';
import '../models/website_link.dart';
import '../widgets/website_header.dart';
import '../widgets/website_tabs.dart';
import '../widgets/website_video_card.dart';
import '../widgets/website_channel_card.dart';
import '../widgets/website_support_page.dart';
import '../theme/app_theme.dart';
import '../config.dart';

class WebsiteHomeScreen extends StatefulWidget {
  const WebsiteHomeScreen({super.key});

  @override
  State<WebsiteHomeScreen> createState() => _WebsiteHomeScreenState();
}

class _WebsiteHomeScreenState extends State<WebsiteHomeScreen> {
  String activeTab = 'live';
  List<WebsiteLink> websiteLinks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgWhite,
      body: Column(
        children: [
          // Header
          WebsiteHeader(
            title: 'YouTube',
            onSupportTap: () {
              _showSupportDialog();
            },
          ),
          // Tabs
          WebsiteTabs(
            activeTab: activeTab,
            onTabChanged: (tab) {
              setState(() {
                activeTab = tab;
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

  Future<void> _openWebsiteLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening website link: $e');
    }
  }
}