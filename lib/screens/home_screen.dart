import 'package:demo/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final List<String> promoImages = [
    'assets/yogabar.png',
    'assets/healthy_snacks.png',
    'assets/oats.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // Peach Background
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              height: 350,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D244A), Color(0xFF1A1F3C)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Light Background Overlay
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.08,
                      child: Image.asset(
                        'assets/images/healthy_food_bg.png', // Add a premium pattern image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 40,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 50), // More breathing space
                        Text(
                          "Welcome to NutriScan",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Your AI-powered Nutrition Assistant",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 20),

                        // Call to Action Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF1AA8F), // Soft Orange
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            // Navigate to scan screen or another section
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Start Scanning",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Promotional Carousel
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Explore Healthy Choices",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D244A),
                ),
              ),
            ),
            SizedBox(height: 10),
            PromoCarousel(),
            SizedBox(height: 20),

            // Services Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Our Services",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D244A),
                    ),
                  ),
                  SizedBox(height: 10),
                  FeatureTile(
                    icon: Icons.qr_code_scanner,
                    title: "Food Scanning",
                    description:
                        "Scan any food product to get detailed nutritional insights.",
                  ),
                  FeatureTile(
                    icon: Icons.analytics,
                    title: "AI-Based Analysis",
                    description:
                        "Our AI recommends the best food for your health.",
                  ),
                  FeatureTile(
                    icon: Icons.health_and_safety,
                    title: "Personalized Health Tips",
                    description: "Get daily diet & health recommendations.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        onScanPressed: () => Navigator.pushNamed(context, '/scan'),
        onHomePressed: () => Navigator.pushNamed(context, '/home'),
        onProfilePressed: () => null,
        onLogoutPressed: () => Navigator.pushNamed(context, '/login'),
      ),

      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFFF1AA8F), // Soft Orange
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
        onPressed: () => Navigator.pushNamed(context, '/scan'),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// Promo Carousel (Alternative to dependencies)
class PromoCarousel extends StatefulWidget {
  @override
  _PromoCarouselState createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentIndex = 0;

  final List<String> images = [
    'assets/yogabar.png',
    'assets/healthy_snacks.png',
    'assets/oats.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
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
                margin: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: _currentIndex == index ? 0 : 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: AssetImage(images[index]),
                    fit: BoxFit.cover,
                  ),
                  boxShadow:
                      _currentIndex == index
                          ? [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
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
                color:
                    _currentIndex == index
                        ? Color(0xFF0D244A)
                        : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Feature Tile
class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFFF1AA8F), size: 30),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D244A),
          ),
        ),
        subtitle: Text(description, style: TextStyle(color: Colors.black54)),
      ),
    );
  }
}
