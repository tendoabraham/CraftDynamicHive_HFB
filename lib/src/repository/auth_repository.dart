part of craft_dynamic;

final _userAccountRepository = UserAccountRepository();
final _initRepository = InitRepository();
final _profileRepository = ProfileRepository();

class AuthRepository {
  final _services = APIService();

  Future<bool> biometricLogin(TextEditingController pinController,
      {isButtonAction = false, context}) async {
    String bioEnabled = await _sharedPref.getBio();
    if (bioEnabled == "true") {
      if (await BioMetricUtil.biometricAuthenticate()) {
        String bioPin = await _sharedPref.getBioPin();
        pinController.text = CryptLib.decryptField(encrypted: bioPin);
        var res = await login(pinController.text);
        if (res.status == StatusCode.success.statusCode) {
          return true;
        } else {
          CommonUtils.showToast(res.message ?? "Login failed");
          return false;
        }
      }
    } else {
      if (isButtonAction) {
        var message =
            "Login with fingerprint/face unlock not enabled, please login and enable it in \"Biometrics Login\" menu";
        if (context != null) {
          AlertUtil.showAlertDialog(context, message,
              isInfoAlert: true, title: "Info");
        } else {
          CommonUtils.showToast(message);
        }
      }
    }
    return false;
  }

  // Call this method to login
  Future<ActivationResponse> login(String pin) async {
    String? currentLanguage = await _sharedPref.getLanguageID();
    var localdataversion = await _sharedPref.getStaticDataVersion();
    bool refreshUIData = false;

    ActivationResponse activationResponse =
        await _services.login(CryptLib.encryptField(pin));
    if (activationResponse.status == StatusCode.success.statusCode ||
        activationResponse.status == StatusCode.otp.statusCode) {
      await _sharedPref.setIsListeningToFocusState(true);
      await _userAccountRepository.addUserAccountData(activationResponse);
      String? currentLanguageIDSetting = activationResponse.languageID;
      var newdataversion = activationResponse.staticDataVersion;
      // await _sharedPref.addStaticDataVersion(newdataversion ?? 0);

      if (currentLanguage != null &&
          currentLanguageIDSetting != null &&
          currentLanguageIDSetting != "" &&
          currentLanguage != currentLanguageIDSetting) {
        await _sharedPref.setLanguageID(currentLanguageIDSetting);
        refreshUIData = true;
      }

      if (newdataversion != null && newdataversion > localdataversion ||
          refreshUIData) {
        await _initRepository.getAppUIData(refreshData: true);
      }
      await _profileRepository.getAllAccountBalancesAndSaveInAppState();
    } else if (activationResponse.status == StatusCode.changePin.statusCode) {
      await _sharedPref.setIsListeningToFocusState(true);
      _moduleRepository.getModuleById(ModuleId.PIN.name).then((module) {
        CommonUtils.getxNavigate(
            widget: DynamicWidget(
          moduleItem: module,
        ));
      });
    }
    return activationResponse;
  }

  // Call this method to activate app
  Future<ActivationResponse> activate(
      {required mobileNumber, required pin}) async {
    ActivationResponse activationResponse = await _services.activateMobile(
      mobileNumber: mobileNumber,
      encryptedPin: CryptLib.encryptField(pin),
    );
    if (activationResponse.status == StatusCode.success.statusCode) {
      bool isUsingExternalBankID = useExternalBankID.value;

      AppLogger.appLogD(
          tag: "AUTH REPO",
          message: "use external bank id $isUsingExternalBankID");
      if (isUsingExternalBankID) {
        var bankID = activationResponse.message;
        if (bankID != null && bankID.isNotEmpty) {
          AppLogger.appLogD(
              tag: "AUTH REPO", message: "setting new bank id as $bankID");
          await _sharedPref.setBankID(bankID);
        }
      }
    } else if (activationResponse.status ==
        StatusCode.setsecurityquestions.statusCode) {
      _sharedPref.addCustomerMobile(mobileNumber);

      _moduleRepository
          .getModuleById(ModuleId.SECRETQUESTIONS.name)
          .then((module) {
        CommonUtils.getxNavigate(
            widget: DynamicWidget(
          moduleItem: module,
        ));
      });
    }
    return activationResponse;
  }

  // Call this method to verify otp
  Future<ActivationResponse> verifyOTP(
      {required mobileNumber, required otp}) async {
    ActivationResponse activationResponse =
        await _services.verifyOTP(mobileNumber: mobileNumber, key: otp);
    if (activationResponse.customerID != null &&
        activationResponse.customerID != "") {
      _sharedPref.addActivationData(
          mobileNumber, activationResponse.customerID!);

      await _initRepository.getAppUIData();
    }
    return activationResponse;
  }

  Future<ActivationResponse> standardOTPVerification(
      {mobileNumber,
      key,
      merchantID,
      serviceName,
      RouteUrl route = RouteUrl.other}) async {
    return await _services.standardOTPVerify(
        mobileNumber: mobileNumber,
        key: key,
        merchantID: merchantID,
        serviceName: serviceName,
        url: route);
  }
}
