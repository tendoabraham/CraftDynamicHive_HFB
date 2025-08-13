// ignore_for_file: must_be_immutable

part of craft_dynamic;

class TransactionReceipt extends StatefulWidget {
  final PostDynamic postDynamic;
  String? moduleName;

  TransactionReceipt({required this.postDynamic, this.moduleName, super.key});

  @override
  State<StatefulWidget> createState() => _TransactionReceiptState();
}

class _TransactionReceiptState extends State<TransactionReceipt>
    with SingleTickerProviderStateMixin {
  late var _controller;
  bool isLoadingPDF = false;

  @override
  void initState() {
    super.initState();
    Vibration.vibrate();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) {
            if (!_controller.isCompleted) {
              _controller.forward(from: 0.0);
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var postDynamic = widget.postDynamic;

    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          return true;
        },
        child: Scaffold(
          body: Center(
              child: SingleChildScrollView(
                  child: Stack(
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: ClipPath(
                      clipper: PointsClipper(),
                      child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12.0),
                                  topRight: Radius.circular(12.0))),
                          padding: const EdgeInsets.only(
                              bottom: 12, left: 12, right: 12),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Lottie.asset(
                                    "packages/craft_dynamic/assets/lottie/success.json",
                                    height: 122,
                                    width: 122,
                                    controller: _controller, onLoaded: (comp) {
                                  _controller
                                    ..duration = comp.duration
                                    ..forward();
                                }),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Divider(
                                      color: Colors.grey[300],
                                    )),
                                    const Text(
                                      "Success",
                                    ).tr(),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey[300],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        postDynamic.receiptDetails?.length,
                                    itemBuilder: (context, index) {
                                      String title = MapItem.fromJson(
                                              postDynamic
                                                  .receiptDetails?[index])
                                          .title;
                                      String? value = MapItem.fromJson(
                                                  postDynamic
                                                      .receiptDetails?[index])
                                              .value ??
                                          "****";
                                      return value.isEmpty
                                          ? const SizedBox()
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(title),
                                                  Flexible(
                                                      child: Text(
                                                    value.isEmpty
                                                        ? "****"
                                                        : value,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    softWrap: true,
                                                    textAlign: TextAlign.end,
                                                  ))
                                                ],
                                              ));
                                    }),
                                const SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  "Thank you for using ${APIService.appLabel}",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        iconSize: 28,
                                        onPressed: isLoadingPDF
                                            ? null
                                            : () async {
                                                setLoadPdfStatus(true);
                                                await PDFUtil.downloadReceipt(
                                                    receiptdetails:
                                                        getTransactionDetailsMap(
                                                            postDynamic));
                                                setLoadPdfStatus(false);
                                              },
                                        icon: const Column(children: [
                                          Icon(
                                            color: Colors.grey,
                                            Icons.download,
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text("Download",
                                              style: TextStyle(fontSize: 12))
                                        ])),
                                    const VerticalDivider(color: Colors.black),
                                    IconButton(
                                        iconSize: 28,
                                        onPressed: isLoadingPDF
                                            ? null
                                            : () async {
                                                setLoadPdfStatus(true);
                                                await PDFUtil.downloadReceipt(
                                                    receiptdetails:
                                                        getTransactionDetailsMap(
                                                            postDynamic),
                                                    downloadReceipt: false,
                                                    isShare: true);
                                                setLoadPdfStatus(false);
                                              },
                                        icon: const Column(children: [
                                          Icon(
                                            color: Colors.grey,
                                            Icons.share,
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text("Share",
                                              style: TextStyle(fontSize: 12))
                                        ])),
                                  ],
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                SizedBox(
                                    width: 150,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          int? noOfTimesToPop =
                                              postDynamic.backstack;
                                          if (noOfTimesToPop != null &&
                                              noOfTimesToPop != 0) {
                                            for (int i = 0;
                                                i <= noOfTimesToPop;
                                                i++) {
                                              Navigator.of(context).pop();
                                            }
                                          } else {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: const Text("Done"))),
                                const SizedBox(
                                  height: 24,
                                ),
                              ])))),
              isLoadingPDF
                  ? Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: CircularLoadUtil())
                  : const SizedBox(),
            ],
          ))),
          backgroundColor: APIService.appPrimaryColor,
        ));
  }

  setLoadPdfStatus(bool status) {
    setState(() {
      isLoadingPDF = status;
    });
  }

  // Map<String, dynamic> getTransactionDetailsMap(PostDynamic postDynamic) {
  //   Map<String, dynamic> details = {};
  //   postDynamic.receiptDetails?.asMap().forEach((index, item) {
  //     final mapItem = MapItem.fromJson(postDynamic.receiptDetails?[index]);
  //     final title = mapItem.title;
  //     final value = mapItem.value ?? "****";
  //
  //     print("TITLE: $title");
  //
  //     if (!["0", "0.00", "0.000"].contains(value)) {
  //       details[title] = value;
  //     }
  //   });
  //   return details;
  // }

  Map<String, dynamic> getTransactionDetailsMap(PostDynamic postDynamic) {
    Map<String, dynamic> details = {};
    Map<String, int> titleCount = {}; // Track duplicate titles

    postDynamic.receiptDetails?.asMap().forEach((index, item) {
      final mapItem = MapItem.fromJson(postDynamic.receiptDetails?[index]);
      String title = mapItem.title;
      final value = mapItem.value ?? "****";

      // Skip if value is zero-like
      if (["0", "0.00", "0.000"].contains(value)) return;

      // Handle duplicates by adding a counter suffix
      if (details.containsKey(title)) {
        titleCount[title] = (titleCount[title] ?? 1) + 1;
        title = "$title ${titleCount[title]}";
      } else {
        titleCount[title] = 1;
      }

      details[title] = value;
    });

    return details;
  }

  // Map<String, dynamic> getTransactionDetailsMap(PostDynamic postDynamic) {
  //   Map<String, dynamic> details = {};
  //   postDynamic.receiptDetails?.asMap().forEach((index, item) {
  //     String title = MapItem.fromJson(postDynamic.receiptDetails?[index]).title;
  //     String value =
  //         MapItem.fromJson(postDynamic.receiptDetails?[index]).value ?? "****";
  //     details.addAll({title: value});
  //   });
  //   return details;
  // }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
