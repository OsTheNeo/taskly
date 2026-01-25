import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../state/settings_state.dart';

/// A duotone icon widget that uses SVG icons with customizable colors.
///
/// Parameters:
/// - [strokeColor]: Color exterior - the main stroke/line color (default: black/white based on theme)
/// - [fillColor]: Color de borde - solid fill elements like dots (default: same as stroke)
/// - [accentColor]: Color de accent - the duotone fill color (default: app accent color)
class DuotoneIcon extends StatelessWidget {
  final String name;
  final double size;

  /// Color exterior - the main stroke/line color
  final Color? strokeColor;

  /// Color de borde - solid fill elements (dots, solid parts)
  final Color? fillColor;

  /// Color de accent - the duotone fill color
  final Color? accentColor;

  /// Override stroke width. If null, scales automatically for large icons.
  final double? strokeWidth;

  /// Legacy parameter - use strokeColor instead
  final Color? color;

  const DuotoneIcon(
    this.name, {
    super.key,
    this.size = 24,
    this.strokeColor,
    this.fillColor,
    this.accentColor,
    this.strokeWidth,
    this.color, // Legacy support
  });

  // Icon name constants for easy reference
  // Navigation & Basic
  static const String home = 'home';
  static const String rocket = 'rocket';
  static const String user = 'user';
  static const String users = 'users';
  static const String plus = 'plus';
  static const String minus = 'minus';
  static const String trash = 'trash';
  static const String check = 'check';
  static const String x = 'x';
  static const String xmark = 'xmark';
  static const String gear = 'gear';
  static const String target = 'target';
  static const String google = 'google';

  // Arrows & Navigation
  static const String chevronRight = 'chevron-right';
  static const String chevronLeft = 'chevron-left';
  static const String chevronDown = 'chevron-down';
  static const String exit = 'exit';

  // Content & Media
  static const String book = 'book';
  static const String chart = 'chart';
  static const String clipboard = 'clipboard';
  static const String clipboardCheck = 'clipboard-check';
  static const String tasks = 'tasks';
  static const String calendar = 'calendar';
  static const String clock = 'clock';
  static const String timer = 'timer';
  static const String image = 'image';
  static const String camera = 'camera';
  static const String link = 'link';
  static const String search = 'search';

  // Status & Feedback
  static const String bell = 'bell';
  static const String info = 'info';
  static const String star = 'star';
  static const String sparkle = 'sparkle';
  static const String award = 'award';
  static const String flame = 'flame';
  static const String bolt = 'bolt';
  static const String heart = 'heart';

  // Categories
  static const String gauge = 'gauge';
  static const String bookmark = 'bookmark';
  static const String wallet = 'wallet';
  static const String feather = 'feather';
  static const String leaf = 'leaf';
  static const String suitcase = 'suitcase';
  static const String layers = 'layers';

  // Actions
  static const String refresh = 'refresh';
  static const String download = 'download';
  static const String sliders = 'sliders';
  static const String globe = 'globe';
  static const String lock = 'lock';
  static const String mail = 'mail';
  static const String userPlus = 'user-plus';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Resolve colors with fallbacks
    // strokeColor (exterior): defaults to black in light, white in dark
    final effectiveStroke = strokeColor ?? color ?? (isDark ? Colors.white : Colors.black);

    // fillColor (borde/solid fills): defaults to same as stroke
    final effectiveFill = fillColor ?? effectiveStroke;

    // accentColor: defaults to app accent color
    final effectiveAccent = accentColor ?? _getAccentColor(context);

    // Calculate stroke width for large icons
    final effectiveStrokeWidth = strokeWidth ?? _calculateStrokeWidth();

    return FutureBuilder<String>(
      future: _loadAndProcessSvg(effectiveStroke, effectiveFill, effectiveAccent, effectiveStrokeWidth),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(width: size, height: size);
        }

