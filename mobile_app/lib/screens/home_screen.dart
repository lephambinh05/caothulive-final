import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/youtube_link.dart';
import '../widgets/link_card.dart';
import '../config.dart';
import 'channels_screen.dart';
import 'support_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPriority = 0; // 0 = tất cả, 1-5 = mức độ cụ thể
  int _currentIndex = 0; // 0 = Videos, 1 = Channels, 2 = Support

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        centerTitle: true,
        elevation: 0,
        bottom: _currentIndex == 0 ? PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Filter button for all priorities
                  FilterChip(
                    label: const Text('Tất cả'),
                    selected: _selectedPriority == 0,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPriority = 0;
                      });
                    },
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  // Priority filter buttons
                  ...List.generate(5, (index) {
                    final priority = index + 1;
                    final isSelected = _selectedPriority == priority;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: getPriorityColor(priority),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('${priority}'),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPriority = selected ? priority : 0;
                          });
                        },
                        selectedColor: getPriorityColor(priority).withOpacity(0.2),
                        checkmarkColor: getPriorityColor(priority),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ) : null,
      ),
      body: _getCurrentBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions),
            label: 'Channels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            label: 'Hỗ trợ',
          ),
        ],
      ),
    );
  }

  Widget _getCurrentBody() {
    switch (_currentIndex) {
      case 0:
        return _buildVideosBody();
      case 1:
        return const ChannelsScreen();
      case 2:
        return const SupportScreen();
      default:
        return _buildVideosBody();
    }
  }

  Widget _buildVideosBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('youtube_links')
          .orderBy('priority', descending: false) // Sắp xếp theo priority (1-5)
          .orderBy('created_at', descending: true) // Sau đó sắp xếp theo ngày tạo
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Firestore stream (mobile) error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Có lỗi xảy ra',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Không thể tải danh sách video',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Refresh stream
                    (context as Element).markNeedsBuild();
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint('Firestore stream (mobile) connecting...');
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang tải danh sách video...'),
              ],
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        debugPrint('Firestore stream (mobile) received ${docs.length} docs');
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          debugPrint(' - doc ${doc.id}: title=${data['title']}, url=${data['url']}, created_at=${data['created_at']}, priority=${data['priority']}');
        }

        var links = docs.map((doc) {
          return YouTubeLink.fromFirestore(doc);
        }).toList() ?? [];

        // Lọc theo priority nếu có chọn
        if (_selectedPriority > 0) {
          links = links.where((link) => link.priority == _selectedPriority).toList();
        }

        if (links.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedPriority > 0 ? Icons.filter_list : Icons.playlist_play,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedPriority > 0 ? 'Không có video nào với mức độ ưu tiên $_selectedPriority' : 'Chưa có video nào',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedPriority > 0 ? 'Hãy thử chọn mức độ ưu tiên khác' : 'Hãy đợi admin thêm video',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh stream
            (context as Element).markNeedsBuild();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: links.length,
            itemBuilder: (context, index) {
              final link = links[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: LinkCard(
                  link: link,
                  onTap: () => _openYouTubeLink(link.url),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'YouTube Videos';
      case 1:
        return 'YouTube Channels';
      case 2:
        return 'Hỗ trợ';
      default:
        return 'YouTube Link Manager';
    }
  }

  Future<void> _openYouTubeLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Không thể mở link';
      }
    } catch (e) {
      // Fallback: mở trong trình duyệt
      try {
        final uri = Uri.parse(url);
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        debugPrint('Error opening URL: $e');
      }
    }
  }
}