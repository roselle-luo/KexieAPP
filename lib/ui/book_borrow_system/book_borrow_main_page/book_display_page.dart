import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kexie_app/models/book_infomation/book_infomation.dart';
import 'package:kexie_app/ui/book_borrow_system/detail_book/detail_book_page.dart';
import 'package:kexie_app/widgets/loading_view.dart';
import 'package:kexie_app/widgets/login_fail_page.dart';
import 'package:kexie_app/widgets/toast.dart';
import '../../../global/global.dart';
import 'book_display_controller.dart';

class BookBorrowPage extends StatefulWidget {
  const BookBorrowPage({super.key});

  @override
  State<BookBorrowPage> createState() => _BookBorrowPageState();
}

class _BookBorrowPageState extends State<BookBorrowPage> {
  final c = Get.put(BookBorrowController());

  @override
  Widget build(BuildContext context) {
    return Global.isLogin.value
        ? Scaffold(
            appBar: AppBar(
              title: const Text('科协书城'),
              // actions: [
              //   Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 10.0),
              //     child: IconButton(
              //         onPressed: () => debugPrint('aaaaaaaa'),
              //         icon: const Icon(
              //           Icons.search,
              //           size: 30,
              //         )),
              //   ),
              //   Obx(
              //     () => Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 10.0),
              //       child: IconButton(
              //           onPressed: () {
              //             c.isColumn.value = !c.isColumn.value;
              //           },
              //           icon: c.isColumn.value
              //               ? const Icon(
              //                   Icons.grid_view_rounded,
              //                   size: 30,
              //                 )
              //               : const Icon(
              //                   Icons.menu_outlined,
              //                   size: 30,
              //                 )),
              //     ),
              //   ),
              // ],
            ),
            floatingActionButton: FloatingActionButton(
              shape: CircleBorder(),
              onPressed: () async {
                String result = await c.scanBookQrCode();
                if (result.isNotEmpty) {
                  LoadingView.show(context, text: '添加中...');
                  await c.addBooks(result);
                  LoadingView.hide(context);
                } else {
                  toastFailure(message: '扫码错误');
                }
              },
              child: Icon(Icons.add),
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                        child: Obx(
                      () => RefreshIndicator(
                        onRefresh: () async {
                          await c.getBooks();
                        },
                        child: GridView.builder(
                          itemCount: c.bookInformation.value.data.length,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 100, //横轴有几个
                            crossAxisSpacing: 30, //次轴方向间距
                            childAspectRatio: 0.45,
                          ),
                          itemBuilder: (context, index) => singleBookWidget(
                              c.bookInformation.value.data[index], context),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ))
        : Scaffold(
            appBar: AppBar(
              title: Text('图书借阅'),
            ),
            body: LoginFailPage(),
          );
  }
}

Widget singleBookWidget(Data book, BuildContext context) {
  return InkWell(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    splashFactory: null,
    onTap: () {
      Get.to(DetailBookPage(book: book), transition: Transition.cupertino);
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).colorScheme.onSurface, width: 0.5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              height: 100 / 0.75,
              fit: BoxFit.cover,
              imageUrl: book.coverImageUrl.first,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Flexible(
          child: Text(
            book.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ],
    ),
  );
}
