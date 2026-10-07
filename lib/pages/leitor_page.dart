
import 'dart:async';

import 'package:flutter/material.dart';

import '../data/book_content_service.dart';
import '../data/reading_repository.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';
import '../widgets/book_cover.dart';
import '../widgets/round_back_button.dart';

class LeitorPage extends StatefulWidget {
  const LeitorPage({super.key, required this.book});

  final Book book;

  @override
  State<LeitorPage> createState() => _LeitorPageState();
}

class _LeitorPageState extends State<LeitorPage> {
  final _scrollController = ScrollController();

  String? _content;
  String? _error;
  bool _loading = true;
  bool _darkMode = false;
  double _fontSize = 20;
  double _progress = 0;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  Future<void> _load() async {
    try {
      final saved = await ReadingRepository.getProgress(widget.book.id);
      final content = await BookContentService.load(widget.book.contentUrl!, widget.book.title);

      if (!mounted) return;
      setState(() {
        _progress = saved;
        _content = content;
        _loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        final target = _scrollController.position.maxScrollExtent * saved;
        _scrollController.jumpTo(target.clamp(0.0, _scrollController.position.maxScrollExtent));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Não foi possível abrir a obra agora. Verifique sua conexão com a internet e tente novamente.';
        _loading = false;
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final value = max <= 0 ? 0.0 : (_scrollController.offset / max).clamp(0.0, 1.0);

    setState(() => _progress = value);

    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 350), () {
      ReadingRepository.saveProgress(widget.book.id, value);
    });
  }

  Future<void> _saveNow() async {
    await ReadingRepository.saveProgress(widget.book.id, _progress);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _saveNow();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _changeFont(double delta) {
    setState(() => _fontSize = (_fontSize + delta).clamp(15.0, 30.0));
  }

  @override
  Widget build(BuildContext context) {
    final background = _darkMode ? const Color(0xFF111111) : const Color(0xFFFCFCFC);
    final textColor = _darkMode ? const Color(0xFFF0F0F0) : const Color(0xFF111111);
    final muted = _darkMode ? const Color(0xFFBDBDBD) : const Color(0xFF6E6E6E);
    final accent = _darkMode ? const Color(0xFF77B8FF) : const Color(0xFF1683F5);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          if (_loading)
            Center(
              child: CircularProgressIndicator(color: accent),
            )
          else if (_error != null)
            _ErrorView(message: _error!, onRetry: _load, darkMode: _darkMode)
          else
            _ReaderContent(
              controller: _scrollController,
              book: widget.book,
              content: _content ?? '',
              fontSize: _fontSize,
              textColor: textColor,
              mutedColor: muted,
              accent: accent,
              background: background,
            ),

          // Percentual fixo, como no modelo enviado.
          Positioned(
            top: 20,
            left: 28,
            child: Text(
              '${(_progress * 100).round()}%',
              style: TextStyle(
                color: accent,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Positioned(
            top: 18,
            right: 28,
            child: _ReaderThemeSwitch(
              darkMode: _darkMode,
              onChanged: (value) => setState(() => _darkMode = value),
            ),
          ),

          Positioned(
            left: 24,
            top: 62,
            child: Material(
              color: background.withValues(alpha: 0.92),
              shape: const CircleBorder(),
              child: RoundBackButton(
                onPressed: () async {
                  await _saveNow();
                  if (mounted) Navigator.of(context).pop();
                },
              ),
            ),
          ),

          Positioned(
            right: 28,
            bottom: 28,
            child: _FontControls(
              onDecrease: () => _changeFont(-1),
              onIncrease: () => _changeFont(1),
              darkMode: _darkMode,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReaderContent extends StatelessWidget {
  const _ReaderContent({
    required this.controller,
    required this.book,
    required this.content,
    required this.fontSize,
    required this.textColor,
    required this.mutedColor,
    required this.accent,
    required this.background,
  });

  final ScrollController controller;
  final Book book;
  final String content;
  final double fontSize;
  final Color textColor;
  final Color mutedColor;
  final Color accent;
  final Color background;

  bool _isHeading(String value) {
    final line = value.trim();
    if (line.length > 70) return false;
    if (RegExp(r'^(CAPÍTULO|CAPITULO)\s+\d+', caseSensitive: false).hasMatch(line)) return true;
    if (RegExp(r'^[IVXLCDM]{1,8}\.?$').hasMatch(line)) return true;
    if (line == line.toUpperCase() && RegExp(r'[A-ZÁÉÍÓÚÃÕÇ]').hasMatch(line) && line.length > 3) return true;
    return false;
  }

  List<Widget> _blocks(BuildContext context) {
    final parts = content
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    final widgets = <Widget>[];
    var chapterNumber = 0;

    for (final part in parts) {
      if (_isHeading(part)) {
        chapterNumber++;
        final title = part == 'I' || part == 'I.' ? 'CAPÍTULO $chapterNumber' : part;

        widgets.add(
          Container(
            margin: const EdgeInsets.only(top: 32, bottom: 22),
            padding: const EdgeInsets.only(left: 14),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: accent, width: 5)),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontFamily: 'Georgia',
                fontSize: 25,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              part,
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: textColor,
                fontFamily: 'Georgia',
                fontSize: fontSize,
                height: 1.75,
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      child: ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(24, 105, 24, 120),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    style: TextStyle(
                      color: textColor,
                      fontFamily: 'Georgia',
                      fontSize: 43,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    book.author,
                    style: TextStyle(
                      color: mutedColor,
                      fontFamily: 'Georgia',
                      fontSize: 21,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Divider(color: mutedColor.withValues(alpha: 0.25), height: 1),
                  ..._blocks(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReaderThemeSwitch extends StatelessWidget {
  const _ReaderThemeSwitch({required this.darkMode, required this.onChanged});

  final bool darkMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 142,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF72C5F4),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x22000000))],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                decoration: BoxDecoration(
                  color: darkMode ? const Color(0xFF26364D) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.nightlight_round, color: Color(0xFF173252)),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                decoration: BoxDecoration(
                  color: !darkMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(
                  darkMode ? 'Escuro' : 'Claro',
                  style: const TextStyle(
                    color: Color(0xFF173252),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FontControls extends StatelessWidget {
  const _FontControls({
    required this.onDecrease,
    required this.onIncrease,
    required this.darkMode,
  });

  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    final background = darkMode ? const Color(0xFF252525) : const Color(0xFFF7F7F7);
    final foreground = darkMode ? Colors.white : const Color(0xFF202020);

    return Row(
      children: [
        _FontButton(label: '-', onPressed: onDecrease, background: background, foreground: foreground),
        const SizedBox(width: 8),
        _FontButton(label: '+', onPressed: onIncrease, background: background, foreground: foreground),
      ],
    );
  }
}

class _FontButton extends StatelessWidget {
  const _FontButton({
    required this.label,
    required this.onPressed,
    required this.background,
    required this.foreground,
  });

  final String label;
  final VoidCallback onPressed;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: foreground.withValues(alpha: 0.15)),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Text(label, style: TextStyle(color: foreground, fontSize: 20, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry, required this.darkMode});

  final String message;
  final VoidCallback onRetry;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    final color = darkMode ? Colors.white : const Color(0xFF15294E);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: color),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 16)),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}
