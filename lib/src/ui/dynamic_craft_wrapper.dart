part of craft_dynamic;

class DynamicCraftWrapper extends StatefulWidget {
  final Widget dashboard;
  final Widget appLoadingScreen;
  final Widget appTimeoutScreen;
  final Widget appInactivityScreen;
  final ThemeData appTheme;
  List<LocalizationsDelegate>? localizationDelegates;
  bool localizationIsEnabled;
  bool useExternalBankID;
  bool showAccountBalanceInDropdowns;

  DynamicCraftWrapper(
      {super.key,
      required this.dashboard,
      required this.appLoadingScreen,
      required this.appTimeoutScreen,
      required this.appInactivityScreen,
      required this.appTheme,
      this.localizationDelegates,
      this.useExternalBankID = false,
      this.localizationIsEnabled = false,
      this.showAccountBalanceInDropdowns = false});

  @override
  State<DynamicCraftWrapper> createState() => _DynamicCraftWrapperState();
}

class _DynamicCraftWrapperState extends State<DynamicCraftWrapper>
    with WidgetsBindingObserver {
  final _connectivityService = ConnectivityService();
  final _initRepository = InitRepository();
  final _sessionRepository = SessionRepository();
  final _sharedPref = CommonSharedPref();
  static const Duration idleDuration = Duration(minutes: 2);
  Timer? _idleTimer;
  var _appTimeout = 10000;

  @override
  void initState() {
    super.initState();
    showLoadingScreen.value = true;
    initializeApp();
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  void _resetTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(idleDuration, _logout);
  }

  void _logout() {
    CommonUtils.getXRouteAndPopAll(widget: widget.appInactivityScreen);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _idleTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _resetTimer();
    }
  }

  initializeApp() async {
    await DeviceInfo.performDeviceSecurityScan();
    await HiveUtil.initializeHive();
    await _connectivityService.initialize();
    _sessionRepository.stopSession();
    useExternalBankID.value = widget.useExternalBankID;

    if (!widget.showAccountBalanceInDropdowns) {
      showAccountBalanceInDropdowns.value = false;
    }

    await getAppLaunchCount();
    if (!kIsWeb) {
      await PermissionUtil.checkRequiredPermissions();
    }
    getCurrentLatLong();
    await getAppData();
  }

  getAppLaunchCount() async {
    var launchCount = await _sharedPref.getLaunchCount();
    if (launchCount == 0) {
      _sharedPref.clearPrefs();
      _sharedPref.setLaunchCount(launchCount++);
      await _sharedPref.setLanguageID("ENG");
    }
    if (launchCount < 5) {
      _sharedPref.setLaunchCount(launchCount++);
    }
  }

  getAppData() async {
    await _initRepository.getAppToken();
    await _initRepository.getAppUIData();
    showLoadingScreen.value = false;
    var timeout = await _sharedPref.getAppIdleTimeout();
    setState(() {
      _appTimeout = timeout;
    });
    periodicActions(_appTimeout);
  }

  periodicActions(int timeout) {
    Timer.periodic(Duration(milliseconds: timeout), (timer) {
      _sharedPref.setTokenIsRefreshed("false");
      _initRepository.getAppToken();
      getCurrentLatLong();
    });
  }

  getCurrentLatLong() {
    LocationUtil.getLatLong().then((value) {
      _sharedPref.setLatLong(json.encode(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return _sessionRepository.getSessionManager(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => PluginState()),
            ChangeNotifierProvider(create: (context) => DynamicState()),
            ChangeNotifierProvider(create: (context) => DropDownState()),
          ],
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _resetTimer,
            onPanDown: (_) => _resetTimer(),
            onScaleStart: (_) => _resetTimer(),
            child: GetMaterialApp(
              localizationsDelegates: widget.localizationIsEnabled
                  ? widget.localizationDelegates ??
                      context.localizationDelegates
                  : null,
              supportedLocales: widget.localizationIsEnabled
                  ? context.supportedLocales
                  : [const Locale('en')],
              locale: widget.localizationIsEnabled ? context.locale : null,
              debugShowCheckedModeBanner: false,
              theme: widget.appTheme,
              home: Obx(() {
                return showLoadingScreen.value
                    ? widget.appLoadingScreen
                    : widget.dashboard;
              }),
              navigatorKey: Get.key,
              builder: (context, child) {
                Provider.of<PluginState>(context, listen: false)
                    .setLogoutScreen(widget.appTimeoutScreen);

                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: child!,
                );
              },
            ),
          ),
        ),
        context: context,
        _appTimeout,
        widget.appInactivityScreen,
        widget.appTimeoutScreen);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _idleTimer?.cancel();
    super.dispose();
  }
}
