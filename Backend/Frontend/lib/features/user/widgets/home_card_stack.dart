import 'package:flutter/material.dart';
import '../../../shared/widgets/queue_card.dart';

class HomeCardStack extends StatefulWidget {
  final List<Map<String, dynamic>> cardData;
  final List<Color> cardColors;

  const HomeCardStack({
    Key? key,
    required this.cardData,
    required this.cardColors,
  }) : super(key: key);

  @override
  State<HomeCardStack> createState() => _HomeCardStackState();
}

class _HomeCardStackState extends State<HomeCardStack> {
  List<int> cardOrder = [0, 1, 2];

  void changeCardOrder(int cardId, int currentIndex) {
    setState(() {
      cardOrder.remove(cardId);
      cardOrder.insert(0, cardId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          for (int i = 0; i < cardOrder.length; i++)
            QueueCard(
              color: widget.cardColors[cardOrder[i]],
              index: i,
              value: cardOrder[i],
              title: widget.cardData[cardOrder[i]]['title'],
              subtitle: widget.cardData[cardOrder[i]]['subtitle'],
              icon: widget.cardData[cardOrder[i]]['icon'],
              buttonText: widget.cardData[cardOrder[i]]['buttonText'],
              onPressed: () => widget.cardData[cardOrder[i]]['onPressed'](context),
              onDragged: () => changeCardOrder(cardOrder[i], i),
            ),
        ],
      ),
    );
  }
}