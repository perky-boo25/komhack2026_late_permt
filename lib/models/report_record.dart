// for structure in and reusability

class ReportRecord {
  final String incidentId;
  final String reportType;
  final String barangay;
  final String street;
  final String time;
  final String status;
  final String specification;
  final String description;
  final double? latitude;
  final double? longitude;
  final String assignedUnit;
  final String eta;
  final String responseState;

  const ReportRecord({
    required this.incidentId,
    required this.reportType,
    required this.barangay,
    required this.street,
    required this.time,
    required this.status,
    required this.specification,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.assignedUnit,
    required this.eta,
    required this.responseState,
  });

  // firestore data to model
  factory ReportRecord.fromMap(Map<String, dynamic> data, String documentId) {
    return ReportRecord(
      incidentId: documentId,
      reportType: data['reportType'] ?? 'EMERGENCY',
      barangay: data['barangay'] ?? 'Unknown Barangay',
      street: data['street'] ?? '',
      time: data['time'] ?? '',
      status: data['status'] ?? 'PENDING',
      specification: data['specification'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      assignedUnit: data['assignedUnit'] ?? '',
      eta: data['eta'] ?? '',
      responseState: data['responseState'] ?? '',
    );
  }
}