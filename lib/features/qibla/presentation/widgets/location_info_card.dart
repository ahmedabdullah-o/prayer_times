import 'package:flutter/material.dart';
import 'package:prayer_times/core/style/colors.dart' as app;

class LocationInfoCard extends StatelessWidget {
  const LocationInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: app.Colors.foreground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            blurStyle: BlurStyle.outer,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Location', value: 'Cairo, Egypt'),
          SizedBox(height: 12),
          _InfoRow(label: 'Coordinates', value: '30.04° N, 31.24° E'),
          SizedBox(height: 12),
          _InfoRow(label: 'Distance to Mecca', value: '1,235 km'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: app.Colors.textSecondary,
            fontSize: 14,
            fontFamily: 'MPLUSRounded1c',
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: app.Colors.text,
            fontSize: 16,
            fontFamily: 'MPLUSRounded1c',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
