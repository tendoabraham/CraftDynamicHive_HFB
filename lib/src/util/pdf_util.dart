part of craft_dynamic;

class PDFUtil {
  static Color color = APIService.appPrimaryColor;
  static final profileRepo = ProfileRepository();

  static Future<int?> downloadReceipt(
      {Map<String, dynamic>? receiptdetails,
      List<dynamic>? transactionlist,
      downloadReceipt = true,
      drawMultipleGrids = false,
      isShare = false}) async {
    final PdfDocument document = PdfDocument();
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory();
    PdfPage page = document.pages.add();
    bool showImageHeader = true;

    double imageWidth = page.size.width;
    double imageHeight = 150;
    ByteData headerImageBytes;
    PdfImage headerImage;
    String receiptNo = "";

    AppLogger.appLogD(tag: "pdf", message: "started creating pdf");

    if (transactionlist != null && drawMultipleGrids) {}

    try {
      //Pick image for receipt header
      headerImageBytes = await rootBundle.load('assets/receipt_logo.png');
      List<int> headerImageBitmap = headerImageBytes.buffer.asUint8List();

      headerImage =
          PdfBitmap.fromBase64String(base64.encode(headerImageBitmap));
      PdfGraphicsState receiptstate = page.graphics.save();

      // Calculate the scaling factor to fit the image within the rectangle
      double scaleX = imageWidth / headerImage.width;
      double scaleY = imageHeight / headerImage.height;
      double scale =
          scaleX < scaleY ? scaleX : scaleY; // Use the smaller scaling factor

      // Calculate the new image dimensions
      imageWidth = headerImage.width * scale;
      imageHeight = headerImage.height * scale;

      // Calculate the position to center the image within the rectangle
      double x = (page.size.width - imageWidth) / 2;
      double y = (150 - imageHeight) / 2;

      page.graphics.drawImage(
          PdfBitmap.fromBase64String(base64.encode(headerImageBitmap)),
          Rect.fromLTWH(x, y, imageWidth - 100, imageHeight));

      page.graphics.restore(receiptstate);
    } catch (e) {
      AppLogger.appLogD(tag: "pdf_util", message: e);
      showImageHeader = false;
    }

    PdfPageTemplateElement header = PdfPageTemplateElement(
        Rect.fromLTWH(0, 0, document.pageSettings.size.width, 100));

    if (!showImageHeader) {
      header.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, header.width, header.height),
        brush: PdfSolidBrush(PdfColor(color.red, color.green,
            color.blue)), // Replace with your desired background color
      );
    }

    if (!showImageHeader) {
      var headerfont = PdfStandardFont(PdfFontFamily.timesRoman, 28,
          style: PdfFontStyle.bold);
      header.graphics.drawString(
        APIService.appLabel,
        headerfont,
        brush: PdfSolidBrush(PdfColor(255, 255, 255)),
        bounds: Rect.fromLTWH(
            (header.width -
                    headerfont.measureString(APIService.appLabel).width) /
                2,
            (header.height / 2) - 20,
            0,
            header.height),
      );
    }

    document.template.top = header;
    double hiTextUpperBound = 60;
    double subTitleUpperBound = hiTextUpperBound + 50;
    PdfStringFormat format = PdfStringFormat();
    format.alignment = PdfTextAlignment.center;

    if (!showImageHeader) {
      page.graphics.drawString(
          'Hi ${await profileRepo.getUserInfo(UserAccountData.FirstName)},',
          PdfStandardFont(PdfFontFamily.helvetica, 40,
              style: PdfFontStyle.bold),
          brush: PdfSolidBrush(PdfColor(color.red, color.green, color.blue)),
          bounds: Rect.fromLTWH(0, hiTextUpperBound, page.size.width - 100, 0),
          format: format);

      page.graphics.drawString('Thank you for using ${APIService.appLabel}',
          PdfStandardFont(PdfFontFamily.helvetica, 18),
          brush: PdfSolidBrush(PdfColor(color.red, color.green, color.blue)),
          bounds: Rect.fromLTWH(
              0, subTitleUpperBound, document.pageSettings.size.width - 100, 0),
          format: format);
    }

    if (transactionlist != null && drawMultipleGrids) {
      var transType = determineTransType(transactionlist.first ?? {});

      page.graphics.drawString(
          'Transaction $transType - Detail',
          PdfStandardFont(PdfFontFamily.helvetica, 20,
              style: PdfFontStyle.bold),
          bounds: Rect.fromLTWH(0, imageHeight + 10, page.size.width - 100, 0),
          format: format);
      page.graphics.restore(await drawWaterMark(page));
      await drawGrid(page, transactionlist.first);
      transactionlist.removeAt(0);
      for (var item in transactionlist) {
        var page = document.pages.add();
        var transType = determineTransType(item ?? {});

        page.graphics.drawString(
            'Transaction $transType - Detail',
            PdfStandardFont(PdfFontFamily.helvetica, 20,
                style: PdfFontStyle.bold),
            bounds: Rect.fromLTWH(0, 0, page.size.width - 100, 0),
            format: format);
        page.graphics.restore(await drawWaterMark(page));
        await drawGrid(page, item, removeTopMargin: true);
      }
      receiptNo =
          DateFormat('hh:mm:ss').format(DateTime.now()).replaceAll(":", "");
    } else {
      var transType = determineTransType(receiptdetails ?? {});
      if (transType != null) {
        page.graphics.drawString(
            'Transaction $transType - Detail',
            PdfStandardFont(PdfFontFamily.helvetica, 20,
                style: PdfFontStyle.bold),
            bounds:
                Rect.fromLTWH(0, imageHeight + 10, page.size.width - 100, 0),
            format: format);
      }
      page.graphics.restore(await drawWaterMark(page));
      receiptNo = await drawGrid(page, receiptdetails);
    }

    String receiptname = "Receipt$receiptNo";
    String filePath = "${directory?.path}/$receiptname.pdf";

    AppLogger.appLogD(tag: "pdf", message: "saving pdf $filePath");

    await saveFile(filePath, document);

    CommonUtils.getxNavigate(
        widget: PDFScreen(
      path: filePath,
      pdfName: receiptname,
      document: document,
      downloadReceipt: downloadReceipt,
      isShare: isShare,
    ));
    return 0;
  }

  static saveFile(String path, PdfDocument document) async {
    await File(path).writeAsBytes(await document.save());
  }

  static String? determineTransType(Map<String, dynamic> details) {
    if (details.containsKey("TransType")) {
      return details["TransType"];
    }
    if (details.containsKey("Transaction Type")) {
      return details["Transaction Type"];
    }
    if (details.containsKey("TransactionType")) {
      return details["TransactionType"];
    }
    return null;
  }

  static Future<String> drawGrid(
      PdfPage page, Map<String, dynamic>? receiptdetails,
      {double hiTextUpperBound = 60,
      subTitleUpperBound = 60 + 50,
      removeTopMargin = false}) async {
    PdfGrid grid = PdfGrid();
    var gridStyle = PdfGridStyle(
      cellPadding: PdfPaddings(left: 20, right: 20, top: 8, bottom: 8),
      backgroundBrush: PdfBrushes.transparent,
      textBrush: PdfBrushes.black,
      font: PdfStandardFont(PdfFontFamily.helvetica, 18),
    );
    grid.style = gridStyle;
    grid.columns.add(count: 2);
    // Set margins for the page
    double leftMargin = 0; // Adjust the left margin value as desired
    double rightMargin = 0; // Adjust the right margin value as desired
    double topMargin = removeTopMargin
        ? 60
        : 20 +
            hiTextUpperBound +
            subTitleUpperBound; // Adjust the top margin value as desired
    String receiptNo = ""; // A

    receiptdetails?.entries.forEach((item) {
      PdfGridRow row = grid.rows.add();
      String title = item.key;
      String value = row.cells[1].value = item.value ?? "****";
      if (title.toLowerCase() == "reference no" ||
          title.toLowerCase() == "bankreference" ||
          title.toLowerCase() == "reference id" ||
          title.toLowerCase() == "bank reference") {
        receiptNo = value;
      }
      row.cells[0].value = title;
      row.cells[1].value = value;
    });

    PdfLayoutResult? layoutResult = grid.draw(
      page: page,
      bounds: Rect.fromLTWH(
        leftMargin,
        topMargin,
        page.getClientSize().width - (leftMargin + rightMargin),
        0,
      ),
    );
    return receiptNo;
  }

  static Future<PdfGraphicsState> drawWaterMark(PdfPage page) async {
    //Watermark image
    ByteData imageBytes = await rootBundle.load('assets/launcher.png');
    List<int> imageBitmap = imageBytes.buffer.asUint8List();
    PdfGraphicsState state = page.graphics.save();
    page.graphics.setTransparency(0.25);
    page.graphics.drawImage(
        PdfBitmap.fromBase64String(base64.encode(imageBitmap)),
        Rect.fromLTWH((page.graphics.clientSize.width / 2) - 150,
            (page.graphics.clientSize.height / 2) - 150, 300, 300));
    return state;
  }
}

class MapItem {
  String title;
  String? value;

  MapItem({required this.title, required this.value});

  MapItem.fromJson(Map<String, dynamic> json)
      : title = json["Title"],
        value = json["Value"];
}
