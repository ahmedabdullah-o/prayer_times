import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prayer_times/core/enums/svg_icon_data_enums.dart';
import 'package:prayer_times/core/extensions/svg_icon_data_extensions.dart';

class SvgIcon extends StatelessWidget {
  final SvgIconData svgIconData;
  final double width;
  final double height;
  final Color color;
  const SvgIcon(
    this.svgIconData, {
    super.key,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    print('{{{{{{{{{{{{{{{{{{{{{{{{{{{{[loading picture with path: ${svgIconData.path}');
    return SvgPicture.asset(
      svgIconData.path,
      width: width,
      height: height,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
