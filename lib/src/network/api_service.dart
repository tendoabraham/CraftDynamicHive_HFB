// ignore_for_file: unnecessary_string_interpolations, prefer_typing_uninitialized_variables

part of craft_dynamic;

final _sharedPref = CommonSharedPref();

class APIService {
  static final APIService _apiService = APIService._internal();

  static Map? appConfig,
      urlsConfig,
      requestConfig,
      cryptConfig,
      appPropertiesConfig;
  static bool isTestUrl = true;
  static String currentBaseUrl = "";
  static String uatUrl = "";
  static String liveUrl = "";
  static String tokenUrl = "";
  static String appName = "";
  static String bankID = "";
  static String bankCustomerID = "";
  static String countryName = "";
  static String countryCode = "";
  static String countryIsoCode = "KE";

  static String appLabel = "";
  static Color appPrimaryColor = Colors.blue;
  static Color appSecondaryColor = Colors.blueAccent;

  static final dio = Dio();
  var logger = Logger();

  factory APIService() {
    Future.sync(() => initializeObject());
    return _apiService;
  }

  APIService._internal();

  static initializeObject() async {
    String yamlConfiguration =
        await rootBundle.loadString('assets/plugin_config.yaml');
    appConfig = loadYaml(yamlConfiguration);
    AppLogger.appLogI(
        tag: "Initialized yaml configuration file", message: appConfig);
    getAppConfigKeys();
    currentBankID.value = await _sharedPref.getBankID() ?? "";
    getAppConfigValues();
    return yamlConfiguration;
  }

  static void getAppConfigKeys() {
    urlsConfig = appConfig?["urls"];
    requestConfig = appConfig?["request"];
    appPropertiesConfig = appConfig?["appProperties"];
  }

  static void getAppConfigValues() {
    appLabel = appPropertiesConfig?["appLabel"];
    appPrimaryColor = "#${appPropertiesConfig?["appPrimaryColor"]}".toColor();
    appSecondaryColor =
        "#${appPropertiesConfig?["appSecondaryColor"]}".toColor();
    isTestUrl = urlsConfig?["test"] ?? true;
    uatUrl = urlsConfig?["uat"] ?? "";
    liveUrl = urlsConfig?["live"] ?? "";
    tokenUrl = urlsConfig?["tokenUrl"] ?? "";
    appName = requestConfig?["appName"] ?? "";
    currentBaseUrl = isTestUrl ? uatUrl : liveUrl;
    bankID = currentBankID.value.isNotEmpty
        ? currentBankID.value
        : requestConfig?["bankId"];
    bankCustomerID = requestConfig?["bankCustomerID"] ?? "";
    countryName =
        requestConfig?["country"] + "${isTestUrl ? "TEST" : ""}" ?? "";
    countryCode = requestConfig?["countryCode"] ?? "";
    countryIsoCode = requestConfig?["countryIsoCode"] ?? "";
  }

  Future<Map<String, dynamic>> buildRequestMap(
      {bool isAuthenticate = false}) async {
    var requestBuilder = RequestBuilder(
        bankID: await _sharedPref.getBankID() ?? bankID,
        country: countryName,
        versionNumber: await DeviceInfo.getAppVersion(),
        trxSource: requestConfig?["trxSource"],
        appName: requestConfig?["appName"],
        imei: CryptLib.encryptField(await DeviceInfo.getDeviceUniqueID()),
        imsi: CryptLib.encryptField(await DeviceInfo.getDeviceUniqueID()),
        latLong: await _sharedPref.getLatLong(),
        customerId: isAuthenticate
            ? null
            : await _sharedPref.getCustomerID() ??
                Config.generateBankCustomerID(countryCode, bankID, isTestUrl));
    return RequestObject(requestBuilder).createRequestMap();
  }

