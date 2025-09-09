import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/youtube_link.dart';

class LinkCard extends StatefulWidget {
  final YouTubeLink link;
  final VoidCallback onTap;

  const LinkCard({
    super.key,
    required this.link,
    required this.onTap,
  });

  @override
  State<LinkCard> createState() => _LinkCardState();
}

class _LinkCardState extends State<LinkCard> {
  bool _expanded = false;
  String? _videoTitle;
  String? _videoDescription;
  String? _videoDuration;
  late final YoutubeExplode _yt;

  @override
  void initState() {
    super.initState();
    _yt = YoutubeExplode();
    _videoTitle = widget.link.videoTitle;
    _videoDescription = widget.link.videoDescription;
    _videoDuration = widget.link.videoDuration;
    if (_videoTitle == null || _videoDuration == null) {
      _ensureMetadata();
    }
  }

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }

  Future<void> _ensureMetadata() async {
    try {
      final video = await _yt.videos.get(widget.link.url);
      final title = video.title;
      final description = video.description ?? '';
      final duration = video.duration?.toString().split('.').first; // HH:MM:SS

      if (!mounted) return;
      setState(() {
        _videoTitle = title;
        _videoDescription = description;
        _videoDuration = duration;
      });

      // cache vào Firestore để những lần sau tải nhanh hơn
      if (widget.link.id != null) {
        await FirebaseFirestore.instance
            .collection('youtube_links')
            .doc(widget.link.id)
            .update({
          'video_title': title,
          'video_description': description,
          'video_duration': duration,
        });
      }
    } catch (e) {
      // im lặng nếu fail, UI vẫn hiển thị được
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: widget.link.highQualityThumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.link.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Priority tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.link.priorityColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.link.priority}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  // Meta: admin title + video meta snippet
                  if ((_videoTitle ?? widget.link.videoTitle) != null)
                    Text(
                      (_videoTitle ?? widget.link.videoTitle)!,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if ((_videoDuration ?? widget.link.videoDuration) != null) ...[
                    const SizedBox(height: 4),
                    Text('Thời lượng: ${(_videoDuration ?? widget.link.videoDuration)!}', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                  ],
                  if (((_videoDescription ?? widget.link.videoDescription) ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    AnimatedCrossFade(
                      firstChild: Text(
                        (_videoDescription ?? widget.link.videoDescription)!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, height: 1.35),
                      ),
                      secondChild: Text(
                        (_videoDescription ?? widget.link.videoDescription)!,
                        style: const TextStyle(fontSize: 13, height: 1.35),
                      ),
                      crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => setState(() => _expanded = !_expanded),
                        child: Text(_expanded ? 'Thu gọn' : 'Xem thêm'),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 8),
                  
                  // Date and play button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.link.createdAt.day}/${widget.link.createdAt.month}/${widget.link.createdAt.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Xem',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
