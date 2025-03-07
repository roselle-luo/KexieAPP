import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kexie_app/models/book_infomation/book_infomation.dart';
import 'package:kexie_app/ui/book_borrow_system/detail_book/detail_book_controller.dart';
import 'package:kexie_app/widgets/loading_view.dart';

class DetailBookPage extends StatefulWidget {
  const DetailBookPage({super.key, required this.book});

  final Data book;

  @override
  State<DetailBookPage> createState() => _DetailBookPageState();
}

class _DetailBookPageState extends State<DetailBookPage> {
  final c = Get.put(DetailBookController());
  @override
  Widget build(BuildContext context) {
    var count = widget.book.count.obs;
    return Scaffold(
      appBar: AppBar(
        title: const Text('书籍信息'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Stack(children: [
                  CachedNetworkImage(
                    imageUrl: widget.book.coverImageUrl.first,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 2.3,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        color: Colors.black.withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '剩余：',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                ),
                              ),
                              Obx(
                                () => Text.rich(TextSpan(children: [
                                  TextSpan(
                                      text: count.value.toString(),
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: count.value == 0 ? Colors.red : Colors.white)
                                  ),
                                  const TextSpan(
                                      text: '   本',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white)
                                  ),
                                ])),
                              ),
                            ],
                          ),
                        ),
                      ))
                ]),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  widget.book.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: '作者：\t',
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: widget.book.author,
                        style: const TextStyle(fontSize: 19)),
                  ])),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: '出版社：\t',
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: widget.book.publisher,
                        style: const TextStyle(fontSize: 19)),
                  ])),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: '所在区域：\t',
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: widget.book.area,
                        style: const TextStyle(fontSize: 19)),
                  ])),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Obx(
                    () => Text.rich(TextSpan(children: [
                      const TextSpan(
                          text: '剩余：\t',
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: count.value.toString(),
                          style: TextStyle(
                              fontSize: 19,
                              color: count.value == 0 ? Colors.red : Theme.of(context).colorScheme.onSurface)),
                      const TextSpan(text: '\t本', style: TextStyle(fontSize: 19)),
                    ])),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
              child: ElevatedButton(
                  onPressed: () async {
                    LoadingView.show(context, text: '借阅中...');
                    final result = await c.borrowAndReturn.borrowBook(widget.book.isbn, c.planTime.value);
                    if (result == true) {
                      count.value--;
                      widget.book.count--;
                    }
                    LoadingView.hide(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(100, 60),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    '借阅',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
                        fontSize: 18,
                        letterSpacing: 10),
                  ))),
          Expanded(
              child: ElevatedButton(
                  onPressed: () async {
                    LoadingView.show(context, text: '归还中...');
                    final result = await c.borrowAndReturn.returnBook(widget.book.isbn);
                    if (result == true) {
                      count.value++;
                      widget.book.count++;
                    }
                    LoadingView.hide(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(100, 60),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: const Text(
                    '归还',
                    style: TextStyle(fontSize: 18, letterSpacing: 10),
                  ))),
        ],
      ),
    );
  }
}
