part of craft_dynamic;

const storage = FlutterSecureStorage();
final prefs = SharedPreferences.getInstance();

class CommonSharedPref {
  setLaunchCount(int launchCount) async {
    prefs.then((pref) {
      pref.setInt("launchCount", launchCount);
    });
  }

  getLaunchCount() async {
    var pref = await prefs;
    return pref.getInt("launchCount") ?? 0;
  }

  addDeviceData(String token) async {
    return await storage.write(key: "token", value: token);
  }

  static addRoutes(Map routesMap) async {
    routesMap.forEach((key, value) {
      storage.write(key: key, value: value.toLowerCase());
    });
  }

  addStaticDataVersion(int version) async {
    await storage.write(key: "currentDataVersion", value: version.toString());
  }

  addActivationData(String mobileNumber, String customerID) async {
    await storage.write(key: "customerMobile", value: mobileNumber);
    await storage.write(key: "customerID", value: customerID);
    await storage.write(key: "appactivated", value: "true");
  }

  getStaticDataVersion() async {
    return int.parse(await storage.read(key: "currentDataVersion") ?? "0");
  }

  addAppIdleTimeout(int? appIdleTimeout) async {
    if (appIdleTimeout != null) {
      await storage.write(
          key: "appIdleTimeout", value: appIdleTimeout.toString());
    }
  }

  Future<bool> getAppActivationStatus() async {
    var isActivated = await storage.read(key: "appactivated");
    if (isActivated == "true") {
      return true;
    }
    return false;
  }

  getAppIdleTimeout() async {
    return int.parse(await storage.read(key: "appIdleTimeout") ?? "100000");
  }

  getRoute(String routeName) async {
    return await storage.read(key: routeName);
  }

  addUserAccountInfo({required key, required value}) async {
    await storage.write(key: key, value: value);
  }

  acceptTermsAndConditions(bool accept) async {
    await storage.write(key: "terms&conditions", value: accept.toString());
  }

  checkTermsAndConditions() async {
    var value = await storage.read(key: "terms&conditions");
    if (value == "true") {
      return true;
    }
    return false;
  }

  setSkyBlueTheme(bool skyblue) async {
    await storage.write(key: "skyblue", value: skyblue.toString());
  }

  Future<bool> checkSkyBlueTheme() async {
    var value = await storage.read(key: "skyblue");
    if (value == "true") {
      return true;
    }
    return false;
  }

  getUserAccountInfo(UserAccountData key) async =>
      await storage.read(key: key.name);

  addCustomerMobile(String customermobile) async {
    return await storage.write(key: "customerMobile", value: customermobile);
  }

  getCustomerMobile() async {
    return await storage.read(key: "customerMobile");
  }

  getCustomerID() async {
    return await storage.read(key: "customerID");
  }

  Future<String?> getCustomerFirstName() async {
    return await storage.read(key: "FirstName");
  }

  getUserData(String key) async {
    return await storage.read(key: key);
  }

  getLocalToken() async {
    return await storage.read(key: "token");
  }

  getLocalDevice() async {
    return await storage.read(key: "device");
  }

  getLocalIv() async {
    return await storage.read(key: "iv");
  }

  getBio() async {
    return await storage.read(key: "biometric") ?? "false";
  }

  setBio(bool isBio) async {
    await storage.write(key: "biometric", value: isBio.toString());
  }

  setBioPin(String bioPin) async {
    await storage.write(key: "biopin", value: bioPin);
  }

  getBioPin() async {
    return await storage.read(key: "biopin");
  }

  setUniqueID(String uniqueID) async {
    await storage.write(key: "uniqueID", value: uniqueID);
  }

  getUniqueID() async {
    return await storage.read(key: "uniqueID");
  }

  setLatLong(String latlong) async {
    await storage.write(key: "latlong", value: latlong);
  }

  getLatLong() async {
    return json.decode(await storage.read(key: "latlong") ?? "{}");
  }

  setBankID(String? bankID) async {
    await storage.write(key: "bankID", value: bankID);
  }

  getBankID() async {
    return await storage.read(key: "bankID");
  }

  setLanguageID(String languageID) async {
    return await storage.write(key: "languageID", value: languageID);
  }

  getLanguageID() async {
    return await storage.read(key: "languageID") ?? "ENG";
  }

  setTokenIsRefreshed(String status) async {
    return await storage.write(key: "tokenIsRefreshed", value: status);
  }

  getTokenIsRefreshed() async {
    var tokenIsRefreshed =
        await storage.read(key: "tokenIsRefreshed") ?? "false";
    if (tokenIsRefreshed == "true") {
      return true;
    } else {
      return false;
    }
  }

  setIsListeningToFocusState(bool state) async {
    return await storage.write(
        key: "applostfocusstate", value: state.toString());
  }

  getIsListeningToFocusState() async {
    var state = await storage.read(key: "applostfocusstate") ?? "true";
    if (state == "true") {
      return true;
    }
    return false;
  }

  setTempLanguage(String templanguage) async {
    return await storage.write(key: "templanguage", value: templanguage);
  }

  Future<String?> getTempLanguage() async =>
      await storage.read(key: "templanguage");

  //Set type of bank id used for app (false if defined in plugin config, true if used from activation response)
  setIsExternalBankIDType(bool type) async {
    return await storage.write(key: "bankidtype", value: type.toString());
  }

  Future<bool> getExternalBankIDType() async {
    var type = await storage.read(key: "bankidtype");
    if (type == "true") {
      return true;
    }
    return false;
  }

  addFirebaseToken(String? token) async {
    await storage.write(key: "firebasetoken", value: token);
  }

  Future<String?> getFirebaseToken() async {
    var firebaseToken = await storage.read(key: "firebasetoken");
    return firebaseToken;
  }

  clearPrefs() async {
    await storage.deleteAll();
  }
}
