import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_motion_design_samples/logininteraction/custom_painters.dart';

//The scene state that the screen is likely to be in.
enum CURRENT_SCREEN_STATE {
  INIT_STATE,
  REVEALING_ANIMATING_STATE,
  POST_REVEAL_STATE,
}

class LoginInteractionScreen extends StatefulWidget {
  final double height, width;

  final WidgetBuilder leftPage, rightPage;

  const LoginInteractionScreen(
      this.height, this.width, this.leftPage, this.rightPage);

  @override
  State<StatefulWidget> createState() {
    return _LoginInteractionScreenState();
  }
}

class _LoginInteractionScreenState extends State<LoginInteractionScreen>
    with TickerProviderStateMixin {
  final double arcHeight = 130;

  late final AnimationController _revealAnimationController,
      _postRevealAnimationController,
      _tabSelectionAnimationController,
      _swipeUpBounceAnimationController,
      _amoebaAnimationController;

  late Animation<double> _swipeArcAnimation;
  late final ScrollController _scrollController;

  late final double _swipeDistance;
  late double _swipeUpDy;
  late final double _initialCurveHeight, _finalCurveHeight;

  CURRENT_SCREEN_STATE currentScreenState = CURRENT_SCREEN_STATE.INIT_STATE;

  late final Animation<RelativeRect> _titleBaseLinePosTranslateAnim,
      _sideIconsTranslateAnim,
      _pageViewPosAnimation;

  late final Animation<double> _centerIconScale;

  late final Animation<double> _swipeArchHeightAnimation;

  Animation<RelativeRect>? _tabSelectionAnimation;

  Animation<double>? _tabRippleEffectAnimation;
  late bool isLeftTabSelected;

  late final Animation<double> _swipeUpBounceAnimation;
  late final Animation<Offset> _amoebaOffsetAnimation;

  late final PageController _pageViewController;

  @override
  void initState() {
    super.initState();
    _swipeDistance = 160;
    _initialCurveHeight = widget.height * .35;
    _finalCurveHeight = widget.height * .65;
    _scrollController = ScrollController();
    _scrollController.addListener(_handleSwipe);
    _swipeUpDy = 0;

    isLeftTabSelected = true;

    //Animation Controller for amoeba bg
    _amoebaAnimationController =
        AnimationController(duration: Duration(milliseconds: 350), vsync: this);

    _amoebaOffsetAnimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(-20, -70)).animate(
            CurvedAnimation(
                parent: _amoebaAnimationController,
                curve: Curves.easeInOutBack));

    //Animation Controller for setting bounce animation for "Swipe up" text widget
    _swipeUpBounceAnimationController =
        AnimationController(duration: Duration(milliseconds: 800), vsync: this)
          ..repeat(reverse: true);

    //Animation for actual bounce effect
    _swipeUpBounceAnimation = Tween<double>(begin: 0, end: -20).animate(
        CurvedAnimation(
            parent: _swipeUpBounceAnimationController,
            curve: Curves.easeOutBack))
      ..addListener(() {
        setState(() {
          _swipeUpDy = _swipeUpBounceAnimation.value;
        });
      });

    //We want to loop bounce effect until user intercepts with drag touch event.
    _swipeUpBounceAnimationController.repeat(reverse: true);

    //Animation Controller for selecting tab header after reveal animation is completed
    _tabSelectionAnimationController = AnimationController(
        duration: Duration(milliseconds: 1200), vsync: this);

    //Animation controller for expanding the curve animation
    _revealAnimationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed)
              setState(() {
                currentScreenState = CURRENT_SCREEN_STATE.POST_REVEAL_STATE;
                _postRevealAnimationController.forward();
              });
          });

    //Animation to translate the brand label
    _titleBaseLinePosTranslateAnim = RelativeRectTween(
            begin: RelativeRect.fromLTRB(
                0,
                widget.height -
                    _initialCurveHeight -
                    widget.height * .2 -
                    arcHeight,
                0,
                _initialCurveHeight),
            end: RelativeRect.fromLTRB(
                0,
                widget.height - _finalCurveHeight - 20 - arcHeight,
                0,
                _finalCurveHeight))
        .animate(CurvedAnimation(
            parent: _revealAnimationController, curve: Curves.easeOutBack));

    //Animation to translate side icons
    _sideIconsTranslateAnim = RelativeRectTween(
            begin: RelativeRect.fromLTRB(
                0,
                widget.height -
                    _initialCurveHeight -
                    widget.height * .25 -
                    arcHeight,
                0,
                _initialCurveHeight),
            end: RelativeRect.fromLTRB(
                0,
                widget.height -
                    _finalCurveHeight -
                    widget.height * .25 -
                    arcHeight,
                0,
                _finalCurveHeight))
        .animate(CurvedAnimation(
            parent: _revealAnimationController, curve: Curves.easeInOutBack));

    //Tween for animating height of the curve during reveal process
    _swipeArcAnimation =
        Tween<double>(begin: _initialCurveHeight, end: _finalCurveHeight)
            .animate(CurvedAnimation(
                parent: _revealAnimationController, curve: Curves.easeInCubic));

    //Animation for the mid control point of cubic bezier curve to show acceleration effect in response to user drag.
    _swipeArchHeightAnimation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: 200),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 200, end: 0),
          weight: 50.0,
        ),
      ],
    ).animate(CurvedAnimation(
        parent: _revealAnimationController, curve: Curves.easeInCubic));

    //Animation controller for showing animation after reveal
    _postRevealAnimationController =
        AnimationController(duration: Duration(milliseconds: 650), vsync: this);

    //Scale animation for showing center logo after reveal is completed
    _centerIconScale = Tween<double>(begin: 0, end: .5).animate(CurvedAnimation(
      parent: _postRevealAnimationController,
      curve: Curves.fastOutSlowIn,
    ));

    _pageViewPosAnimation = RelativeRectTween(
            begin: RelativeRect.fromLTRB(0, widget.height, 0, 0),
            end: RelativeRect.fromLTRB(
              0,
              widget.height - _finalCurveHeight,
              0,
              0,
            ))
        .animate(CurvedAnimation(
            parent: _postRevealAnimationController, curve: Curves.easeOutCirc));

    _pageViewController = PageController();
  }

  /// We are adding required widgets on the basis of the scene selected and positioning them and as per the scene we
  ///are orchestrating the animation.
  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];

    switch (currentScreenState) {
      case CURRENT_SCREEN_STATE.INIT_STATE:
        stackChildren.addAll(_getBgWidgets());
        stackChildren.addAll(_getDefaultWidgets());
        stackChildren.addAll(_getInitScreenWidgets());
        stackChildren.add(_getBrandTitle());

        break;
      case CURRENT_SCREEN_STATE.REVEALING_ANIMATING_STATE:
        stackChildren.addAll(_getBgWidgets());
        stackChildren.addAll(_getDefaultWidgets());
        stackChildren.add(_getBrandTitle());
        break;
      case CURRENT_SCREEN_STATE.POST_REVEAL_STATE:
        stackChildren.addAll(_getBgWidgets());
        stackChildren.addAll(_getDefaultWidgets());
        stackChildren.add(_getCurvedPageSwitcher());
        stackChildren.addAll(_getPostRevealAnimationStateWidgets());
        stackChildren.add(buildPages());
        break;
    }

    return Stack(children: stackChildren);
  }

  @override
  void dispose() {
    _revealAnimationController.dispose();
    _postRevealAnimationController.dispose();
    _tabSelectionAnimationController.dispose();
    _swipeUpBounceAnimationController.dispose();
    _amoebaAnimationController.dispose();
    super.dispose();
  } //List of widgets that every scene needs.

  List<Widget> _getDefaultWidgets() {
    return [
      Positioned.fill(
        child: CustomPaint(
          painter: SwipeToDragBg(
              _swipeArcAnimation, _swipeArchHeightAnimation, arcHeight),
        ),
      ),
      PositionedTransition(
          rect: _sideIconsTranslateAnim,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 38),
                child: IgnorePointer(
                  child: SizedBox(
                      height: 100,
                      width: 100,
                      child: Image(
                          image: AssetImage("assets/coin_star_left.png"))),
                ),
              ),
              Expanded(
                child: Container(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 38),
                child: IgnorePointer(
                  child: SizedBox(
                      height: 100,
                      width: 100,
                      child: Image(
                          image: AssetImage("assets/coin_star_right.png"))),
                ),
              )
            ],
          ))
    ];
  }

  //List of widgets for init state of the screen.
  List<Widget> _getInitScreenWidgets() {
    return [
      Positioned(
        right: 0,
        left: 0,
        bottom: 0,
        child: Container(
          height: widget.height * .5,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            child: Container(
              height: widget.height * .5 + .1,
              // color:Colors.yellow,
            ),
          ),
        ),
      ),
      Positioned(
          right: 0,
          left: 0,
          bottom: widget.height * .05,
          child: Transform.translate(
              offset: Offset(0, _swipeUpDy),
              child: IgnorePointer(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_rounded,
                        color: Colors.deepPurple,
                        size: 52,
                      ),
                      Text(
                        "Swipe up to start",
                        style: TextStyle(color: Colors.grey),
                      )
                    ]),
              ))),
    ];
  }

  //Since brand title is common to multiple scene, we refactored into seperate method

  //List of widgets for reveal animation scene
  List<Widget> _getPostRevealAnimationStateWidgets() {
    return [
      Positioned.fromRelativeRect(
        rect: _titleBaseLinePosTranslateAnim.value.shift(Offset(0, 18)),
        child: ScaleTransition(
            scale: _centerIconScale,
            child: FloatingActionButton(
                backgroundColor: Colors.white,
                elevation: 5,
                onPressed: null,
                child: Icon(Icons.monetization_on_outlined,
                    size: 100,
                    color: isLeftTabSelected
                        ? Colors.deepPurple
                        : Colors.pinkAccent))),
      ),
    ];
  }

  Widget _getBrandTitle() {
    return PositionedTransition(
        rect: _titleBaseLinePosTranslateAnim,
        child: Center(
            child: Text("B\$D",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800))));
  }

  Widget _getCurvedPageSwitcher() {
    return Positioned(
      top: 0,
      bottom: _titleBaseLinePosTranslateAnim.value.bottom,
      left: 0,
      right: 0,
      child: CurvePageSwitchIndicator(widget.height, widget.width, arcHeight, 3,
          true, _onLeftTabSelectd, _onRightTabSelectd),
    );
  }

  //Intercepts the bounce animation and start dragg animation
  void _handleSwipe() {
    _swipeUpBounceAnimationController.stop(canceled: true);
    double dy = _scrollController.position.pixels;

    double scrollRatio =
        math.min(1.0, _scrollController.position.pixels / _swipeDistance);

    //If user scroll 70% of the scrolling region we proceed towards reveal animation
    if (scrollRatio > .7)
      _playRevealAnimation();
    else
      setState(() {
        _swipeUpDy = dy * -1;
      });
  }

  //Update scene state to "reveal" and start corresponding animation
  void _playRevealAnimation() {
    setState(() {
      currentScreenState = CURRENT_SCREEN_STATE.REVEALING_ANIMATING_STATE;
      _revealAnimationController.forward();
      _amoebaAnimationController.forward();
    });
  }

  //Callback when right tab is tapped. Animate the clip path region toward left so only right portion is visible
  void _onRightTabSelectd() {
    setState(() {
      isLeftTabSelected = false;
      _tabSelectionAnimation = RelativeRectTween(
              begin: RelativeRect.fromLTRB(0, 0, 0, 0),
              end: RelativeRect.fromLTRB(widget.width, 0, 0, 0))
          .animate(CurvedAnimation(
              parent: _tabSelectionAnimationController,
              curve: Curves.easeOutBack));

      _tabRippleEffectAnimation =
          Tween<double>(begin: 0, end: TAB_RIPPLE_RADIUS).animate(
              CurvedAnimation(
                  parent: _tabSelectionAnimationController,
                  curve: Curves.ease));

      _pageViewController.animateToPage(1,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      _tabSelectionAnimationController.forward(from: 0);
    });
  }

  //Callback when left tab is tapped. Animate the clip path region toward right so only left portion is visible
  void _onLeftTabSelectd() {
    setState(() {
      isLeftTabSelected = true;
      _tabSelectionAnimation = RelativeRectTween(
              begin: RelativeRect.fromLTRB(0, 0, 0, 0),
              end: RelativeRect.fromLTRB(0, 0, widget.width, 0))
          .animate(CurvedAnimation(
              parent: _tabSelectionAnimationController,
              curve: Curves.easeOutBack));

      _tabRippleEffectAnimation =
          Tween<double>(begin: 0, end: TAB_RIPPLE_RADIUS).animate(
              CurvedAnimation(
                  parent: _tabSelectionAnimationController,
                  curve: Curves.ease));

      _pageViewController.animateToPage(0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);

      _tabSelectionAnimationController.forward(from: 0);
    });
  }

  ///The background for selected tab. On the basis of tab selected, the foreground container is translated away,
  ///revealing the underlying background container. If the screen state is just set to reveal, then in the initial state no foreground container
  ///is added which is signified by _tabSelectionAnimation set to null. _tabSelectionAnimation is only set when either of the tab is pressed.
  List<Widget> _getBgWidgets() {
    List<Widget> widgets = [];
    Color foreGroundColor;
    Color backgroundColor;
    if (isLeftTabSelected) {
      foreGroundColor = Colors.deepPurple;
      backgroundColor = Colors.pink;
    } else {
      foreGroundColor = Colors.pink;
      backgroundColor = Colors.deepPurple;
    }

    widgets.add(Positioned.fill(child: Container(color: foreGroundColor)));

    if (_tabSelectionAnimation != null)
      widgets.add(PositionedTransition(
          rect: _tabSelectionAnimation!,
          child: Container(
            decoration: BoxDecoration(color: backgroundColor),
          )));
    // if(_tabRippleEffectAnimation!=null)
    //   widgets.add(Container(
    //     height: double.infinity,
    //     width: double.infinity,
    //     child: CustomPaint(
    //       painter: TabRippleEffect(_tabRippleEffectAnimation!,isLeftTabSelected),
    //     ),
    //   ));
    widgets.add(Container(
      height: double.infinity,
      width: double.infinity,
      child: CustomPaint(
        painter: AmoebaBg(_amoebaOffsetAnimation),
      ),
    ));

    return widgets;
  }

  //Add the respective page supplied by user
  Widget buildPages() {
    // return Positioned(
    //   left: 0,
    //   top: widget.height,
    //   bottom: 0,
    //   right: 0,
    //   child: Container(height: widget.height-_finalCurveHeight,color: Colors.yellow,
    //   )
    // );

    return PositionedTransition(
        rect: _pageViewPosAnimation,
        child: Container(
          height: widget.height - _finalCurveHeight,
          child: PageView(
            scrollDirection: Axis.horizontal,
            controller: _pageViewController,
            children: <Widget>[
              widget.leftPage(context),
              widget.rightPage(context)
            ],
            physics: NeverScrollableScrollPhysics(),
          ),
        ));
  }
}

