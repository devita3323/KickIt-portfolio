import 'dart:collection';

/// Sliding window of recently-seen item image URLs. Used by all swipe decks
/// (onboarding preview, Discover Explore/Activities/Events) so an image is
/// never repeated within the last [maxSize] items the user has been shown.
///
/// Process-local — resets when the app cold-starts. That's intentional:
/// across sessions, repeats are fine; within a session, they're annoying.
class RecentImageCache {
  RecentImageCache._();

  static const int maxSize = 10;

  // Ordered LRU. Using LinkedHashSet for O(1) contains + insertion-order.
  static final LinkedHashSet<String> _seen = LinkedHashSet<String>();

  /// Returns true if [imageUrl] is in the recent window.
  static bool contains(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;
    return _seen.contains(imageUrl);
  }

  /// Record that [imageUrl] was just shown. Drops the oldest if over capacity.
  static void add(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;
    // If already present, move it to "most recent" position by removing first.
    _seen.remove(imageUrl);
    _seen.add(imageUrl);
    while (_seen.length > maxSize) {
      _seen.remove(_seen.first);
    }
  }

  /// Filter [items] so any with an image already in the recent window is dropped.
  /// Pass an extractor to pull the URL out of whatever shape your items have.
  static List<T> filter<T>(Iterable<T> items, String? Function(T) imgOf) {
    return items.where((it) => !contains(imgOf(it))).toList();
  }

  /// Clear (rarely needed — exposed for tests / sign-out).
  static void clear() => _seen.clear();
}