        return SvgPicture.string(
          snapshot.data!,
          width: size,
          height: size,
        );
      },
    );
  }

  /// Calculate optimal stroke width based on icon size.
  /// Base SVGs are designed for 18px with 1.5 stroke.
  /// For larger sizes, we reduce the stroke to keep visual balance.
  double _calculateStrokeWidth() {
    if (size <= 24) return 1.5;
    if (size <= 32) return 1.3;
    if (size <= 40) return 1.1;
    if (size <= 48) return 1.0;
    return 0.8; // Very large icons
  }

  Color _getAccentColor(BuildContext context) {
    // Try to get accent from settings signal
    try {
      final accentIndex = accentColorIndex.value;
      final colors = [
        Colors.blue,
        Colors.purple,
        Colors.pink,
        Colors.red,
        Colors.orange,
        Colors.amber,
        Colors.green,
        Colors.teal,
        Colors.cyan,
        Colors.indigo,
      ];
      return colors[accentIndex % colors.length];
    } catch (_) {
      return Theme.of(context).colorScheme.primary;
    }
  }

  Future<String> _loadAndProcessSvg(Color strokeColor, Color fillColor, Color accentColor, double strokeWidth) async {
    try {
      final svgString = await rootBundle.loadString('assets/icons/$name.svg');
      return _processSvg(svgString, strokeColor, fillColor, accentColor, strokeWidth);
    } catch (e) {
      // Return empty SVG on error
      return '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 18 18"></svg>';
    }
  }

  String _processSvg(String svg, Color strokeColor, Color fillColor, Color accentColor, double strokeWidth) {
    // Convert colors to hex
    final strokeHex = _colorToHex(strokeColor);
    final fillHex = _colorToHex(fillColor);
    final accentHex = _colorToHex(accentColor);

    // Replace stroke color (color exterior - main lines)
    var processed = svg.replaceAll('stroke="#1c1f21"', 'stroke="$strokeHex"');

    // Replace stroke-width for proper scaling on large icons
    processed = processed.replaceAll(
      RegExp(r'stroke-width="[0-9.]+"'),
      'stroke-width="$strokeWidth"',
    );

    // Replace solid fills (color de borde - for elements like dots)
    processed = processed.replaceAll(
      RegExp(r'fill="#1c1f21"(?!\s+fill-opacity)'),
      'fill="$fillHex"',
    );

    // Replace duotone fills (color de accent)
    processed = processed.replaceAll(
      RegExp(r'fill="#1c1f21"\s+fill-opacity="0\.3"'),
      'fill="$accentHex"',
    );

    // Handle opacity attribute with fill anywhere in element
    processed = processed.replaceAllMapped(
      RegExp(r'opacity="0\.3"([^>]*)fill="#1c1f21"'),
      (match) => 'opacity="1"${match.group(1)}fill="$accentHex"',
    );

    // Handle data-color="color-2" elements (these get accent color)
    processed = processed.replaceAllMapped(
      RegExp(r'fill="#1c1f21"([^>]*)data-color="color-2"'),
      (match) => 'fill="$accentHex"${match.group(1)}',
    );

    return processed;
  }

  String _colorToHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }
}

/// Preloaded duotone icon that caches the processed SVG
class CachedDuotoneIcon extends StatefulWidget {
  final String name;
  final double size;
  final Color? strokeColor;
  final Color? fillColor;
  final Color? accentColor;
  final Color? color; // Legacy

  const CachedDuotoneIcon(
    this.name, {
    super.key,
    this.size = 24,
    this.strokeColor,
    this.fillColor,
    this.accentColor,
    this.color,
  });

  @override
  State<CachedDuotoneIcon> createState() => _CachedDuotoneIconState();
}

class _CachedDuotoneIconState extends State<CachedDuotoneIcon> {
  String? _processedSvg;
  Color? _lastStrokeColor;
  Color? _lastFillColor;
  Color? _lastAccentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final strokeColor = widget.strokeColor ?? widget.color ?? (isDark ? Colors.white : Colors.black);
    final fillColor = widget.fillColor ?? strokeColor;
    final accentColor = widget.accentColor ?? _getAccentColor(context);

    // Check if we need to reload
    if (_processedSvg == null ||
        _lastStrokeColor != strokeColor ||
        _lastFillColor != fillColor ||
        _lastAccentColor != accentColor) {
      _loadSvg(strokeColor, fillColor, accentColor);
    }

    if (_processedSvg == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    return SvgPicture.string(
      _processedSvg!,
      width: widget.size,
      height: widget.size,
    );
  }

  Color _getAccentColor(BuildContext context) {
    try {
      final accentIndex = accentColorIndex.value;
      final colors = [
        Colors.blue,
        Colors.purple,
        Colors.pink,
        Colors.red,
        Colors.orange,
        Colors.amber,
        Colors.green,
        Colors.teal,
        Colors.cyan,
        Colors.indigo,
      ];
      return colors[accentIndex % colors.length];
    } catch (_) {
      return Theme.of(context).colorScheme.primary;
    }
  }

  Future<void> _loadSvg(Color strokeColor, Color fillColor, Color accentColor) async {
    try {
      final svgString = await rootBundle.loadString(
        'assets/icons/${widget.name}.svg',
      );

      if (!mounted) return;

      setState(() {
        _processedSvg = _processSvg(svgString, strokeColor, fillColor, accentColor);
        _lastStrokeColor = strokeColor;
        _lastFillColor = fillColor;
        _lastAccentColor = accentColor;
      });
    } catch (e) {
      // Silently fail
    }
  }

  String _processSvg(String svg, Color strokeColor, Color fillColor, Color accentColor) {
    final strokeHex = _colorToHex(strokeColor);
    final fillHex = _colorToHex(fillColor);
    final accentHex = _colorToHex(accentColor);

    var processed = svg.replaceAll('stroke="#1c1f21"', 'stroke="$strokeHex"');

    processed = processed.replaceAll(
      RegExp(r'fill="#1c1f21"(?!\s+fill-opacity)'),
      'fill="$fillHex"',
    );

    processed = processed.replaceAll(
      RegExp(r'fill="#1c1f21"\s+fill-opacity="0\.3"'),
      'fill="$accentHex"',
    );

    processed = processed.replaceAll(
      RegExp(r'opacity="0\.3"\s*fill="#1c1f21"'),
      'fill="$accentHex"',
    );

    return processed;
  }

  String _colorToHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }
}
