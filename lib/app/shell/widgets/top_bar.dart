import 'package:flutter/material.dart';

final _title = {'/home': 'TODAY', '/habits': "HABITS"};

class TopBar extends StatelessWidget {
  final String currentPath;
  const TopBar(this.currentPath, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: Colors.grey[900],
      height: 48.0,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Icon(Icons.person, size: 32, color: Colors.grey[600]),
              ),
              SizedBox(width: 12),
              Text(
                _title[currentPath] ?? '',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          _ProgressBar(40),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double completionRate;
  const _ProgressBar(this.completionRate);

  @override
  Widget build(BuildContext context) {
    if (completionRate > 100 || completionRate < 0) {
      throw Exception(
        'completion rate error: CompletionRate value must be between 0 and 100',
      );
    }
    return Container(
      width: 128,
      height: 16,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        alignment: AlignmentGeometry.centerLeft,
        children: [
          Container(
            width: completionRate * 128 / 100,
            height: 16,
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(6),
              color: Colors.blue[50],
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            width: 128,
            height: 16,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2.5,
                color: Colors.white,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
