import 'package:flutter/material.dart';

class PromoCarousel extends StatefulWidget {
  @override
  _PromoCarouselState createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentIndex = 0;

  final List<String> images = [
    'assets/yogabar.png',
    'assets/oats.png',
    'assets/healthy_snacks.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200, // Adjust height as needed
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: _currentIndex == index ? 0 : 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: AssetImage(images[index]),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: _currentIndex == index
                      ? [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)]
                      : [],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              width: _currentIndex == index ? 12 : 8,
              height: _currentIndex == index ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index ? Color(0xFF0D244A) : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
