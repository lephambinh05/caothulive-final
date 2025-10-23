import 'package:flutter/material.dart';
import '../models/youtube_link.dart';
import '../theme/caothulive_theme.dart';

class CaoThuLiveVideoCard extends StatelessWidget {
  final YouTubeLink link;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final bool isFavorite;
  final bool showAnalytics;

  const CaoThuLiveVideoCard({
    super.key,
    required this.link,
    this.onTap,
    this.onFavorite,
    this.onShare,
    this.isFavorite = false,
    this.showAnalytics = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: CaoThuLiveTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CaoThuLiveTheme.mediumShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildThumbnail(context),
                const SizedBox(height: 12),
                _buildContent(context),
                if (showAnalytics) ...[
                  const SizedBox(height: 12),
                  _buildAnalytics(context),
                ],
                const SizedBox(height: 12),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CaoThuLiveTheme.getStatusColor(link.status).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CaoThuLiveTheme.getStatusColor(link.status),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: CaoThuLiveTheme.getStatusColor(link.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _getStatusText(),
                style: TextStyle(
                  color: CaoThuLiveTheme.getStatusColor(link.status),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: CaoThuLiveTheme.accentGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Priority ${link.priority}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: CaoThuLiveTheme.primaryGradient,
      ),
      child: Stack(
        children: [
          // Thumbnail placeholder with gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CaoThuLiveTheme.primaryRed.withOpacity(0.3),
                  CaoThuLiveTheme.primaryBlue.withOpacity(0.3),
                ],
              ),
            ),
          ),
          // Play button overlay
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: CaoThuLiveTheme.lightShadow,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: CaoThuLiveTheme.primaryRed,
                size: 30,
              ),
            ),
          ),
          // Duration badge
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          link.videoTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: CaoThuLiveTheme.textPrimary,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          link.title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CaoThuLiveTheme.textSecondary,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 14,
              color: CaoThuLiveTheme.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              _formatDate(link.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: CaoThuLiveTheme.textMuted,
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: CaoThuLiveTheme.getCategoryColor(link.category ?? 'other').withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                link.category ?? 'Other',
                style: TextStyle(
                  color: CaoThuLiveTheme.getCategoryColor(link.category ?? 'other'),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalytics(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildAnalyticsItem('Views', '1.2K', Icons.visibility),
          const SizedBox(width: 16),
          _buildAnalyticsItem('Likes', '89', Icons.thumb_up),
          const SizedBox(width: 16),
          _buildAnalyticsItem('Comments', '23', Icons.comment),
        ],
      ),
    );
  }

  Widget _buildAnalyticsItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: CaoThuLiveTheme.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: CaoThuLiveTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            color: CaoThuLiveTheme.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            label: 'Favorite',
            onTap: onFavorite,
            isActive: isFavorite,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.share,
            label: 'Share',
            onTap: onShare,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.analytics,
            label: 'Analytics',
            onTap: () {
              Navigator.pushNamed(context, '/live-analytics');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive 
                ? CaoThuLiveTheme.primaryRed.withOpacity(0.2)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive 
                  ? CaoThuLiveTheme.primaryRed
                  : Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive 
                    ? CaoThuLiveTheme.primaryRed
                    : CaoThuLiveTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive 
                      ? CaoThuLiveTheme.primaryRed
                      : CaoThuLiveTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (link.status.toLowerCase()) {
      case 'live':
        return 'LIVE';
      case 'upcoming':
        return 'UPCOMING';
      case 'ended':
        return 'ENDED';
      case 'paused':
        return 'PAUSED';
      default:
        return 'UNKNOWN';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
