// Portfolio characterization checks added during sanitization; synthetic inputs.
import '../lib/utils/content_format.dart';
import '../lib/services/recent_image_cache.dart';
import '../lib/models/tribe_connection.dart';

int checks = 0;
void check(bool condition, String label) {
  if (!condition) throw StateError(label);
  checks++;
}

void main() {
  check(formatItemDescription(null) == '', 'null descriptions');
  check(formatItemDescription('<p>Community walk</p><br>Bring water &amp; snacks') ==
      'Community walk\nBring water & snacks', 'HTML and entities');
  check(formatItemDescription('Activities: Walk;Picnic;;') ==
      'Activities: Walk, Picnic', 'list formatting');
  check(formatItemDescription('📍 Synthetic location\n📅 Synthetic date\nMeet outside') ==
      'Meet outside', 'duplicate listing header');
  check(!isDisplayableTag('source:synthetic:001'), 'internal tags');
  check(!isDisplayableTag('AI-generated'), 'machine tags');
  check(isDisplayableTag('Hiking'), 'human-facing tags');
  check(formatDistanceMiles(-1) == '', 'negative distance');
  check(formatDistanceMiles(double.nan) == '', 'nonfinite distance');
  check(formatDistanceMiles(0.01) == '<0.1 mi away', 'near distance');
  check(formatDistanceMiles(3.25) == '3.3 mi away', 'distance precision');
  check(mapsUrlForItem() == null, 'missing map location');
  check(mapsUrlForItem(title: 'Synthetic park & field')!.contains('Synthetic%20park%20%26%20field'),
      'map URL encodes a synthetic title; no request is made');
  check(cityStateFromLocation('Sampleville, Illinois') == 'Sampleville, IL',
      'state-name formatting');
  // Known source limitation: escaped end anchors prevent ZIP stripping.
  check(cityStateFromLocation('Sampleville, IL 00000') == 'Sampleville, IL 00000',
      'document retained ZIP parsing limitation');
  RecentImageCache.clear();
  check(!RecentImageCache.contains(null), 'null image');
  RecentImageCache.add('');
  for (var i = 0; i < 11; i++) { RecentImageCache.add('synthetic-image-$i'); }
  check(!RecentImageCache.contains('synthetic-image-0'), 'oldest image evicted');
  check(RecentImageCache.contains('synthetic-image-10'), 'latest image retained');
  RecentImageCache.add('synthetic-image-1');
  RecentImageCache.add('synthetic-image-11');
  check(RecentImageCache.contains('synthetic-image-1'), 'repeated image refreshed');
  check(!RecentImageCache.contains('synthetic-image-2'), 'LRU order');
  check(RecentImageCache.filter(['synthetic-image-1', 'unseen'], (x) => x).single == 'unseen',
      'filter previously seen images');
  RecentImageCache.clear();
  check(!RecentImageCache.contains('synthetic-image-1'), 'cache reset');
  final connection = TribeConnection.fromJson({
    'connection_id': 1, 'other_uid': 'synthetic-person-1',
    'other_name': 'Example Member', 'status': 'tribe', 'health_bar': 75,
    'shared_activities': 2, 'last_activity_at': '2026-01-01T12:00:00Z',
  });
  check(connection.isTribe, 'connection status');
  check(connection.healthLabel == 'Strong', 'health label');
  check(connection.sharedActivities == 2, 'synthetic activity count');
  check(connection.otherImage.isEmpty, 'missing avatar fallback');
  print('PASS: $checks offline characterization checks.');
}
