import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../widgets/Dashboard/RightPanel.dart';
import '../../widgets/upload_create_design/MainContent.dart';
import '../../widgets/upload_create_design/SideNav.dart';
import '../../widgets/upload_create_design/StatusBar.dart';
import '../../widgets/upload_create_design/TopBar.dart';

class UploadCreateDesignScreen extends StatelessWidget {
  const UploadCreateDesignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Column(
        children: [
          const TopBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SideNav(),
                Expanded(child: MainContent()),
                const RightPanel(),
              ],
            ),
          ),
          const StatusBar(),
        ],
      ),
    );
  }
}