//Widget that represents the curve arc tab selection portion of the scene.
class CurvePageSwitchIndicator extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;
  final double arcHeight;
  final double arcBottomOffset;
  final VoidCallback onLeftPageTapped, onRightPageTapped;
  final bool showLeftAsFirstPage;

  CurvePageSwitchIndicator(
      this.screenHeight,
      this.screenWidth,
      this.arcHeight,
      this.arcBottomOffset,
      this.showLeftAsFirstPage,
      this.onLeftPageTapped,
      this.onRightPageTapped);

  @override
  State<StatefulWidget> createState() {
    return _CurvePageSwitchIndicator();
  }
}

class _CurvePageSwitchIndicator extends State<CurvePageSwitchIndicator>
    with TickerProviderStateMixin {
  late bool showLeftAsFirstPage;

  AnimationController? pageTabAnimationController;

  late final AnimationController entryAnimationController;

  late final Animation<double> translationDxAnim,
      translationDyAnim,
      rotationAnim;

  ///When the reveal scene is completed, left tab is selected and the tab selection fly towards from the left side of the screen
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Transform(
          transform: Matrix4.identity()
            ..setEntry(0, 3, translationDxAnim.value)
            ..setEntry(1, 3, translationDyAnim.value)
            ..rotateZ(rotationAnim.value * 3.14 / 180),
          alignment: Alignment.bottomLeft,
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: CustomPaint(
              painter: CurvePageSwitcher(
                  widget.arcHeight,
                  widget.arcBottomOffset,
                  showLeftAsFirstPage,
                  pageTabAnimationController!),
            ),
          )),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
              child: Stack(children: [
            Positioned(
                left: 0,
                right: 20,
                bottom: 0,
                top: 90,
                child: Transform.rotate(
                    angle: -13 * 3.14 / 180,
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Login",
                          style: TextStyle(
                              color: showLeftAsFirstPage
                                  ? Colors.white
                                  : Colors.white60,
                              fontSize: 22,
                              fontWeight: FontWeight.w800),
                        )))),
            GestureDetector(
              onTap: _handleLeftTab,
            )
          ])),
          Expanded(
              child: Stack(children: [
            Positioned(
                left: 20,
                right: 0,
                bottom: 0,
                top: 90,
                child: Transform.rotate(
                    angle: 13 * 3.14 / 180,
                    child: Align(
                        alignment: Alignment.center,
                        child: Text("Signup",
                            style: TextStyle(
                                color: !showLeftAsFirstPage
                                    ? Colors.white
                                    : Colors.white60,
                                fontSize: 22,
                                fontWeight: FontWeight.w800))))),
            GestureDetector(
              onTap: _handleRightTab,
            )
          ])),
        ],
      ),
    ]);
  }

  @override
  void dispose() {
    entryAnimationController.dispose();
    super.dispose();
  }

  //Handle the left tab tapping and propogate the call to the supplied callback, so parent can add more effect to it.
  void _handleLeftTab() {
    if (this.showLeftAsFirstPage == true) return;
    _resetAnimationController();
    setState(() {
      this.showLeftAsFirstPage = true;
      pageTabAnimationController?.forward(from: 0);
      widget.onLeftPageTapped();
    });
  }

  //Handle the right tab tapping and propogate the call to the supplied callback, so parent can add more effect to it.
  void _handleRightTab() {
    if (this.showLeftAsFirstPage == false) return;
    _resetAnimationController();
    setState(() {
      this.showLeftAsFirstPage = false;
      pageTabAnimationController?.forward(from: 0);
      widget.onRightPageTapped();
    });
  }

  @override
  void initState() {
    super.initState();
    this.showLeftAsFirstPage = widget.showLeftAsFirstPage;
    //Animation Controller that translates the tab selection from the left side of the screen
    entryAnimationController =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    _resetAnimationController();
    translationDxAnim = Tween<double>(begin: -(widget.screenWidth / 2), end: 0)
        .animate(CurvedAnimation(
            parent: entryAnimationController, curve: Curves.decelerate));
    translationDyAnim = Tween<double>(begin: widget.arcHeight * .4, end: 0)
        .animate(CurvedAnimation(
            parent: entryAnimationController, curve: Curves.decelerate));
    rotationAnim = Tween<double>(begin: 350, end: 360).animate(CurvedAnimation(
        parent: entryAnimationController, curve: Curves.decelerate));
    pageTabAnimationController?.forward(from: 1);
    entryAnimationController.addListener(() {
      setState(() {});
    });
    entryAnimationController.forward(from: 0);
  }

  _resetAnimationController() {
    pageTabAnimationController?.dispose();
    pageTabAnimationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
  }
}
