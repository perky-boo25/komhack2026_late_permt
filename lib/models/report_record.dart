// ── Simple data model (replace with your ReportRecord later) ──────────────────

class ReportRecord {
  final String incidentId;
  final String reportType;
  final String barangay;
  final String time;
  final String status;

  const ReportRecord({
    required this.incidentId,
    required this.reportType,
    required this.barangay,
    required this.time,
    required this.status,
  });
}