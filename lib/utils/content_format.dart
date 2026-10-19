// Shared presentation-layer formatters for item content.
//
// Source data (e.g. imported USDA farmers-market / CSA listings) stores
// descriptions with literal HTML `<br>` tags and semicolon-delimited product
// lists, and carries internal machine tags like `source:synthetic:001`. These must
// never reach the UI raw. Keep ALL of this in the render layer — do not mutate
// the stored rows.

/// Cleans a raw item description for display:
///  - converts `<br>`, `<br/>`, `<p>`, `</p>` to line breaks
///  - strips any remaining simple HTML tags
///  - turns `A;B;C;` semicolon lists into `A, B, C`
///  - collapses repeated/blank separators and trims
///  - decodes common HTML entities
String formatItemDescription(String? raw) {
  if (raw == null) return '';
  var s = raw;

  // Drop leading presentation-marker lines that duplicate fields already
  // shown separately in the UI (location_1, category chip, distance):
  //   \ud83d\udcc5 date   \ud83d\udccd address   \ud83c\udff7\ufe0f category   \ud83d\udccf distance
  // These appear only as a header block at the top of imported listings
  // (Ticketmaster / Foursquare), so we strip consecutive leading lines
  // that begin with one of these markers, then keep the real body text.
  {
    final markerLines = s.split('\n');
    var start = 0;
    final markerRe =
        RegExp(r'^\s*(\u{1F4C5}|\u{1F4CD}|\u{1F3F7}|\u{1F4CF})', unicode: true);
    while (start < markerLines.length) {
      final line = markerLines[start];
      if (line.trim().isEmpty || markerRe.hasMatch(line)) {
        start++;
      } else {
        break;
      }
    }
    if (start > 0 && start < markerLines.length) {
      s = markerLines.sublist(start).join('\n');
    }
  }

  // Normalize line-break-ish HTML to newlines.
  s = s.replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n');
  s = s.replaceAll(RegExp(r'<\s*/?\s*p\s*>', caseSensitive: false), '\n');
  s = s.replaceAll(RegExp(r'<\s*/?\s*li\s*>', caseSensitive: false), '\n');

  // Strip any remaining tags.
  s = s.replaceAll(RegExp(r'<[^>]+>'), ' ');

  // Decode a few common entities.
  const entities = {
    '&amp;': '&',
    '&lt;': '<',
    '&gt;': '>',
    '&quot;': '"',
    '&#39;': "'",
    '&apos;': "'",
    '&nbsp;': ' ',
  };
  entities.forEach((k, v) => s = s.replaceAll(k, v));

  // Convert semicolon product lists to comma-separated, dropping empties.
  // Do this per-line so "Open: Year-round" lines are unaffected.
  final lines = s.split('\n');
  final out = <String>[];
  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty) continue;
    if (line.contains(';')) {
      final parts = line
          .split(';')
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
      // If the line is "Label: a;b;c" keep the label, comma-join the rest.
      if (parts.isNotEmpty && parts.first.contains(':')) {
        final firstColon = parts.first.indexOf(':');
        final label = parts.first.substring(0, firstColon + 1).trim();
        parts[0] = parts.first.substring(firstColon + 1).trim();
        final body = parts.where((p) => p.isNotEmpty).join(', ');
        line = '$label $body';
      } else {
        line = parts.join(', ');
      }
    }
    out.add(line);
  }

  return out.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}

/// Internal/machine tag namespaces that should never render as a user-facing
/// chip. Matches the existing hidden-tag rules in the explore detail page and
/// adds the USDA import namespaces (`source:synthetic:001`, `source:synthetic:002`).
bool isDisplayableTag(Object? tag) {
  final s = tag?.toString().trim().toLowerCase() ?? '';
  if (s.isEmpty) return false;

  // Any namespaced machine tag (contains a colon) is internal.
  if (s.contains(':')) return false;

  const hidden = {
    'ai-generated',
    'ai generated',
    'ai_generated',
    'ai',
    'aigenerated',
    'nps',
    'src',
    'tm',
    'ticketmaster',
    'user-added',
    'foursquare',
    'usda',
    'fsq',
  };
  if (hidden.contains(s)) return false;

  return true;
}

/// Formats a distance in miles for display, e.g. "3.2 mi away".
/// Returns '' for non-finite or negative input. Uses "<0.1 mi away" for very
/// close points so we never show "0.0 mi away".
String formatDistanceMiles(double? miles) {
  if (miles == null || miles.isNaN || miles.isInfinite || miles < 0) {
    return '';
  }
  if (miles < 0.1) return '<0.1 mi away';
  if (miles < 10) return '${miles.toStringAsFixed(1)} mi away';
  return '${miles.round()} mi away';
}