  Future<String> dioRequestBodySetUp(String formID,
      {Map<String, dynamic>? objectMap, bool isAuthenticate = false}) async {
    Map<String, dynamic> requestObject = {};

    requestObject[RequestParam.FormID.name] = formID;
    requestObject[RequestParam.SessionID.name] = Constants.getUniqueID();
    requestObject.addAll(await buildRequestMap(isAuthenticate: isAuthenticate));
    if (objectMap != null) {
      requestObject.addAll(objectMap);
    }
    AppLogger.appLogD(tag: "\n\nREQUEST", message: jsonEncode(requestObject));
    return jsonEncode(requestObject);
  }

  Future<String?> performDioRequest(var requestObject,
      {String? route,
      String requestUrl = "",
      bool useGZIPDecryption = false}) async {
    String? response;

    String data = "{}";
    var tokenRefreshed = await _sharedPref.getTokenIsRefreshed();

    if (!APIUtil.verifyConnection()) {
      _sharedPref.setTokenIsRefreshed("false");
      return data;
    }

    if (!tokenRefreshed) {
      await _initRepository.getAppToken();
    }

    String uniqueID = await _sharedPref.getUniqueID();
    // var localToken = await _sharedPref.getLocalToken();
    var localToken = currentToken.value;
    var url = route ?? currentBaseUrl + requestUrl;

    AppLogger.appLogD(tag: "REQ:ROUTE", message: url);
    var encryptedBody =
        CryptLib.encrypt(requestObject, currentKey.value, currentIv.value);
    var requestBody = {"Data": encryptedBody, "UniqueId": uniqueID};
    AppLogger.appLogD(tag: "BODY", message: jsonEncode(requestBody));

    try {
      var res = await dio.post(url,
          options: Options(
            headers: {
              'T': localToken,
              'Access-Control-Allow-Origin': '*',
            },
          ),
          data: requestBody);
      AppLogger.appLogD(tag: "HEADERS", message: res.requestOptions.headers);
      data = res.data["Response"];
      AppLogger.appLogD(tag: "Undecrypted", message: data.toString());
      if (useGZIPDecryption) {
        response = CryptLib.gzipDecompressStaticData(data);
      } else {
        response = await CryptLib.oldDecrypt(data);
      }
    } catch (e) {
      AppLogger.appLogE(tag: "DIO:ERROR", message: e.toString());
      response = await APIUtil.handleDioError(e, data, response);
    }
    return response;
  }

  Future<String?> getPublicKey(String url) async {
    final client = HttpClient();
    final uri = Uri.parse(url);
    final request = await client.getUrl(uri);
    final response = await request.close();
    final pem = response.certificate?.pem;
    final blocks = decodePemBlocks(PemLabel.certificate, pem.toString());
    var encodedPublicKey = base64.encode(blocks[0]);
    AppLogger.appLogD(tag: "Public key", message: encodedPublicKey);
    AppLogger.writeResponseToFile(
        fileName: "Public key", response: encodedPublicKey);
    return encodedPublicKey;
  }

