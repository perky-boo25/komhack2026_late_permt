import 'package:flutter/material.dart';
import '../models/report_record.dart';
import '../widgets/report_record_card.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Reports',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black,
                  width: 1.5
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 1.2),
                      ),
                    ),
                    child: const Text(
                      'Ongoing Reports',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  ReportRecordCard(
                    record: const ReportRecord(
                      reportType: 'FIRE',
                      barangay: 'Brgy. Sample',
                      time: '2:30 PM',
                      status: 'PENDING',
                    ),
                    icon: Icons.local_fire_department,
                    iconColor: Colors.orange,
                    statusColor: Colors.grey,
                  ),

                  ReportRecordCard(
                    record: const ReportRecord(
                      reportType: 'FLOOD',
                      barangay: 'Brgy. Sample',
                      time: '3:15 PM',
                      status: 'ACKNOWLEDGED',
                    ),
                    icon: Icons.waves,
                    iconColor: Colors.blue,
                    statusColor: Colors.orange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 1.2,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Resolved Reports',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  ReportRecordCard(
                    record: const ReportRecord(
                      reportType: 'FIRE',
                      barangay: 'Brgy. Sample',
                      time: '1:10 PM',
                      status: 'RESOLVED',
                    ),
                    icon: Icons.local_fire_department,
                    iconColor: Colors.orange,
                    statusColor: Colors.green,
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