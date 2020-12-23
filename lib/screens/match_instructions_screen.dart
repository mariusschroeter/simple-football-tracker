import 'package:flutter/material.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:simple_football_tracker/widgets/global_colors.dart';
import 'package:introduction_screen/introduction_screen.dart';

class MatchInstructionsScreen extends StatefulWidget {
  final Function onClose;

  MatchInstructionsScreen({this.onClose});

  @override
  _MatchInstructionsScreenState createState() =>
      _MatchInstructionsScreenState();
}

class _MatchInstructionsScreenState extends State<MatchInstructionsScreen>
    with SingleTickerProviderStateMixin {
  final introKey = GlobalKey<IntroductionScreenState>();
  GifController gifController;

  @override
  void initState() {
    super.initState();
    gifController = GifController(vsync: this);
  }

  void _onIntroEnd(context) {
    widget.onClose();
  }

  @override
  void dispose() {
    gifController.dispose();
    super.dispose();
  }

  Widget _buildImage(String assetName, double maxFrame) {
    gifController.repeat(min: 0, max: maxFrame, period: Duration(seconds: 5));
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(top: statusBarHeight + 8),
      child: GifImage(
        height: 400,
        controller: gifController,
        fit: BoxFit.cover,
        image: AssetImage(
          'lib/resources/gifs/$assetName.gif',
        ),
      ),
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
      pageColor: Theme.of(context).scaffoldBackgroundColor,
      imagePadding: EdgeInsets.zero,
      imageFlex: 1,
      titlePadding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
      descriptionPadding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Start the game",
          body: "Choose which team has the ball and start the game",
          image: Center(child: _buildImage('start_match', 75)),
          decoration: pageDecoration,
          footer: null,
        ),
        PageViewModel(
          title: "Track current ball position",
          body: "Tap on the corresponding zone to track possession",
          image: Center(child: _buildImage('track_possession', 53)),
          decoration: pageDecoration,
          footer: null,
        ),
        PageViewModel(
          title: "Switch ball possession",
          body: "Double tap to switch the team currently in possession",
          image: Center(child: _buildImage('switch_possession', 53)),
          decoration: pageDecoration,
          footer: null,
        ),
        PageViewModel(
          title: "Track shots",
          body:
              "Hold and drag the ball to the corresponding goal and release to determine the shots outcome",
          image: Center(child: _buildImage('track_shots', 53)),
          decoration: pageDecoration,
          footer: null,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
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
