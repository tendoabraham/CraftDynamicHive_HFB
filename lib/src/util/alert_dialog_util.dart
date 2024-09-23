part of craft_dynamic;

class AlertUtil {
  static showAlertDialog(BuildContext context, String message,
      {isConfirm = false,
      isInfoAlert = false,
      showTitleIcon = true,
      formFields,
      title,
      confirmButtonText = "Ok",
      cancelButtonText = "Cancel"}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      // user must tap button!
      pageBuilder: (BuildContext context, anim1, anim2) {
        return Container();
      },
      transitionBuilder: (ctx, a1, a2, child) {
        var curve = Curves.easeInOut.transform(a1.value);
        return Transform.scale(
            scale: curve,
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: AlertDialog(
                actionsPadding:
                    const EdgeInsets.only(bottom: 16, right: 14, left: 14),
                insetPadding: const EdgeInsets.symmetric(horizontal: 44),
                titlePadding: EdgeInsets.zero,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                title: Container(
                  color: APIService.appPrimaryColor,
                  height: 100,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      title == null
                          ? const SizedBox()
                          : Text(
                              title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  fontFamily: "DMSans",
                                  color: Colors.white),
                            ),
                      const SizedBox(
                        height: 8,
                      ),
                      showTitleIcon
                          ? isInfoAlert
                              ? Icon(
                                  Icons.info_outline,
                                  color: APIService.appPrimaryColor
                                      .withOpacity(.4),
                                  size: 38,
                                )
                              : const Icon(
                                  Icons.dangerous_rounded,
                                  color: Colors.redAccent,
                                  size: 38,
                                )
                          : const SizedBox()
                    ],
                  )),
                ),
                content: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                        child: ListBody(
                      children: <Widget>[
                        const SizedBox(
                          height: 8,
                        ),
                        Center(
                            child: Text(
                          message,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              fontFamily: "DMSans"),
                          textAlign: TextAlign.center,
                        )),
                        // const SizedBox(
                        //   height: 12,
                        // ),
                        // Divider(
                        //   color: APIService.appPrimaryColor.withOpacity(.2),
                        // )
                      ],
                    ))),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: isConfirm
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.center,
                    children: [
                      isConfirm
                          ? Row(
                              children: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text(
                                      cancelButtonText,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: "DMSans",
                                          color: APIService.appSecondaryColor),
                                    ).tr()),
                                const SizedBox(
                                  width: 12,
                                ),
                              ],
                            )
                          : const SizedBox(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: APIService
                              .appPrimaryColor, // Set the blue background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                12), // Adjust the curvature of the borders
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 34.0), // Optional padding
                        ),
                        child: Text(
                          confirmButtonText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: "DMSans",
                            color: Colors
                                .white, // Set the text color to white to contrast with the blue background
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ));
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static showModalBottomDialog(context, message) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 4),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            child: ListView(
              shrinkWrap: true,
              children: [
                DynamicTextViewWidget(jsonText: message).render(),
                WidgetFactory.buildButton(context, () {
                  Navigator.of(context).pop();
                }, "Done")
              ],
            ));
      },
    );
  }
}
