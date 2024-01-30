// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:medical_family_app/constants/scale/scale_dimension.dart';
import 'package:medical_family_app/constants/texts/texts.dart';
import 'package:medical_family_app/data/repo_model/medical_world_repo_model.dart';
import 'package:medical_family_app/data/repo_model/medical_world_repo_model_impl.dart';
import 'package:medical_family_app/data/vo_models/design_object_vo.dart';
import 'package:medical_family_app/pages/bottom_navigation_page.dart';
import 'package:medical_family_app/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// app state
  bool? isLogin;

  /// repo model
  MedicalWorldRepoModel model = MedicalWorldRepoModelImpl();

  Future<void> _getDesignOne() async {
    await model.getDesign("1",page: 1).then((value) {
      preDesignListOne = value;
    }).onError((error, stackTrace) {
      debugPrint("Error one ==> $error\n Trace one ==> $stackTrace");
    });
  }

  Future<void> _getDesignTwo() async {
    await model.getDesign("2",page: 1).then((value) {
      preDesignListTwo = value;
    }).onError((error, stackTrace) {
      debugPrint("Error two ==> $error\n Trace two ==> $stackTrace");
    });
  }

  Future<void> _getDesignThree() async {
    await model.getDesign("3",page: 1).then((value) {
      preDesignListThree = value;
    }).onError((error, stackTrace) {
      debugPrint("Error three ==> $error\n Trace three ==> $stackTrace");
    });
  }

  @override
  void initState() {
    super.initState();
    model.isPreferenceExists(USER_ID).then((value) async {
      isLogin = value;
      await Future.wait([_getDesignOne(), _getDesignTwo(), _getDesignThree()])
          .then((value) {
        if (isLogin == true) {
          if (preDesignListOne != null &&
              preDesignListOne!.isNotEmpty &&
              preDesignListTwo != null &&
              preDesignListTwo!.isNotEmpty &&
              preDesignListThree != null &&
              preDesignListThree!.isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavigationPage(),
              ),
            );
          } else {
            print("error one");
          }
        } else {
          if (preDesignListOne != null &&
              preDesignListOne!.isNotEmpty &&
              preDesignListTwo != null &&
              preDesignListTwo!.isNotEmpty &&
              preDesignListThree != null &&
              preDesignListThree!.isNotEmpty) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const LoginPage()));
          } else {
            print("error two");
          }
        }
      });
    }).onError((error, stackTrace) {
      debugPrint("$error");
    });
  }
  // model.getDesign("1").then((value) {
  //   designListOne = value;
  //   model.getDesign("2").then((value) {
  //     designListTwo = value;
  //     model.getDesign("3").then((value) {
  //       designListThree = value;
  //     });
  //   });
  // });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        width: scaleWidth(context),
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Image.asset(
            'assets/images/medical_world.png',
            height: scaleWidth(context) / 1.8,
            width: scaleWidth(context) / 1.8,
          ),
        ),
      ),
    );
  }
}
