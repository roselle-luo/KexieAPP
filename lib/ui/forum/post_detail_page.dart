import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kexie_app/ui/forum/post_card_detail.dart';
import 'package:kexie_app/ui/forum/post_detail_controller.dart';
import '../../models/forum_posts/forum_posts.dart';
import 'post_card.dart';

class PostDetailPageArgs {
  const PostDetailPageArgs({required this.post});

  final Post post;
}

class PostDetailPage extends StatelessWidget {
  PostDetailPage({super.key, required PostDetailPageArgs args})
      : post = args.post;

  final Post post;

  onChangeLikePost(PostDetailController c, bool isLiked, Post post) async {
    if (isLiked) {
      await c.unlike(post.iD);
      return false;
    } else {
      await c.like(post.iD);
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PostDetailController(post: post), tag: post.iD.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text('帖子'),
        bottom: CustomAppBarBottom(
          widget: Container(
            width: double.infinity,
            height: 0.2,
            color: Colors.grey,
          ),
          height: 1,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (c.focus.value.hasFocus) {
            c.focus.value.unfocus();
          }
        },
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await c.refresh();
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: PostCardDetail(
                        post: post,
                        watchCount: c.watchCount,
                        onChangeLikePost: (isLiked) async {
                          return await onChangeLikePost(c, isLiked, post);
                        },
                      ),
                    ),
                    PagedSliverList<int, Post>(
                      pagingController: c.pagingController,
                      builderDelegate: PagedChildBuilderDelegate<Post>(
                        itemBuilder: (context, post, index) {
                          return PostCard(
                            post: post,
                            onChangeLikePost: (isLiked) async {
                              return await onChangeLikePost(c, isLiked, post);
                            },
                          );
                        },
                        noItemsFoundIndicatorBuilder: (context) => const Center(
                          child: Text('没有找到评论'),
                        ),
                        firstPageErrorIndicatorBuilder: (context) => Center(
                          child: TextButton(
                            onPressed: () => c.pagingController.refresh(),
                            child: const Text("加载失败，点击重试"),
                          ),
                        ),
                        newPageErrorIndicatorBuilder: (context) => Center(
                          child: TextButton(
                            onPressed: () =>
                                c.pagingController.retryLastFailedRequest(),
                            child: const Text("加载失败，点击重试"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() => c.images.isNotEmpty ? imagesList(c, context) : SizedBox()),
            Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                    child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: c.focus.value,
                          controller: c.replyController,
                          maxLines: 5,
                          minLines: 1,
                          decoration: InputDecoration(
                              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white ,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              contentPadding: const EdgeInsets.all(15),
                              hintText: '  发布你的回复',
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        c.pickImage();
                                      },
                                      icon:
                                          const Icon(Icons.image_outlined)),
                                  Obx(
                                    () => IconButton(
                                        onPressed: c.isSending.isTrue ||
                                                (c.replyIsBlank.isTrue && c.images.isEmpty)
                                            ? null
                                            : () {
                                                c.replyPost(
                                                    post.iD,
                                                    c.replyController.text);
                                              },
                                        icon: const Icon(
                                          Icons.send,
                                        )),
                                  )
                                ],
                              )),
                        ),
                      ),
                    ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget imagesList (PostDetailController c,BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15)
        ),
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: c.images.length,
            separatorBuilder: (context,index) {
              return SizedBox(
                width: 30,
                height: 0,
              );
            },
            itemBuilder: (context,index) {
              final image = c.images[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Image.file(
                      File(image.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        onPressed: () => c.images.remove(image),
                        icon: Icon(Icons.close,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ),
    );
  }

}

class CustomAppBarBottom extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomAppBarBottom(
      {super.key, required this.widget, required this.height});

  final StatelessWidget widget;
  final double height; //组件占据的高度

  @override
  Widget build(BuildContext context) {
    return widget;
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
