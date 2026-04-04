// ── Shared alert data ─────────────────────────────────────────────────────────

// status values:
//   'respond'    → needs a responder
//   'inProgress' → a responder accepted it
//   'resolved'   → incident closed by responder
//
// specification: free-text string if type == 'other', otherwise null (shown as '–')
// description:   caller-provided notes; shown in the incident detail popup

/// Active / in-progress alerts shown on the map and in the Home alert list.
final List<Map<String, dynamic>> sharedAlerts = [
  {
    'id': 'INC-001',
    'type': 'fire',
    'title': 'Fire Alert',
    'location': 'Brgy. Mat-y, Hollywood St.',
    'time': '6:32 PM',
    'status': 'respond',
    'lat': 10.8310,
    'lng': 122.5290,
    'specification': null,
    'description':
        'bulig huhu may ga sunod di sa 3rd floor dasiga niyo, and ido ko pagid na bilin sa cr basi indi na ka ginhawa sa aso help',
  },
  {
    'id': 'INC-002',
    'type': 'flood',
    'title': 'Flood Alert',
    'location': 'Brgy. Proper, Rizal St.',
    'time': '6:29 PM',
    'status': 'inProgress',
    'lat': 10.8290,
    'lng': 122.5330,
    'specification': null,
    'description':
        'sunog baks',
  },
  {
    'id': 'INC-003',
    'type': 'emergency',
    'title': 'Emergency Alert',
    'location': 'Brgy. Agustin, Mabini Ave.',
    'time': '6:26 PM',
    'status': 'respond',
    'lat': 10.8350,
    'lng': 122.5270,
    'specification': null,
    'description':
        'helppppppppp gina lagas ko sang killer',
  },
  {
    'id': 'INC-004',
    'type': 'medical',
    'title': 'Medical Alert',
    'location': 'Brgy. Caingin, National Hwy.',
    'time': '6:22 PM',
    'status': 'respond',
    'lat': 10.8260,
    'lng': 122.5350,
    'specification': null,
    'description':
        'ambot',
  },
  {
    'id': 'INC-003',
    'type': 'other',
    'title': 'Other Alert',
    'location': 'Brgy. Caingin, National Hwy.',
    'time': '6:22 PM',
    'status': 'respond',
    'lat': 10.8260,
    'lng': 122.5350,
    'specification': "ginalagas ko",
    'description':
        'potangina',
  },
];

final List<Map<String, dynamic>> resolvedAlerts = [];
