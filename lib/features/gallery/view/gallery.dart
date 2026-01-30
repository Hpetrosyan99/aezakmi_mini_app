import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_system/design_system.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/navigation/app_router.dart';
import '../../../gen/locale_keys.g.dart';
import '../../../injectable.dart';
import '../../../shared/stores/auth_store/auth_store.dart';
import '../../../shared/widgets/custom_scaffold/custom_scaffold.dart';
import '../../../shared/widgets/loading_button/loading_button.dart';

@RoutePage()
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

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
        systemOverlayStyle:
        const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
        centerTitle: true,
        leading: IconButton(
          onPressed: () async {
            await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text(LocaleKeys.gallery_escape.tr()),
                  content:
                  Text(LocaleKeys.gallery_areYouSureToLogOut.tr()),
                  actions: [
                    TextButton(
                      onPressed: router.pop,
                      child: Text(LocaleKeys.gallery_cancel.tr()),
                    ),
                    TextButton(
                      onPressed: () async {
                        await router.pop();
                        await router.pushAndPopAll(const LoginRoute());
                        await FirebaseAuth.instance.signOut();
                        await getIt<AuthStore>().logout();
                      },
                      child: Text(LocaleKeys.gallery_logOut.tr()),
                    ),
                  ],
                );
              },
            );
          },
          icon: Assets.icons.logOutIcon.image(height: 24),
        ),
        title: Text(
          LocaleKeys.gallery_gallery.tr(),
          style: TextStyles.primaryButtonTextStyle,
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (_, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                onPressed: () {
                  router.push(DrawRoute());
                },
                icon: Assets.icons.drawNewIcon.image(height: 24),
              );
            },
          ),
        ],
        backgroundColor: Colors.grey.withValues(alpha: 0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(8),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 46,
                      ),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (_, index) {
                        final doc = docs[index];
                        final imageId = doc.id;
                        final url = doc['downloadUrl'] as String;

                        return MutedScaleTap(
                          onPressed: () {
                            router.push(
                              DrawRoute(
                                imageId: imageId,
                                imageUrl: url,
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (_, child, progress) {
                                if (progress == null) {
                                  return child;
                                }
                                return Shimmer.fromColors(
                                  baseColor:
                                  Colors.grey.shade300,
                                  highlightColor:
                                  Colors.grey.shade100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: stream,
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isNotEmpty) {
                    return const SizedBox.shrink();
                  }

                  return LoadingButton(
                    child: Text(
                      LocaleKeys.gallery_create.tr(),
                      style: TextStyles.primaryButtonTextStyle,
                    ),
                    onPressed: () {
                      router.push(DrawRoute());
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
