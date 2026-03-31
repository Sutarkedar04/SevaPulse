import 'package:flutter/material.dart';

class QueueCard extends StatefulWidget {
  final Color color;
  final int index;
  final int value;
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonText;
  final VoidCallback onPressed;
  final VoidCallback onDragged;

  const QueueCard({
    Key? key,
    required this.color,
    required this.index,
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonText,
    required this.onPressed,
    required this.onDragged,
  }) : super(key: key);

  @override
  State<QueueCard> createState() => _QueueCardState();
}

class _QueueCardState extends State<QueueCard> {
  bool _isDragging = false;
  double _dragOffset = 0.0;

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    
    if (_dragOffset.abs() > 30) {
      widget.onDragged();
    }
    
    _dragOffset = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    
    const double cardWidth = 320;
    const double cardHeight = 200;
    
    Map<int, Map<String, double>> queuePositions = {
      0: {
        'top': 20.0,
        'left': -30,
        'scale': 1.0,
        'elevation': 12.0,
        'opacity': 1.0,
      },
      1: {
        'top': 40.0,
        'left': -10,
        'scale': 0.95,
        'elevation': 8.0,
        'opacity': 0.9,
      },
      2: {
        'top': 60.0,
        'left': 10,
        'scale': 0.9,
        'elevation': 4.0,
        'opacity': 0.8,
      },
    };

    final position = queuePositions[widget.index]!;
    final double top = position['top']!;
    final double left = position['left']!;
    final double scale = position['scale']!;
    final double elevation = position['elevation']!;
    final double opacity = position['opacity']!;

    double horizontalOffset = _isDragging ? _dragOffset : 0.0;

    return AnimatedPositioned(
      duration: Duration(milliseconds: _isDragging ? 0 : 300),
      top: top,
      left: ((screenWidth - cardWidth) / 2) + left + horizontalOffset,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        behavior: HitTestBehavior.translucent,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: _isDragging ? 0 : 300),
          opacity: opacity,
          child: AnimatedScale(
            duration: Duration(milliseconds: _isDragging ? 0 : 300),
            scale: scale,
            child: Card(
              elevation: elevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color,
                      widget.color.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 28,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${widget.index + 1}/3',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: widget.onPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: widget.color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: Text(
                                widget.buttonText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}