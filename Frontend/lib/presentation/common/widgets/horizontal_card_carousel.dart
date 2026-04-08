// lib/shared/widgets/horizontal_card_carousel.dart
import 'package:flutter/material.dart';
import 'dart:async';

class HorizontalCardCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> cardData;
  final List<Color> cardColors;
  final Duration autoSlideInterval;

  const HorizontalCardCarousel({
    Key? key,
    required this.cardData,
    required this.cardColors,
    this.autoSlideInterval = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  State<HorizontalCardCarousel> createState() => _HorizontalCardCarouselState();
}

class _HorizontalCardCarouselState extends State<HorizontalCardCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;
  bool _isAutoSliding = true;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(widget.autoSlideInterval, (timer) {
      if (_isAutoSliding && !_isDragging && mounted && widget.cardData.isNotEmpty) {
        if (_currentPage < widget.cardData.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _stopAutoSlide() {
    setState(() {
      _isAutoSliding = false;
    });
  }

  void _resumeAutoSlide() {
    setState(() {
      _isAutoSliding = true;
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cardData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 260, // Reduced height to prevent overflow
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollStartNotification) {
                setState(() {
                  _isDragging = true;
                });
                _stopAutoSlide();
              } else if (notification is ScrollEndNotification) {
                setState(() {
                  _isDragging = false;
                });
                _resumeAutoSlide();
                _startAutoSlide();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: widget.cardData.length,
              itemBuilder: (context, index) {
                return _buildCard(
                  widget.cardData[index],
                  widget.cardColors[index % widget.cardColors.length],
                  index,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.cardData.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _currentPage == index
                    ? const Color(0xFF3498db)
                    : const Color(0xFFbdc3c7),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Auto-slide controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: const Color(0xFFecf0f1),
              ),
              child: _isAutoSliding
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        return AnimatedContainer(
                          duration: widget.autoSlideInterval,
                          width: constraints.maxWidth * 
                              ((_currentPage + 1) / widget.cardData.length),
                          height: 2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1),
                            color: const Color(0xFF3498db),
                          ),
                        );
                      },
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                _isAutoSliding ? Icons.pause : Icons.play_arrow,
                size: 14,
                color: const Color(0xFF7f8c8d),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  if (_isAutoSliding) {
                    _stopAutoSlide();
                  } else {
                    _resumeAutoSlide();
                    _startAutoSlide();
                  }
                });
              },
              tooltip: _isAutoSliding ? 'Pause auto-slide' : 'Resume auto-slide',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> data, Color color, int index) {
    return GestureDetector(
      onTap: () {
        _stopAutoSlide();
        if (data['onPressed'] != null) {
          data['onPressed'](context);
        }
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && !_isDragging) {
            _resumeAutoSlide();
            _startAutoSlide();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              // ignore: deprecated_member_use
              color.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  data['icon'],
                  size: 100,
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row with icon and page indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            data['icon'],
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${index + 1}/${widget.cardData.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Title
                    Text(
                      data['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      data['subtitle'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (data['onPressed'] != null) {
                            data['onPressed'](context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          data['buttonText'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}