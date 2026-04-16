import 'package:cloud_firestore/cloud_firestore.dart';

// ── Firestore → local map converter ──────────────────────────────────────────
//
// Firestore `incidents` schema (from database):
//   barangay      : String   e.g. "Ungka I"
//   street        : String   e.g. "Benigno S. Aquino Jr. Avenue"
//   reportType    : String   e.g. "Fire", "Flood", "Medical", "Emergency", "Others"
//   status        : String   "PENDING" | "IN_PROGRESS" | "RESOLVED"
//   latitude      : double
//   longitude     : double
//   time          : String   e.g. "3:49 AM"
//   description   : String
//   specification : String   (empty string when not applicable)
//   createdAt     : Timestamp
//
// Local map shape used by all tabs:
//   id            : String    (Firestore document ID)
//   type          : String    "fire" | "flood" | "medical" | "emergency" | "other"
//   title         : String    e.g. "Fire Alert"
//   location      : String    "Brgy. <barangay>, <street>"
//   time          : String    exact time string from Firestore e.g. "3:49 AM"
//   createdAt     : DateTime? parsed from Firestore Timestamp; null if missing
//   status        : String    "respond" | "inProgress" | "resolved"
//   lat           : double
//   lng           : double
//   specification : String?   null when empty
//   description   : String?

// ── Time helpers ──────────────────────────────────────────────────────────────

/// Returns a human-readable "time ago" string derived from a [DateTime].
/// e.g. "Just now", "5 min ago", "2 hrs ago", "3 days ago".
String timeAgo(DateTime? dt) {
  if (dt == null) return '–';
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24)   return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
  if (diff.inDays < 7)     return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  return '${dt.month}/${dt.day}/${dt.year}';
}

/// Formats a [DateTime] as a readable date string e.g. "Apr 6, 2026".
String formatDate(DateTime? dt) {
  if (dt == null) return '–';
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[dt.month]} ${dt.day}, ${dt.year}';
}

/// Converts a Firestore document snapshot into the local alert map shape.
Map<String, dynamic> incidentFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;

  // ── type ──────────────────────────────────────────────────────────────────
  final rawType = (data['reportType'] as String? ?? '').toLowerCase();
  final String type;
  if (rawType == 'others' || rawType == 'other') {
    type = 'other';
  } else if (rawType == 'fire') {
    type = 'fire';
  } else if (rawType == 'flood') {
    type = 'flood';
  } else if (rawType == 'medical') {
    type = 'medical';
  } else if (rawType == 'emergency') {
    type = 'emergency';
  } else {
    type = 'other';
  }

  // ── title ─────────────────────────────────────────────────────────────────
  final String title;
  switch (type) {
    case 'fire':      title = 'Fire Alert';      break;
    case 'flood':     title = 'Flood Alert';     break;
    case 'medical':   title = 'Medical Alert';   break;
    case 'emergency': title = 'Emergency Alert'; break;
    default:          title = 'Other Alert';
  }

  // ── status ────────────────────────────────────────────────────────────────
  final rawStatus = (data['status'] as String? ?? 'PENDING').toUpperCase();
  final String status;
  switch (rawStatus) {
    case 'IN_PROGRESS': status = 'inProgress'; break;
    case 'RESOLVED':    status = 'resolved';   break;
    default:            status = 'respond';    // PENDING
  }

  // ── location ──────────────────────────────────────────────────────────────
  final barangay = (data['barangay'] as String? ?? '').trim();
  final street   = (data['street']   as String? ?? '').trim();
  final location = barangay.isNotEmpty && street.isNotEmpty
      ? '$barangay, $street'
      : barangay.isNotEmpty
          // ignore: unnecessary_string_interpolations
          ? '$barangay'
          : street.isNotEmpty
              ? street
              : 'Unknown location';

  // ── specification ─────────────────────────────────────────────────────────
  final rawSpec = data['specification'] as String?;
  final String? specification =
      (rawSpec != null && rawSpec.trim().isNotEmpty) ? rawSpec.trim() : null;

  // ── description ───────────────────────────────────────────────────────────
  final rawDesc = data['description'] as String?;
  final String? description =
      (rawDesc != null && rawDesc.trim().isNotEmpty) ? rawDesc.trim() : null;

  // ── createdAt → DateTime ──────────────────────────────────────────────────
  final rawTs = data['createdAt'];
  final DateTime? createdAt =
      rawTs is Timestamp ? rawTs.toDate() : null;

  return {
    'id':            doc.id,
    'type':          type,
    'title':         title,
    'location':      location,
    'time':          data['time'] as String? ?? '–',
    'createdAt':     createdAt,
    'status':        status,
    'lat':           (data['latitude']  as num?)?.toDouble() ?? 0.0,
    'lng':           (data['longitude'] as num?)?.toDouble() ?? 0.0,
    'specification': specification,
    'description':   description,
  };
}

// ── Firestore stream helpers ──────────────────────────────────────────────────

/// Stream of active (non-resolved) incidents, sorted newest-first in Dart.
/// Uses a simple `where` with no `orderBy` to avoid requiring a composite index.
Stream<List<Map<String, dynamic>>> activeAlertsStream() {
  return FirebaseFirestore.instance
      .collection('incidents')
      .where('status', whereNotIn: ['RESOLVED'])
      .snapshots()
      .map((snap) {
        final list = snap.docs.map(incidentFromDoc).toList();
        // Sort newest-first using the raw Firestore Timestamp stored in each doc.
        // Falls back gracefully if createdAt is missing.
        list.sort((a, b) {
          final aTs = snap.docs
              .firstWhere((d) => d.id == a['id'])
              .data()['createdAt'];
          final bTs = snap.docs
              .firstWhere((d) => d.id == b['id'])
              .data()['createdAt'];
          if (aTs == null || bTs == null) return 0;
          return (bTs as Timestamp).compareTo(aTs as Timestamp);
        });
        return list;
      });
}

/// Stream of resolved incidents, sorted newest-first in Dart.
/// Uses a simple `where` with no `orderBy` to avoid requiring a composite index.
Stream<List<Map<String, dynamic>>> resolvedAlertsStream() {
  return FirebaseFirestore.instance
      .collection('incidents')
      .where('status', isEqualTo: 'RESOLVED')
      .snapshots()
      .map((snap) {
        final list = snap.docs.map(incidentFromDoc).toList();
        list.sort((a, b) {
          final aTs = snap.docs
              .firstWhere((d) => d.id == a['id'])
              .data()['createdAt'];
          final bTs = snap.docs
              .firstWhere((d) => d.id == b['id'])
              .data()['createdAt'];
          if (aTs == null || bTs == null) return 0;
          return (bTs as Timestamp).compareTo(aTs as Timestamp);
        });
        return list;
      });
}

/// One-shot update of a single incident's status in Firestore.
/// [docId] is the Firestore document ID stored in alert['id'].
/// [newStatus] should be one of: 'PENDING', 'IN_PROGRESS', 'RESOLVED'.
Future<void> updateIncidentStatus(String docId, String newStatus) {
  return FirebaseFirestore.instance
      .collection('incidents')
      .doc(docId)
      .update({'status': newStatus});
}