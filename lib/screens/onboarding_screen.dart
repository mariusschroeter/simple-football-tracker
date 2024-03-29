import 'package:flutter/material.dart';
import 'package:simple_football_tracker/screens/matches_screen.dart';
import 'package:simple_football_tracker/widgets/global_colors.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MatchesScreen()),
    );
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset(
        'lib/resources/images/soccertest.jpg',
      ),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = TextStyle(
      fontSize: 19.0,
      color: Colors.white,
      height: 1.25,
    );
    final pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
          fontSize: 28.0, fontWeight: FontWeight.w700, color: Colors.white),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Theme.of(context).scaffoldBackgroundColor,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          titleWidget: SizedBox(
            height: 0,
          ),
          bodyWidget: Container(
            child: Column(
              children: [
                TextField(),
                TextField(),
              ],
            ),
          ),
          image: _buildImage('img2'),
          footer: RaisedButton(
            onPressed: () {
              introKey.currentState?.animateScroll(0);
            },
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
            color: GlobalColors.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: SizedBox(
            height: 0,
          ),
          bodyWidget: Container(
            child: Column(
              children: [
                TextField(),
                TextField(),
              ],
            ),
          ),
          image: _buildImage('img2'),
          footer: RaisedButton(
            onPressed: () {
              introKey.currentState?.animateScroll(0);
            },
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
            color: GlobalColors.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Login'),
      next: const Text('Register'),
      done: const Text(''),
      dotsDecorator: DotsDecorator(
        activeColor: GlobalColors.primary,
        size: Size(10.0, 10.0),
        color: GlobalColors.primary,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