  Future<int?> getToken() async {
    String routes, token = "";
    Map<String, dynamic> requestObject = {};
    Map<String, dynamic> keyIV = CryptLib.generateKeyIV();
    AppLogger.appLogD(tag: "generated key and iv", message: keyIV.toString());
    previousIv.value = currentIv.value;
    previousKey.value = currentKey.value;
    currentIv.value = keyIV["iv"];
    currentKey.value = keyIV["key"];

    String uniqueID = Constants.getUniqueID();
    AppLogger.appLogD(tag: "UNIQUEID:", message: uniqueID);
    var latLong = await _sharedPref.getLatLong();
    await _sharedPref.setUniqueID(uniqueID);
    requestObject["appName"] = appName;
    requestObject["codeBase"] = Constants.getHostPlatform();
    requestObject["Device"] = await DeviceInfo.getDeviceUniqueID();
    requestObject["lat"] = latLong?["lat"] ?? "0.00";
    requestObject["longit"] = latLong?["long"] ?? "0.00";
    requestObject["UniqueId"] = uniqueID;
    requestObject["KV"] = currentKey.value;
    requestObject["IV"] = currentIv.value;
    requestObject[RequestParam.MobileNumber.name] =
        Config.generateBankCustomerID(countryCode, bankID, isTestUrl);

    String requestBody = jsonEncode(requestObject);
    AppLogger.appLogD(tag: "REQ:", message: requestBody);

    var url = currentBaseUrl + tokenUrl;
    // var publicKey = await getPublicKey(currentBaseUrl);

    AppLogger.appLogD(tag: "Token url:", message: url);
    var dioResponse;
    var rsaEncrypted = await RSAUtil.rsaEncrypt(requestBody);
    if (!APIUtil.verifyConnection()) {
      await _sharedPref.setTokenIsRefreshed("false");
      return 1;
    }
    try {
      dioResponse = await dio.post(url,
          data: {
            "Data": rsaEncrypted,
          },
          options: Options(headers: {
            'Access-Control-Allow-Origin': '*',
          }));
      var response = jsonDecode(dioResponse.toString())["Data"];
      AppLogger.appLogD(tag: "\n\nUndecrypted RES", message: response);

      var decryptedMessage = jsonDecode(
          CryptLib.gcmDecrypt(response, currentIv.value, currentKey.value) ??
              "");
      AppLogger.appLogI(tag: "TOKEN RESPONSE", message: decryptedMessage);

      if (dioResponse.statusCode == 200) {
        await _sharedPref.setTokenIsRefreshed("true");
        token = decryptedMessage["token"] ?? "";
        currentToken.value = token;
        await _sharedPref.addDeviceData(token);
        routes = CryptLib.gcmDecrypt(decryptedMessage["payload"]["Routes"],
                currentIv.value, currentKey.value) ??
            "";

        AppLogger.appLogI(tag: "REQ:ROUTES", message: routes);
        await CommonSharedPref.addRoutes(json.decode(routes));
      }
    } catch (e) {
      await _sharedPref.setTokenIsRefreshed("false");
      AppLogger.appLogE(tag: "GET TOKEN ERROR:", message: e.toString());
    }
    return dioResponse?.statusCode;
  }

  Future<UIResponse?> getUIData(FormId formId) async {
    UIResponse? uiResponse;
    var decrypted;

    final route = await _sharedPref.getRoute("staticdata".toLowerCase());
    var res = await performDioRequest(await dioRequestBodySetUp(formId.name),
        route: route, useGZIPDecryption: true);

    try {
      decrypted = jsonDecode(res ?? "{}") ?? "{}";
      // decrypted = await CryptLib.gcmDecrypt(res) ?? "",
      // decrypted = await CryptLib.oldDecrypt(res),
      AppLogger.appLogI(tag: "\n\n$formId RES", message: decrypted);
      AppLogger.writeResponseToFile(
          fileName: formId.name, response: decrypted.toString());
      uiResponse = UIResponse.fromJson(decrypted[0]);
    } catch (e) {
      if (e.runtimeType == FormatException) {
        AppLogger.appLogE(
            tag: "UI DATA EXCEPTION",
            message: "Trying to parse invalid response");
        return uiResponse;
      }
      AppLogger.appLogE(tag: "DECODE UI DATA:ERROR", message: e.toString());
    }
    return uiResponse ?? UIResponse(status: "XXXX");
  }

  Future<StaticResponse?> getStaticData(
      {currentStaticDataVersion, formId = "STATICDATA"}) async {
    var decrypted;
    StaticResponse? staticResponse;
    final route = await _sharedPref.getRoute("other".toLowerCase());
    var res = await performDioRequest(await dioRequestBodySetUp(formId),
        route: route);

    try {
      decrypted = jsonDecode(res ?? "{}") ?? "{}";
      // decrypted = await CryptLib.decryptResponse(res),
      // decrypted = CryptLib.gzipDecompressStaticData(res),
      AppLogger.appLogI(tag: "\n\nSTATIC DATA RES:", message: decrypted);
      AppLogger.writeResponseToFile(
          fileName: "Static", response: decrypted.toString());
      staticResponse = StaticResponse.fromJson(decrypted);
    } catch (e) {
      AppLogger.appLogE(tag: "DECODE:ERROR", message: e.toString());
    }
    return staticResponse;
  }

