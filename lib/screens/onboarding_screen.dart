import 'package:corider/providers/user_state.dart';
import 'package:flutter/material.dart';
import 'root.dart';

class OnboardingScreen extends StatefulWidget {
  final UserState userState;
  const OnboardingScreen({super.key, required this.userState});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<Widget> _pages = [
    const OnboardingPage(
      backgroundColor: Colors.lightBlue,
      title: 'Welcome to CoRider',
      description:
          'Welcome to CoRider, your company-wide carpooling solution. With CoRider carpooling, you can contribute to a greener environment while enjoying a more efficient and enjoyable commute. Join us in reducing traffic congestion and promoting sustainable transportation options for our workplace community.',
    ),
    const OnboardingPage(
      backgroundColor: Colors.lightBlue,
      title: 'Find a Ride',
      description:
          "With CoRider, finding a ride is a breeze. Browse through available rides shared by your colleagues and select the one that fits your schedule and route. Say goodbye to the hassle of driving alone and join fellow employees for a comfortable and cost-effective commute. Let's make carpooling a part of our daily routine.",
    ),
    const OnboardingPage(
      backgroundColor: Colors.lightBlue,
      title: 'Offer a Ride',
      description:
          "Share the ride, share the benefits. By offering a ride on CoRider, you can help your colleagues reach their destinations conveniently while reducing their carbon footprint. Offer your available seats, set your preferred route, and connect with coworkers who are heading in the same direction. Together, let's make our commutes more efficient, social, and eco-friendly.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (BuildContext context, int index) {
              return _pages[index];
            },
          ),
          Positioned(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPageIndicator(),
                _currentPage != _pages.length - 1
                    ? TextButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => RootNavigationView(
                              userState: widget.userState,
                            ),
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(_pages.length, (int index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          width: _currentPage == index ? 16.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.white : Colors.grey,
          ),
        );
      }),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.backgroundColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
