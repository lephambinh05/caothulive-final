import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesProvider extends ChangeNotifier {
  static const String _favoritesKey = 'favorite_videos';
  
  final Set<String> _favoriteVideoIds = {};
  final Set<String> _favoriteChannelIds = {};

  Set<String> get favoriteVideoIds => Set.from(_favoriteVideoIds);
  Set<String> get favoriteChannelIds => Set.from(_favoriteChannelIds);

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load favorite videos
      final favoriteVideosJson = prefs.getString('${_favoritesKey}_videos');
      if (favoriteVideosJson != null) {
        final List<dynamic> favoriteVideos = json.decode(favoriteVideosJson);
        _favoriteVideoIds.addAll(favoriteVideos.cast<String>());
      }
      
      // Load favorite channels
      final favoriteChannelsJson = prefs.getString('${_favoritesKey}_channels');
      if (favoriteChannelsJson != null) {
        final List<dynamic> favoriteChannels = json.decode(favoriteChannelsJson);
        _favoriteChannelIds.addAll(favoriteChannels.cast<String>());
      }
      
      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save favorite videos
      await prefs.setString(
        '${_favoritesKey}_videos',
        json.encode(_favoriteVideoIds.toList()),
      );
      
      // Save favorite channels
      await prefs.setString(
        '${_favoritesKey}_channels',
        json.encode(_favoriteChannelIds.toList()),
      );
    } catch (e) {
      // Handle error silently
    }
  }

  bool isVideoFavorite(String videoId) {
    return _favoriteVideoIds.contains(videoId);
  }

  bool isChannelFavorite(String channelId) {
    return _favoriteChannelIds.contains(channelId);
  }

  Future<void> toggleVideoFavorite(String videoId) async {
    if (_favoriteVideoIds.contains(videoId)) {
      _favoriteVideoIds.remove(videoId);
    } else {
      _favoriteVideoIds.add(videoId);
    }
    
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> toggleChannelFavorite(String channelId) async {
    if (_favoriteChannelIds.contains(channelId)) {
      _favoriteChannelIds.remove(channelId);
    } else {
      _favoriteChannelIds.add(channelId);
    }
    
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> removeVideoFavorite(String videoId) async {
    _favoriteVideoIds.remove(videoId);
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> removeChannelFavorite(String channelId) async {
    _favoriteChannelIds.remove(channelId);
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> clearAllFavorites() async {
    _favoriteVideoIds.clear();
    _favoriteChannelIds.clear();
    await _saveFavorites();
    notifyListeners();
  }

  int get totalFavorites => _favoriteVideoIds.length + _favoriteChannelIds.length;
}