  Future<DynamicResponse> dynamicRequest({
    required formID,
    required requestObj,
    required webHeader,
  }) async {
    var decrypted;
    DynamicResponse? dynamicResponse;
    final route = await _sharedPref
        .getRoute(webHeader?.toLowerCase() ?? "other".toLowerCase());
    var request = await dioRequestBodySetUp(formID, objectMap: requestObj);

    var res = await performDioRequest(request, route: route);

    try {
      decrypted = jsonDecode(res ?? "{}") ?? "{}";
      AppLogger.appLogI(tag: "\n\nnDYNAMIC RESPONSE", message: decrypted);
      dynamicResponse = DynamicResponse.fromJson(decrypted);
    } catch (e) {
      AppLogger.appLogE(tag: "DECODE:ERROR", message: e.toString());
      return DynamicResponse(status: "XXXX");
    }
    return dynamicResponse;
  }

  Future<ActivationResponse> login(String encryptedPin,
      {formId = "LOGIN"}) async {
    var decrypted;
    Map<String, dynamic> requestObj = {};
    ActivationResponse? activationResponse;

    // requestObj["AppNotificationID"] = Constants.appNotificationID;
    requestObj["MobileNumber"] = await _sharedPref.getCustomerMobile();
    requestObj["AppNotificationID"] = await _sharedPref.getFirebaseToken();
    requestObj["Login"] = {"LoginType": "PIN"};
    requestObj["EncryptedFields"] = {"PIN": "$encryptedPin"};

    final route = await _sharedPref.getRoute("auth".toLowerCase());
    var res = await performDioRequest(
        await dioRequestBodySetUp(formId, objectMap: requestObj),
        route: route);

    try {
      decrypted = jsonDecode(res ?? "{}") ?? "{}";
      AppLogger.appLogI(tag: "\n\nnACTIVATION RESPONSE", message: decrypted);
      AppLogger.writeResponseToFile(
          fileName: "Login_res", response: decrypted.toString());
      activationResponse = ActivationResponse.fromJson(decrypted);
    } catch (e) {
      AppLogger.appLogE(tag: "DECODE:ERROR", message: e.toString());
    }
    return activationResponse ?? ActivationResponse(status: "XXXX");
  }

  Future<ActivationResponse> activateMobile(
      {mobileNumber, encryptedPin, formId = "ACTIVATIONREQ"}) async {
    var decrypted;
    ActivationResponse? activationResponse;

    Map<String, dynamic> requestObj = {};
    requestObj["MobileNumber"] = mobileNumber;
    requestObj["Activation"] = {};
    requestObj["EncryptedFields"] = {"PIN": "$encryptedPin"};

    final route = await _sharedPref.getRoute("auth".toLowerCase());
    var res = await performDioRequest(
        await dioRequestBodySetUp(formId,
            objectMap: requestObj, isAuthenticate: true),
        route: route);

    try {
      decrypted = jsonDecode(res ?? "{}") ?? "{}";
      logger.d("\n\nACTIVATION RESPONSE: $decrypted");
      activationResponse = ActivationResponse.fromJson(decrypted);
    } catch (e) {
      AppLogger.appLogE(tag: "DECODE:ERROR", message: e.toString());
    }
    return activationResponse ?? ActivationResponse(status: "XXXX");
  }

  Future<ActivationResponse> verifyOTP(
      {mobileNumber, key, formId = "ACTIVATE"}) async {
    var decrypted;
    final encryptedKey = CryptLib.encryptField(key);
    ActivationResponse? activationResponse;

    Map<String, dynamic> requestObj = {};
    requestObj["MobileNumber"] = mobileNumber;
    requestObj["Activation"] = {};
    requestObj["EncryptedFields"] = {"Key": "$encryptedKey"};

    final route = await _sharedPref.getRoute("auth".toLowerCase());
    var res = await performDioRequest(
        await dioRequestBodySetUp(formId,
            objectMap: requestObj, isAuthenticate: true),
        route: route);

    try {
      decrypted = jsonDecode(res ?? "{}") ?? "{}";
      logger.d("\n\nOTP VERIFICATION RESPONSE: $decrypted");
      activationResponse = ActivationResponse.fromJson(decrypted);
    } catch (e) {
      AppLogger.appLogE(tag: "DECODE:ERROR", message: e.toString());
    }
    return activationResponse ?? ActivationResponse(status: "XXXX");
  }