/// Builds a Google Maps URL for an item. Prefers a Google Place ID (the value
/// stored in items.external_ref for auto-discovered places); otherwise falls
/// back to lat/lon, and finally to a name search. Returns null if there is
/// nothing usable to link to.
String? mapsUrlForItem({
  String? placeId,
  double? lat,
  double? lon,
  String? title,
}) {
  final pid = placeId?.trim() ?? '';
  if (pid.isNotEmpty) {
    return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(title ?? 'place')}&query_place_id=$pid';
  }
  if (lat != null && lon != null && (lat != 0.0 || lon != 0.0)) {
    return 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
  }
  final t = title?.trim() ?? '';
  if (t.isNotEmpty) {
    return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(t)}';
  }
  return null;
}

// US state names + abbreviations for compact "City, State" extraction.
const _usStates = <String, String>{
  'alabama': 'AL',
  'alaska': 'AK',
  'arizona': 'AZ',
  'arkansas': 'AR',
  'california': 'CA',
  'colorado': 'CO',
  'connecticut': 'CT',
  'delaware': 'DE',
  'florida': 'FL',
  'georgia': 'GA',
  'hawaii': 'HI',
  'idaho': 'ID',
  'illinois': 'IL',
  'indiana': 'IN',
  'iowa': 'IA',
  'kansas': 'KS',
  'kentucky': 'KY',
  'louisiana': 'LA',
  'maine': 'ME',
  'maryland': 'MD',
  'massachusetts': 'MA',
  'michigan': 'MI',
  'minnesota': 'MN',
  'mississippi': 'MS',
  'missouri': 'MO',
  'montana': 'MT',
  'nebraska': 'NE',
  'nevada': 'NV',
  'new hampshire': 'NH',
  'new jersey': 'NJ',
  'new mexico': 'NM',
  'new york': 'NY',
  'north carolina': 'NC',
  'north dakota': 'ND',
  'ohio': 'OH',
  'oklahoma': 'OK',
  'oregon': 'OR',
  'pennsylvania': 'PA',
  'rhode island': 'RI',
  'south carolina': 'SC',
  'south dakota': 'SD',
  'tennessee': 'TN',
  'texas': 'TX',
  'utah': 'UT',
  'vermont': 'VT',
  'virginia': 'VA',
  'washington': 'WA',
  'west virginia': 'WV',
  'wisconsin': 'WI',
  'wyoming': 'WY',
  'district of columbia': 'DC',
};

/// Reduces a messy full address to a compact "City, State" for summary cards.
/// Handles comma-separated location text with state names.
/// Falls back to the original (trimmed) string if it can't parse one.
String cityStateFromLocation(String? raw) {
  final input = (raw ?? '').trim();
  if (input.isEmpty) return '';
  final parts =
      input.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();

  String _titleCase(String s) => s
      .split(RegExp(r'\s+'))
      .map((w) => w.isEmpty
          ? w
          : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');

  // Scan parts for a state (full name or 2-letter abbrev, possibly with a ZIP).
  for (var i = 0; i < parts.length; i++) {
    final token = parts[i];
    // Strip a trailing ZIP from tokens like "Illinois 61019" or "WI 53574".
    final noZip =
        token.replaceAll(RegExp(r'\s*\d{5}(?:-\d{4})?\s*\$'), '').trim();
    final lower = noZip.toLowerCase();
    String? abbrev;
    if (_usStates.containsKey(lower)) {
      abbrev = _usStates[lower];
    } else if (RegExp(r'^[A-Za-z]{2}\$').hasMatch(noZip) &&
        _usStates.containsValue(noZip.toUpperCase())) {
      abbrev = noZip.toUpperCase();
    }
    if (abbrev != null && i > 0) {
      final city = parts[i - 1].replaceAll(RegExp(r'\s*\d{5}.*\$'), '').trim();
      if (city.isNotEmpty && !RegExp(r'^\d').hasMatch(city)) {
        return '${_titleCase(city)}, $abbrev';
      }
    }
  }
  // Fallback: last two non-numeric parts, or the original.
  final words =
      parts.where((p) => !RegExp(r'^[\d.\s]+\$').hasMatch(p)).toList();
  if (words.length >= 2)
    return '${_titleCase(words[words.length - 2])}, ${words.last}';
  return input;
}
