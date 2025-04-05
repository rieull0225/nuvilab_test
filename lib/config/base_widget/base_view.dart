import "dart:async";
import "dart:developer";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:tripmate/src/config/theme/color.dart";

abstract class BaseView<T extends ChangeNotifier> extends StatelessWidget {
  const BaseView({Key? key}) : super(key: key);

  T vm(BuildContext context, {bool listen = false}) => Provider.of<T>(context, listen: listen);

  @protected
  T createViewModel(BuildContext context);

  @protected
  PreferredSizeWidget? appBar(BuildContext context) => null;

  @protected
  Widget buildBody(BuildContext context);

  // @protected
  // Widget? bottomNavigationBar(BuildContext context) => null;
  //
  @protected
  Widget? fab(BuildContext context) => null;

  @protected
  bool bottomInset() => true;

  @protected
  bool extendBody() => false;

  @protected
  Color backgroundColor() => TripMateColor.white;

  @protected
  FloatingActionButtonLocation fabLocation() => FloatingActionButtonLocation.centerDocked;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: createViewModel,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: backgroundColor(),
            extendBodyBehindAppBar: extendBody(),
            resizeToAvoidBottomInset: bottomInset(),
            appBar: appBar(context),
            body: buildBody(context),
            floatingActionButton: fab(context),
            floatingActionButtonLocation: fabLocation(),
            // bottomNavigationBar: bottomNavigationBar(context),
          ),
        );
      },
    );
  }

  Future<void> inProgress(Function task, {dynamic Function(dynamic)? onComplete}) async {
    FullScreenProgressDialog().show(barrierDismissible: false);
    try {
      var result = await task();
      FullScreenProgressDialog().hide();
      if (onComplete != null) {
        onComplete(result);
      }
    } on Exception catch (e) {
      log(e.toString());
      rethrow;
    } finally {
      FullScreenProgressDialog().hide();
    }
  }
}

class FullScreenProgressDialog {
  factory FullScreenProgressDialog() => _instance;

  FullScreenProgressDialog._internal();

  static final FullScreenProgressDialog _instance = FullScreenProgressDialog._internal();

  late BuildContext _context;
  BuildContext? _dialogContext;

  bool _isShowing = false;

  void init(BuildContext context) {
    _context = context;
  }

  void show({bool barrierDismissible = true}) async {
    _isShowing = true;
    await showDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      context: _context,
      builder: (context) {
        _dialogContext = context;
        return SimpleDialog(
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          children: const [
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        );
      },
      barrierDismissible: barrierDismissible,
    );
    _isShowing = false;
  }

  void hide() async {
    if (_isShowing && _dialogContext != null) {
      Navigator.pop(_dialogContext!);
      _isShowing = false;
    }
  }
}

void showIndeterminateDialog() async => FullScreenProgressDialog().show();

void get hideIndeterminateDialog => FullScreenProgressDialog().hide();