  Future<DynamicResponse?> checkAccountBalance(
      {required bankAccountID,
      required merchantID,
      required moduleID,
      formId = "PAYBILL"}) async {
    var decrypted;
    DynamicResponse? dynamicResponse;
    Map<String, dynamic> innerMap = {};
    Map<String, dynamic> requestObj = {};
    innerMap["BANKACCOUNTID"] = bankAccountID;
    innerMap["MerchantID"] = merchantID;
    requestObj["ModuleID"] = moduleID;
    requestObj["PayBill"] = innerMap;

    final route = await _sharedPref.getRoute("account".toLowerCase());
    var res = await performDioRequest(
        await dioRequestBodySetUp(formId, objectMap: requestObj),
        route: route);

    try {
      decrypted = jsonDecode(res ?? "{}") ?? "{}";
      logger.d("\n\nBANK BALANCE RESPONSE: $decrypted");
      dynamicResponse = DynamicResponse.fromJson(decrypted);
    } catch (e) {
      AppLogger.appLogE(tag: "DECODE:ERROR", message: e.toString());
    }
    return dynamicResponse ?? DynamicResponse(status: "XXX");
  }

  Future<DynamicResponse?> checkMiniStatement(
      {required bankAccountID,
      required merchantID,
      required moduleID,
      formId = "PAYBILL"}) async {
    var decrypted;
    DynamicResponse? dynamicResponse;
    Map<String, dynamic> innerMap = {};
    Map<String, dynamic> requestObj = {};
    innerMap["BANKACCOUNTID"] = bankAccountID;
    innerMap["MerchantID"] = merchantID;
    requestObj["ModuleID"] = moduleID;
    requestObj["PayBill"] = innerMap;
    requestObj["MerchantID"] = merchantID;

    final route = await _sharedPref.getRoute("account".toLowerCase());
    var res = await performDioRequest(
        await dioRequestBodySetUp(formId, objectMap: requestObj),
        route: route);

    try {
      decrypted = jsonDecode(res ?? "{}") ?? "{}";
      logger.d("\n\nMINI-STATEMENT RESPONSE: $decrypted");

      dynamicResponse = DynamicResponse.fromJson(decrypted);
    } catch (e) {
      AppLogger.appLogE(tag: "DECODE:ERROR", message: e.toString());
    }
    return dynamicResponse ?? DynamicResponse(status: "XXX");
  }

  Future<ActivationResponse> standardOTPVerify(
      {mobileNumber,
      key,
      merchantID,
      serviceName,
      RouteUrl url = RouteUrl.other}) async {
    var decrypted;
    // final encryptedKey = CryptLib.encryptField(key);
    ActivationResponse? activationResponse;

    Map<String, dynamic> requestObj = {};
    requestObj[RequestParam.MerchantID.name] = merchantID;
    requestObj["SERVICENAME"] = serviceName;
    requestObj["DynamicForm"] = {
      "MOBILENUMBER": mobileNumber,
      RequestParam.MerchantID.name: merchantID,
      RequestParam.HEADER.name: "OTPVERIFY",
      "SERVICENAME": serviceName,
      "OTPKEY": "$key"
    };

    final route = await _sharedPref.getRoute(url.name.toLowerCase());
    var res = await performDioRequest(
        await dioRequestBodySetUp(FormId.DBCALL.name,
            objectMap: requestObj, isAuthenticate: true),
        route: route);

    try {
      decrypted = jsonDecode(res ?? "{}") ?? "{}";
      logger.d("\n\nOTP VERIFICATION RESPONSE: $decrypted");
      activationResponse = ActivationResponse.fromJson(decrypted);
    } catch (e) {
      AppLogger.appLogE(tag: "DECODE:ERROR", message: e.toString());
    }
    return activationResponse ?? ActivationResponse(status: "XXXX");
  }
}
