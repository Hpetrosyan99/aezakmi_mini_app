import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_system/design_system.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_router.dart';
import '../../../gen/locale_keys.g.dart';
import '../../../shared/widgets/custom_scaffold/custom_scaffold.dart';
import '../../../shared/widgets/grid_shimmer/grid_shimmer.dart';
import '../../../shared/widgets/loading_button/loading_button.dart';

@RoutePage()
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('images')
        .orderBy('createdAt', descending: true)
        .snapshots();
    return CustomScaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
        centerTitle: true,
        leading: IconButton(onPressed: () async {}, icon: Assets.icons.logOutIcon.image(height: 24)),
        title: Text(LocaleKeys.gallery_gallery.tr(), style: TextStyles.primaryButtonTextStyle),
        backgroundColor: Colors.grey.withValues(alpha: 0.2),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(8))),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const GridShimmer();
                  }
                  final docs = snapshot.data!.docs;
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (_, index) {
                      final path = docs[index]['localPath'] as String;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(path), fit: BoxFit.cover),
                      );
                    },
                  );
                },
              ),
              const Spacer(),
              LoadingButton(
                child: Text(LocaleKeys.gallery_create.tr(), style: TextStyles.primaryButtonTextStyle),
                onPressed: () {
                  router.push(const DrawRoute());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
