// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables
part of craft_dynamic;

var classname = "dynamic_components";

class DynamicInput {
  static Map<String?, dynamic> formInputValues = {};
  static Map<String?, dynamic> encryptedField = {};

  clearDynamicInput() {
    formInputValues.clear();
    encryptedField.clear();
  }
}

class BaseFormComponent extends StatelessWidget {
  const BaseFormComponent(
      {super.key,
      required this.child,
      required this.formItem,
      required this.moduleItem,
      required this.formItems,
      required this.formKey});

  final Widget child;
  final FormItem formItem;
  final ModuleItem moduleItem;
  final List<FormItem> formItems;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BaseFormInheritedComponent(
          widget: child,
          formItem: formItem,
          moduleItem: moduleItem,
          formItems: formItems,
          formKey: formKey,
        ),
        formItem.controlType == ViewType.HIDDEN.name ||
                formItem.controlType == ViewType.CONTAINER.name ||
                formItem.controlType == ViewType.RBUTTON.name ||
                formItem.controlType == ViewType.TAB.name ||
                formItem.controlType == ViewType.LIST.name ||
                formItem.controlType == ViewType.TITLE.name ||
                formItem.controlType == ViewType.SELECTEDTEXT.name ||
                formItem.controlType == ViewType.FORM.name ||
                formItem.controlType == ViewType.IMAGE.name ||
                formItem.controlType == ViewType.TEXTVIEW.name ||
                formItem.controlType == ViewType.HORIZONTALTEXT.name
            ? const SizedBox()
            : const SizedBox(
                height: 18,
              )
      ],
    );
  }
}

class BaseFormInheritedComponent extends InheritedWidget {
  final FormItem formItem;
  final ModuleItem moduleItem;
  final List<FormItem> formItems;
  final GlobalKey<FormState> formKey;
  final Widget widget;
  List<dynamic>? jsonText;

  BaseFormInheritedComponent(
      {super.key,
      required this.widget,
      required this.formItem,
      required this.moduleItem,
      required this.formItems,
      required this.formKey,
      this.jsonText})
      : super(child: widget);

  static BaseFormInheritedComponent? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<BaseFormInheritedComponent>();
  }

  @override
  bool updateShouldNotify(covariant BaseFormInheritedComponent oldWidget) {
    return oldWidget.formItem != formItem;
  }
}

class DynamicTextFormField extends StatefulWidget implements IFormWidget {
  Function? func;
  bool isEnabled;
  String? customText;
  TextEditingController? controller;
  List<dynamic>? formFields;

  DynamicTextFormField(
      {super.key,
      this.isEnabled = true,
      this.func,
      this.customText,
      this.controller,
      this.formFields});

  @override
  Widget render() {
    return DynamicTextFormField(
      formFields: formFields,
    );
  }

  @override
  State<DynamicTextFormField> createState() => _DynamicTextFormFieldState();
}

class _DynamicTextFormFieldState extends State<DynamicTextFormField> {
  var controller = TextEditingController();
  var inputType = TextInputType.text;
  bool isObscured = false;
  IconButton? suffixIcon;
  FormItem? formItem;
  String? initialValue;
  String linkedToControlText = "";

  @override
  void initState() {
    super.initState();
    if (widget.customText != null) {
      controller.text = widget.customText!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    formItem = BaseFormInheritedComponent.of(context)?.formItem;
  }

  updateControllerText(String value) {
    controller.text = value;
  }

  @override
  Widget build(BuildContext context) {
    bool isEnabled = formItem?.isEnabled ?? false;

    return Consumer<PluginState>(builder: (context, state, child) {
      isObscured = formItem?.controlFormat == ControlFormat.PinNumber.name ||
              formItem?.controlFormat == ControlFormat.PIN.name
          ? true
          : false;

      var textFieldParams = WidgetUtil.checkControlFormat(
          formItem!.controlFormat!,
          context: context,
          isObscure: isObscured,
          refreshParent: refreshParent);
      inputType = formItem?.controlFormat == ControlFormat.PinNumber.name ||
              formItem?.controlFormat == ControlFormat.PIN.name
          ? TextInputType.number
          : textFieldParams['inputType'];
      var formFieldValue = widget.formFields?.firstWhereOrNull((formField) =>
              formField[FormFieldProp.ControlID.name].toLowerCase() ==
              formItem?.controlId?.toLowerCase()) ??
          "";

      if (formFieldValue.isNotEmpty) {
        controller.text = formFieldValue[FormFieldProp.ControlValue.name] ?? "";
      }

      if (formItem?.linkedToRowID != null) {
        AppLogger.appLogD(
            tag: "all dynamic dropdown data ${formItem?.linkedToRowID}",
            message: state.dynamicDropDownData);
        linkedToControlText = state.dynamicDropDownData[formItem?.linkedToRowID]
                ?[formItem?.linkedToRowID] ??
            "";
      }

      if (linkedToControlText.isNotEmpty) {
        setInitialText(linkedToControlText);
      }

      var properties = TextFormFieldProperties(
          isEnabled: formFieldValue.isNotEmpty ||
                  linkedToControlText.isNotEmpty ||
                  isEnabled
              ? false
              : true,
          isObscured: isObscured ? state.obscureText : false,
          controller: controller,
          textInputType: inputType,
          maxLength: formItem?.maxLength,
          maxLines: formItem?.maxLines,
          textStyle: TextStyle(
            fontSize: 12,
            color: Color(0xff2532A1),
            fontWeight: FontWeight.normal,
            fontFamily: "DMSans",
          ),
          inputDecoration: InputDecoration(
              // border: const OutlineInputBorder(),
              labelText: formItem?.controlText,
              suffixIcon: textFieldParams['suffixIcon'],
              contentPadding: formItem?.verticalPadding != null
                  ? EdgeInsets.symmetric(
                      vertical: formItem?.verticalPadding ?? 18, horizontal: 14)
                  : null),
          isAmount: formItem?.controlFormat == ControlFormat.Amount.name);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${formItem?.controlText}",
            style: TextStyle(
                fontSize: 12,
                fontFamily: "Manrope",
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          WidgetFactory.buildTextField(context, properties, validator)
        ],
      );
    });
  }

  String? validator(String? value) {
    var formattedValue = value.toString().replaceAll(',', '');
    if (formItem!.isMandatory! && value!.isEmpty) {
      return 'Input required*';
    }

    if (inputType == TextInputType.number &&
        formItem?.controlFormat == ControlFormat.Amount.name) {
      if (formItem?.maxValue != null) {
        if (formItem!.maxValue!.isNotEmpty) {
          if (double.parse(formattedValue) >
              double.parse(formItem!.maxValue!)) {
            return "Maximum accepted is ${formItem!.maxValue}";
          }
          if (formItem?.minValue != null) {
            if (double.parse(formattedValue) <
                double.parse(formItem!.minValue!)) {
              return "Minimum required is ${formItem?.minValue}";
            }
          }
        }
      }
    }
    if (isObscured) {
      Provider.of<PluginState>(context, listen: false).addEncryptedFields({
        "${formItem?.serviceParamId}":
            CryptLib.encryptField(formattedValue.replaceAll(" ", ""))
      });
    } else {
      Provider.of<PluginState>(context, listen: false)
          .addFormInput({"${formItem?.serviceParamId}": "$value"});
    }
    return null;
  }

  void setInitialText(String? initialText) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.text = initialText ?? "";
    });
  }

  void refreshParent(bool status, {newText}) {
    setState(() {
      status;
      controller.text = DateFormat('yyyy-MM-dd').format(newText);
    });
  }
}

class HiddenWidget implements IFormWidget {
  final _sharedPref = CommonSharedPref();
  List<dynamic>? formFields;
  FormItem? formItem;

  HiddenWidget({this.formFields, this.formItem});

  @override
  Widget render() {
    return Builder(builder: (context) {
      String controlValue = "";
      if (formItem?.controlFormat == ControlFormat.OWNNUMBER.name) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _sharedPref.getCustomerMobile().then((value) {
            if (value != null && value.toString().isNotEmpty) {
              Provider.of<PluginState>(context, listen: false)
                  .addFormInput({"${formItem?.serviceParamId}": value});
            }
          });
        });
      } else {
        if (formFields != null) {
          formFields?.forEach((formField) {
            if (formField[FormFieldProp.ControlID.name] ==
                formItem?.controlId) {
              controlValue = formField[FormFieldProp.ControlValue.name];
              if (controlValue.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Provider.of<PluginState>(context, listen: false).addFormInput(
                      {"${formItem?.serviceParamId}": controlValue});
                });
              }
            }
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<PluginState>(context, listen: false).addFormInput(
                {formItem?.serviceParamId: formItem?.controlValue});
          });
        }
      }

      return const Visibility(
        visible: false,
        child: SizedBox(),
      );
    });
  }
}

class DynamicButton extends StatefulWidget implements IFormWidget {
  const DynamicButton({super.key});

  @override
  Widget render() {
    return const DynamicButton();
  }

  @override
  State<DynamicButton> createState() => _DynamicButtonState();
}

class _DynamicButtonState extends State<DynamicButton> {
  final _dynamicRequest = DynamicFormRequest();
  final _moduleRepository = ModuleRepository();
  FormItem? formItem;
  ModuleItem? moduleItem;
  var formKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    formItem = BaseFormInheritedComponent.of(context)?.formItem;
    moduleItem = BaseFormInheritedComponent.of(context)?.moduleItem;
    formKey = BaseFormInheritedComponent.of(context)?.formKey;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      return Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Consumer<PluginState>(builder: (context, state, child) {
            return state.loadingNetworkData
                ? SpinKitSpinningLines(
                    color: APIService.appPrimaryColor,
                    duration: Duration(milliseconds: 2000),
                    size: 40,
                  )
                : WidgetFactory.buildButton(context, onClick,
                    formItem?.controlText?.capitalizeFirstLetter() ?? "Submit");
          }));
    });
  }

  onClick() {
    if (formItem?.controlId == "CLOSE") {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      return;
    }

    if (formItem?.controlFormat == ControlFormat.OPENFORM.name) {
      getModule(formItem?.actionId ?? "").then((module) {
        CommonUtils.navigateToRoute(
            context: context,
            widget: DynamicWidget(
              moduleItem: module,
            ));
      });

      return;
    }

    if (formKey?.currentState?.validate()!) {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }

      if (formItem?.controlFormat == ControlFormat.NEXT.name) {
        Provider.of<PluginState>(context, listen: false).setDeleteForm(false);
        CommonUtils.navigateToRoute(
            context: context,
            widget: DynamicWidget(
              moduleItem: moduleItem,
              nextFormSequence: 2,
            ));
        return;
      } else {
        Provider.of<PluginState>(context, listen: false).setRequestState(true);
        _dynamicRequest
            .dynamicRequest(moduleItem,
                formItem: formItem,
                dataObj: Provider.of<PluginState>(context, listen: false)
                    .formInputValues,
                encryptedField: Provider.of<PluginState>(context, listen: false)
                    .encryptedFields,
                context: context,
                tappedButton: true)
            .then((value) {
          if (value?.status != StatusCode.unknown.statusCode) {
            AppLogger.appLogD(
                tag: "DYNAMIC BUTTON POST CALL",
                message: "Current status is --->${value?.message}");
            DynamicPostCall.processDynamicResponse(
                value!.dynamicData!, context, formItem!.controlId!,
                moduleItem: moduleItem);
          }
        });
      }
    } else {
      CommonUtils.vibrate();
    }
  }

  getModule(String moduleID) => _moduleRepository.getModuleById(moduleID);
}

class ImageDynamicDropDown extends StatefulWidget implements IFormWidget {
  const ImageDynamicDropDown({super.key});

  @override
  State<ImageDynamicDropDown> createState() => _ImageDynamicDropDownState();

  @override
  Widget render() => const ImageDynamicDropDown();
}

class _ImageDynamicDropDownState extends State<ImageDynamicDropDown> {
  final _apiService = APIService();
  FormItem? formItem;
  ModuleItem? moduleItem;
  String? _currentValue;
  Map<String, dynamic> extraFieldMap = {};
  List<dynamic> dropdownItems = [];

  Future<DynamicResponse?> getDropDownData(
          String actionID, ModuleItem moduleItem,
          {formID = "DBCALL", route = "other", merchantID}) =>
      _apiService.getDynamicDropDownValues(actionID, moduleItem,
          formID ?? "DBCALL", route ?? "other", merchantID);

  @override
  initState() {
    AppLogger.appLogD(
        tag: "images dropdown", message: "getting images for dropdown");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    formItem = BaseFormInheritedComponent.of(context)?.formItem;
    moduleItem = BaseFormInheritedComponent.of(context)?.moduleItem;

    return FutureBuilder<DynamicResponse?>(
        future: getDropDownData(formItem?.actionId ?? "", moduleItem!,
            formID: formItem?.formID,
            route: formItem?.route,
            merchantID: formItem?.merchantID),
        builder:
            (BuildContext context, AsyncSnapshot<DynamicResponse?> snapshot) {
          Widget child = DropdownButtonFormField2(
            value: _currentValue,
            decoration: InputDecoration(
                prefixIcon: ThreeLoadUtil(
              size: 24,
            )),
            hint: Text(
              formItem?.controlText ?? "",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            isExpanded: true,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            items: const [],
          );
          if (snapshot.hasData) {
            dropdownItems = snapshot.data?.dynamicList ?? [];
            if (dropdownItems.isEmpty) {
              child = DropdownButtonFormField2(
                value: _currentValue,
                hint: Text(
                  snapshot.data?.message ?? formItem?.controlText ?? "",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                isExpanded: true,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                items: const [],
              );
            } else {
              AppLogger.appLogD(
                  tag: "dropdown items", message: dropdownItems.first);
              _currentValue = formItem?.hasInitialValue ?? true
                  ? dropdownItems.first[formItem?.controlId]["Value"]
                  : null;
              var dropdownPicks = dropdownItems.asMap().entries.map((item) {
                Map<String, dynamic> jsonvalue =
                    item.value[formItem?.controlId] ?? {};
                var image = jsonvalue["ImageUrl"];
                var label = jsonvalue["Description"];
                var value = jsonvalue["Value"];

                return DropdownMenuItem(
                    value: value ?? formItem?.controlText,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            CachedNetworkImage(
                              imageUrl: image ?? formItem?.controlText,
                              placeholder: (context, url) => PulseLoadUtil(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              width: 70,
                              height: 70,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Text(
                              label ?? formItem?.controlText,
                              overflow: TextOverflow.ellipsis,
                            ))
                          ],
                        )));
              }).toList();
              dropdownPicks.toSet().toList();
              if (dropdownPicks.isNotEmpty &&
                  (formItem?.hasInitialValue ?? true)) {
                addInitialValueToLinkedField(context, dropdownItems.first);
              }
              child = DropdownButtonFormField(
                value: _currentValue,
                items: dropdownPicks,
                isExpanded: true,
                onChanged: (value) {},
                validator: (value) {
                  String? input = value.toString();
                  if ((formItem?.isMandatory ?? false) && input == "null") {
                    return 'Input required*';
                  }
                  debugPrint("value in dropdown is $value");
                  Provider.of<PluginState>(context, listen: false)
                      .addFormInput({"${formItem?.serviceParamId}": value});
                  return null;
                },
              );
            }
          }

          return child;
        });
  }

  getValueFromList(value) => dropdownItems
      .firstWhereOrNull((element) => element[formItem?.controlId] == value);

  void addInitialValueToLinkedField(BuildContext context, var initialValue) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (Provider.of<PluginState>(context, listen: false)
            .dynamicDropDownData
            .isEmpty) {
          Provider.of<PluginState>(context, listen: false)
              .addDynamicDropDownData(
                  {formItem?.controlId.toString() ?? "": initialValue});
        }
      } catch (e) {
        AppLogger.appLogE(tag: "Dropdown error", message: e.toString());
      }
    });
  }
}

class DynamicDropDown extends StatefulWidget implements IFormWidget {
  const DynamicDropDown({super.key});

  @override
  State<DynamicDropDown> createState() => _DynamicDropDownState();

  @override
  Widget render() => const DynamicDropDown();
}

class _DynamicDropDownState extends State<DynamicDropDown> {
  final _apiService = APIService();
  FormItem? formItem;
  ModuleItem? moduleItem;
  String? _currentValue;
  Map<String, dynamic> extraFieldMap = {};
  List<dynamic> dropdownItems = [];

  Future<DynamicResponse?> getDropDownData(
          String actionID, ModuleItem moduleItem,
          {formID = "DBCALL", route = "other", merchantID}) async =>
      _apiService.getDynamicDropDownValues(
          actionID, moduleItem, formID, route, merchantID);

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PluginState>(context, listen: false).clearDynamicDropDown();
    });
  }

  @override
  Widget build(BuildContext context) {
    formItem = BaseFormInheritedComponent.of(context)?.formItem;
    moduleItem = BaseFormInheritedComponent.of(context)?.moduleItem;

    return FutureBuilder<DynamicResponse?>(
        future: getDropDownData(formItem?.actionId ?? "", moduleItem!,
            formID: formItem?.formID,
            route: formItem?.route,
            merchantID: formItem?.merchantID),
        builder:
            (BuildContext context, AsyncSnapshot<DynamicResponse?> snapshot) {
          Widget child = DropdownButtonFormField2(
            value: _currentValue,
            decoration: InputDecoration(
              prefixIcon: ThreeLoadUtil(
                size: 24,
              ),
            ),
            hint: Text(
              formItem?.controlText ?? "",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: "DMSans"),
            ),
            isExpanded: true,
            style: const TextStyle(
                fontSize: 16, color: Color(0xff2532A1), fontFamily: "DMSans"),
            items: const [],
          );
          if (snapshot.hasData) {
            dropdownItems = snapshot.data?.dynamicList ?? [];
            AppLogger.appLogD(tag: "dropdown data-->", message: dropdownItems);

            if (dropdownItems.isEmpty) {
              child = DropdownButtonFormField2(
                value: _currentValue,
                hint: Text(
                  snapshot.data?.message ?? formItem?.controlText ?? "",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                isExpanded: true,
                style: const TextStyle(
                    fontSize: 16, color: Colors.black, fontFamily: "DMSans"),
                items: const [],
              );
            } else {
              _currentValue = formItem?.hasInitialValue ?? true
                  ? dropdownItems.first[formItem?.controlId]
                  : null;
              var dropdownPicks = dropdownItems.asMap().entries.map((item) {
                return DropdownMenuItem(
                  value:
                      item.value[formItem?.controlId] ?? formItem?.controlText,
                  child: Text(
                    item.value[formItem?.controlId] ?? formItem?.controlText,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                );
              }).toList();
              dropdownPicks.toSet().toList();
              if (dropdownPicks.isNotEmpty &&
                  (formItem?.hasInitialValue ?? true)) {
                addInitialValueToLinkedField(context, dropdownItems.first);
              }
              child = DropdownButtonFormField(
                value: _currentValue,
                decoration: InputDecoration(labelText: formItem?.controlText),
                isExpanded: true,
                style: const TextStyle(fontWeight: FontWeight.normal),
                onChanged: (value) {
                  Provider.of<PluginState>(context, listen: false)
                      .addDynamicDropDownData(
                          {formItem?.controlId ?? "": getValueFromList(value)});
                },
                validator: (value) {
                  String? input = value.toString();
                  if ((formItem?.isMandatory ?? false) && input == "null") {
                    return 'Input required*';
                  }
                  Provider.of<PluginState>(context, listen: false)
                      .addFormInput({
                    "${formItem?.serviceParamId}":
                        getValueFromList(value)[formItem?.controlId ?? ""]
                  });
                  return null;
                },
                items: dropdownPicks,
              );
            }
          }

          return child;
        });
  }

  getValueFromList(value) => dropdownItems
      .firstWhereOrNull((element) => element[formItem?.controlId] == value);

  void addInitialValueToLinkedField(BuildContext context, var initialValue) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (Provider.of<PluginState>(context, listen: false)
            .dynamicDropDownData
            .isEmpty) {
          Provider.of<PluginState>(context, listen: false)
              .addDynamicDropDownData(
                  {formItem?.controlId ?? "": initialValue});
        }
      } catch (e) {
        AppLogger.appLogE(tag: "Dropdown error", message: e.toString());
      }
    });
  }
}

class DropDown extends StatefulWidget implements IFormWidget {
  const DropDown({super.key});

  @override
  State<DropDown> createState() => _DropDownState();

  @override
  Widget render() => const DropDown();
}

class _DropDownState extends State<DropDown> {
  final _userCodeRepository = UserCodeRepository();
  List<UserCode> userCodes = [];
  Map<String, dynamic> extraFieldMap = {};
  Map<String, dynamic> relationIDMap = {};
  Map<String, dynamic> dropdownItems = {};

  FormItem? formItem;
  ModuleItem? moduleItem;
  String? _currentValue;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PluginState>(context, listen: false).clearDynamicDropDown();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      formItem = BaseFormInheritedComponent.of(context)?.formItem;
      moduleItem = BaseFormInheritedComponent.of(context)?.moduleItem;

      {
        return FutureBuilder<Map<String, dynamic>?>(
            future: getDropDownValues(formItem!, moduleItem!),
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, dynamic>?> snapshot) {
              AppLogger.appLogD(
                  tag: "dropdown", message: "getting dropdown data...");
              Widget child = DropdownButtonFormField2(
                value: _currentValue,
                hint: Text(
                  formItem!.controlText!,
                ),
                isExpanded: true,
                items: const [],
              );
              AppLogger.appLogD(
                  tag: "dropdown",
                  message: "snapshot has data...v${snapshot.data}");
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                AppLogger.appLogD(
                    tag: "dropdown", message: "snapshot has data...");
                var data = snapshot.data ?? {};
                dropdownItems = data;
                AppLogger.appLogD(
                    tag: "dropdown data-->", message: dropdownItems);

                child =
                    Consumer<DropDownState>(builder: (context, state, child) {
                  // dropdownItems = removeAllLoanAccounts(
                  //     dropdownItems, state.currentRepaymentAccounts);

                  AppLogger.appLogD(
                      tag: classname,
                      message:
                          "all values @${formItem?.controlId} --------> $data");

                  AppLogger.appLogD(
                      tag: "$classname:relationid @${formItem?.controlId}",
                      message:
                          Provider.of<DropDownState>(context, listen: false)
                              .currentRelationID);

                  var dropdownPicks = dropdownItems.entries.map((item) {
                    return DropdownMenuItem(
                      value: item.key,
                      child: Text(
                        item.value,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    );
                  }).toList();
                  dropdownPicks.sort((a, b) => (a.child as Text)
                      .data!
                      .compareTo((b.child as Text).data!));
                  dropdownPicks.toSet().toList();

                  if (dropdownPicks.isNotEmpty &&
                      (formItem?.hasInitialValue ?? true)) {
                    addInitialValueToLinkedField(context,
                        getFirstSubcodeID(dropdownItems.entries.first));
                  }

                  if (!isToAccountField(formItem?.controlId ?? "") &&
                      !isBillerName(formItem?.controlId ?? "") &&
                      (_currentValue?.isEmpty ?? true)) {
                    _currentValue = formItem?.hasInitialValue ?? true
                        ? dropdownItems.isNotEmpty
                            ? dropdownItems.entries.first.key
                            : null
                        : null;
                  }

                  if (isToAccountField(formItem?.controlId ?? "")) {
                    var dropdowns = dropdownPicks.firstWhereOrNull((item) =>
                        item.value ==
                        state.currentSelections?[ControlID.BANKACCOUNTID.name]);
                    dropdownPicks.remove(dropdowns);

                    if (_currentValue ==
                        state
                            .currentSelections?[ControlID.BANKACCOUNTID.name]) {
                      _currentValue = formItem?.hasInitialValue ?? true
                          ? dropdownPicks.isNotEmpty
                              ? "${dropdownPicks[0].value}"
                              : null
                          : null;
                    }
                  }

                  if (isBillerName(formItem?.controlId ?? "")) {
                    _currentValue = formItem?.hasInitialValue ?? true
                        ? dropdownPicks.isNotEmpty
                            ? "${dropdownPicks[0].value}"
                            : null
                        : null;
                  }

                  AppLogger.appLogD(
                      tag: "$classname@${formItem?.controlId}",
                      message:
                          "current relationid is --> ${state.currentRelationID} and current value set is $_currentValue");

                  return DropdownButtonFormField(
                    value: _currentValue,
                    decoration:
                        InputDecoration(labelText: formItem?.controlText),
                    isExpanded: true,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                    onChanged: ((value) => {
                          AppLogger.appLogD(
                              tag: 'dropdown component event elected',
                              message: value),
                          setState(() {
                            _currentValue = value.toString();
                          }),
                          Provider.of<PluginState>(context, listen: false)
                              .addDynamicDropDownData({
                            formItem?.controlId ?? "": {
                              formItem?.controlId ?? "": getValueFromList(value)
                            }
                          }),
                          state.addCurrentDropDownValue(
                              {formItem?.controlId: value}),
                          if (isBillerType(formItem?.controlId ?? ""))
                            {
                              state.addCurrentRelationID(
                                  getRelationIDValue(value)),
                            },
                          if (isFromAccountField(formItem?.controlId ?? ""))
                            {
                              state.setCurrentSelections(
                                  {formItem?.controlId: _currentValue}),
                            }
                        }),
                    validator: (value) {
                      AppLogger.appLogD(
                          tag: 'dropdown component validator value-->',
                          message: value);
                      String? input = value.toString();
                      if ((formItem?.isMandatory ?? false) && input == "null") {
                        return 'Input required*';
                      }

                      dropdownSelection.addAll({
                        formItem?.serviceParamId:
                            getValueFromKey(value.toString())
                      });

                      addDateFrequencyToState(value.toString());
                      Provider.of<PluginState>(context, listen: false)
                          .addFormInput({"${formItem?.serviceParamId}": value});
                      return null;
                    },
                    items: dropdownPicks,
                  );
                });
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${formItem?.controlText}",
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: "Manrope",
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  child
                ],
              );
            });
      }
    });
  }

  addDateFrequencyToState(String frequency) {
    if (formItem?.controlId == ControlID.FREQUENCY.name) {
      try {
        selectedDateFrequency.value = int.parse(frequency);
      } catch (e) {
        AppLogger.appLogD(tag: "dynamic_components", message: e);
      }
    }
  }

  String? getValueFromKey(String? value) =>
      dropdownItems.keys.firstWhereIndexedOrNull(
          (index, element) => dropdownItems[element] == value);

  String getFirstSubcodeID(MapEntry entry) => entry.key;

  getValueFromList(value) => extraFieldMap[value];

  getRelationIDValue(value) => relationIDMap[value];

  Future<BankAccount?> getAccountBranch(String accountID) async {
    final bankRepo = BankAccountRepository();
    return bankRepo.getBankAccount(accountID);
  }

  bool isToAccountField(String controlID) =>
      controlID.toLowerCase() == ControlID.TOACCOUNTID.name.toLowerCase()
          ? true
          : false;

  bool isBillerType(String controlID) =>
      controlID.toLowerCase() == ControlID.BILLERTYPE.name.toLowerCase()
          ? true
          : false;

  bool isBillerName(String controlID) =>
      controlID.toLowerCase() == ControlID.BILLERNAME.name.toLowerCase()
          ? true
          : false;

  bool isFromAccountField(String controlID) =>
      controlID.toLowerCase() == ControlID.BANKACCOUNTID.name.toLowerCase()
          ? true
          : false;

  Map<String, dynamic> removeAllLoanAccounts(Map<String, dynamic> dropdownItems,
      Map<String?, dynamic> allLoanAccounts) {
    Map<String, dynamic> items = dropdownItems;
    if (isFromAccountField(formItem?.controlId ?? "")) {
      AppLogger.appLogD(
          tag: "dynamic_components",
          message: "removing all loan accounts from From Account Dropdown");

      try {
        if (items.isNotEmpty) {
          var loanAccounts = allLoanAccounts.entries.toList();

          for (var account in loanAccounts) {
            items.removeWhere((key, value) => key == account.value);
          }
        }
      } catch (e) {
        AppLogger.appLogD(tag: "dynamic_components", message: e);
      }
    }
    return items;
  }

  void addInitialValueToLinkedField(BuildContext context, var initialValue) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (Provider.of<PluginState>(context, listen: false)
                    .dynamicDropDownData[formItem?.rowID?.toString()] ==
                {} ||
            Provider.of<DropDownState>(context, listen: false)
                    .currentDropDownValue[formItem?.controlId?.toString()] ==
                null) {
          Map<String, dynamic> map = {};

          map.addAll(
              {formItem?.controlId ?? "": getValueFromList(initialValue)});
          if (isFromAccountField(formItem?.controlId ?? "")) {
            Provider.of<DropDownState>(context, listen: false)
                .setCurrentSelections({formItem?.controlId: _currentValue});
          }
          Provider.of<PluginState>(context, listen: false)
              .addDynamicDropDownData({formItem?.controlId ?? "": map});
          Provider.of<DropDownState>(context, listen: false)
              .addCurrentDropDownValue({formItem?.controlId: initialValue});
          if (isBillerType(formItem?.controlId ?? "")) {
            Provider.of<DropDownState>(context, listen: false)
                .addCurrentRelationID(getRelationIDValue(initialValue));
          }
        }
      } catch (e) {
        AppLogger.appLogE(tag: "Dropdown error", message: e.toString());
      }
    });
  }

  Future<Map<String, dynamic>?>? getDropDownValues(
      FormItem formItem, ModuleItem moduleItem) async {
    if (formItem.controlFormat != ControlFormat.SELECTBANKACCOUNT.name ||
        formItem.controlFormat != ControlFormat.SELECTBENEFICIARY.name) {
      try {
        userCodes =
            await _userCodeRepository.getUserCodesById(formItem.dataSourceId);
        extraFieldMap = userCodes.fold<Map<String, dynamic>>(
            {}, (acc, curr) => acc..[curr.subCodeId] = curr.extraField);
        relationIDMap = userCodes.fold<Map<String, dynamic>>(
            {}, (acc, curr) => acc..[curr.subCodeId] = curr.relationId);
      } catch (e) {
        AppLogger.appLogE(tag: "Dropdown error", message: e.toString());
      }
    }
    return await IDropDownAdapter(formItem, moduleItem).getDropDownItems();
  }
}

class DynamicLabelWidget implements IFormWidget {
  DynamicResponse? dynamicResponse;
  final _dynamicRequest = DynamicFormRequest();

  getDynamicLabel(
          BuildContext context, FormItem? formItem, ModuleItem moduleItem) =>
      _dynamicRequest.dynamicRequest(
        moduleItem,
        formItem: formItem,
        dataObj:
            Provider.of<PluginState>(context, listen: false).formInputValues,
        encryptedField:
            Provider.of<PluginState>(context, listen: false).encryptedFields,
        isList: true,
        context: context,
      );

  @override
  Widget render() {
    return Builder(builder: (BuildContext context) {
      var formItem = BaseFormInheritedComponent.of(context)?.formItem;
      var moduleItem = BaseFormInheritedComponent.of(context)?.moduleItem;

      return formItem?.controlFormat == ControlFormat.LISTDATA.name
          ? FutureBuilder<DynamicResponse?>(
              future: getDynamicLabel(context, formItem, moduleItem!),
              builder: (BuildContext context,
                  AsyncSnapshot<DynamicResponse?> snapshot) {
                Widget child = Text(formItem?.controlText ?? "");
                if (snapshot.hasData) {
                  var dynamicResponse = snapshot.data;
                  DynamicPostCall.processDynamicResponse(
                      dynamicResponse!.dynamicData!,
                      context,
                      formItem?.controlId);

                  child = DynamicTextViewWidget(
                          jsonText: dynamicResponse.dynamicList)
                      .render();
                }
                return child;
              })
          : Text(
              formItem?.controlText ?? "",
              style: const TextStyle(fontSize: 16),
            );
    });
  }
}

class DynamicTextViewWidget implements IFormWidget {
  List<dynamic>? jsonText;
  List<LinkedHashMap> mapItems = [];

  DynamicTextViewWidget({
    this.jsonText,
  });

  @override
  Widget render() {
    jsonText?.forEach((item) {
      mapItems.add(item);
    });

    return mapItems.isNotEmpty
        ? Builder(builder: (BuildContext context) {
            return Column(children: [
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mapItems.length,
                itemBuilder: (context, index) {
                  var mapItem = mapItems[index];
                  mapItem.removeWhere((key, value) =>
                      key == null || value == null || value == "");

                  return Material(
                      elevation: 1,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 16.0, bottom: 16.0, left: 16, top: 4),
                        child: Column(
                          children: mapItem
                              .map((key, value) => MapEntry(
                                  key,
                                  Container(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "$key:",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                fontFamily: "Manrope"),
                                          ),
                                          Flexible(
                                              child: Text(
                                            value.toString(),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontFamily: "Manrope"),
                                          ))
                                        ],
                                      ))))
                              .values
                              .toList(),
                        ),
                      ));
                },
              ),
              const SizedBox(
                height: 24,
              ),
              Container(
                margin: EdgeInsets.zero,
                color: APIService.appSecondaryColor,
                width: MediaQuery.of(context).size.width,
                height: 1,
              ),
              const SizedBox(
                height: 18,
              )
            ]);
          })
        : const SizedBox();
  }
}

class DynamicQRScanner implements IFormWidget {
  @override
  Widget render() {
    return Builder(builder: (BuildContext context) {
      var formItem = BaseFormInheritedComponent.of(context)?.formItem;
      var moduleItem = BaseFormInheritedComponent.of(context)?.moduleItem;
      return Column(
        children: [
          const SizedBox(
            height: 24,
          ),
          InkWell(
            onTap: () {
              context.navigate(QRScanner(
                moduleItem: moduleItem!,
                formItem: formItem!,
                context: context,
              ));
            },
            child: Image.asset(
              "packages/craft_dynamic/assets/images/qr-code.png",
              width: 200,
              height: 200,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            "QR Code quick scan",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: 12,
          ),
          const Text("Tap on the above image to start scanning"),
          const SizedBox(
            height: 44,
          ),
          Consumer<PluginState>(
            builder: (context, state, child) =>
                state.scanvalidationloading ? LoadUtil() : const SizedBox(),
          )
        ],
      );
    });
  }
}

class DynamicPhonePickerFormWidget extends StatefulWidget
    implements IFormWidget {
  const DynamicPhonePickerFormWidget({super.key});

  @override
  State<DynamicPhonePickerFormWidget> createState() =>
      _DynamicPhonePickerFormWidgetState();

  @override
  Widget render() {
    return const DynamicPhonePickerFormWidget();
  }
}

class _DynamicPhonePickerFormWidgetState
    extends State<DynamicPhonePickerFormWidget> {
  String? code;

  var controller = TextEditingController();
  PhoneNumber inputNumber = PhoneNumber(isoCode: APIService.countryIsoCode);
  final FlutterNativeContactPicker _contactPicker =
      FlutterNativeContactPicker();

  @override
  Widget build(BuildContext context) {
    var formItem = BaseFormInheritedComponent.of(context)?.formItem;
    AppLogger.appLogD(
        tag: "phone input::leading digit", message: formItem?.leadingDigits);
    AppLogger.appLogD(
        tag: "phone input::max digits", message: formItem?.maxLength);

    return InternationalPhoneNumberInput(
      maxLength: formItem?.maxLength ?? 11,
      onInputChanged: (PhoneNumber number) {
        inputNumber = number;
      },
      selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.DIALOG,
          setSelectorButtonAsPrefixIcon: true,
          leadingPadding: 14),
      ignoreBlank: false,
      autoValidateMode: AutovalidateMode.disabled,
      initialValue: inputNumber,
      textFieldController: controller,
      inputDecoration: InputDecoration(
          labelText: formItem?.controlText,
          suffixIcon: IconButton(
              onPressed: pickPhoneContact,
              icon:
                  Icon(Icons.contacts, color: Theme.of(context).primaryColor))),
      validator: (value) {
        var input = value?.replaceAll(" ", "");
        var leadingDigits = formItem?.leadingDigits ?? [];
        if (input?.length != 9) {
          return "Invalid mobile";
        } else if (leadingDigits.isNotEmpty &&
            (!leadingDigits.contains(value?[0]))) {
          return "Mobile must start with $leadingDigits";
        } else if (input == "") {
          return "Enter your mobile";
        } else {
          Provider.of<PluginState>(context, listen: false).addFormInput({
            "${formItem?.serviceParamId}":
                inputNumber.phoneNumber?.replaceAll("+", "")
          });
        }

        return null;
      },
      countries: (formItem?.countries?.isNotEmpty ?? false)
          ? formItem?.countries
          : null,
    );
  }

  pickPhoneContact() async {
    try {
      final Contact? contact = await _contactPicker.selectPhoneNumber();
      if (contact != null) {
        setState(() {
          controller.text = formatPhone(contact.selectedPhoneNumber ?? "")
              .replaceAll(RegExp(r'^0'), '');
        });
      }
    } catch (e) {
      print("Failed to pick contact: $e");
    }
  }

  String formatPhone(String phone) {
    String noSpace = phone.replaceAll(' ', '');
    return noSpace.replaceAll(RegExp(r'\+\d{1,3}'), '');
  }
  // pickPhoneContact() async {
  //   final PhoneContact contact = await FlutterContactPicker.pickPhoneContact();
  //   setState(() {
  //     controller.text = formatPhone(contact.phoneNumber?.number ?? "")
  //         .replaceAll(RegExp(r'^0'), '');
  //   });
  // }

  // String formatPhone(String phone) {
  //   return phone.replaceAll(RegExp(r'\+\d{1,3}'), '');
  // }
}

class DynamicListWidget implements IFormWidget {
  final _dynamicRequest = DynamicFormRequest();
  DynamicResponse? dynamicResponse;
  FormItem? formItem, inheritedFormItem;
  ModuleItem? moduleItem, inheritedModuleItem;

  DynamicListWidget({this.moduleItem, this.formItem});

  getDynamicList(context, formItem, module) => _dynamicRequest.dynamicRequest(
        module,
        formItem: formItem,
        dataObj:
            Provider.of<PluginState>(context, listen: false).formInputValues,
        encryptedField:
            Provider.of<PluginState>(context, listen: false).encryptedFields,
        isList: true,
        context: context,
      );

  @override
  Widget render() {
    return Builder(builder: (BuildContext context) {
      inheritedFormItem = BaseFormInheritedComponent.of(context)?.formItem;
      inheritedModuleItem = BaseFormInheritedComponent.of(context)?.moduleItem;

      Provider.of<PluginState>(context, listen: false).addFormInput({
        RequestParam.HEADER.name:
            inheritedFormItem?.actionId ?? formItem?.actionId
      });

      return isEmptyList()
          ? const Center(
              child: Text("Nothing was found!"),
            )
          : FutureBuilder<DynamicResponse?>(
              future: getDynamicList(
                  context, formItem, inheritedModuleItem ?? moduleItem),
              builder: (BuildContext context,
                  AsyncSnapshot<DynamicResponse?> snapshot) {
                Widget child = Center(
                    child: SpinKitSpinningLines(
                  color: APIService.appPrimaryColor,
                  duration: Duration(milliseconds: 2000),
                  size: 40,
                ));
                if (snapshot.hasData) {
                  dynamicResponse = snapshot.data;

                  child = ListWidget(
                    dynamicList: dynamicResponse?.dynamicList,
                    summary: dynamicResponse?.summary,
                    scrollable: false,
                    controlID: formItem?.controlId,
                    moduleItem: moduleItem,
                    serviceParamID: formItem?.serviceParamId,
                  );
                }
                return child;
              });
    });
  }

  bool isEmptyList() {
    if (formItem?.controlFormat != null &&
            formItem!.controlFormat!.isNotEmpty ||
        formItem?.actionId == null ||
        formItem?.actionId == "") {
      return false;
    }
    return true;
  }
}

class DynamicHyperLink implements IFormWidget {
  @override
  Widget render() {
    return Builder(builder: (BuildContext context) {
      var formItem = BaseFormInheritedComponent.of(context)?.formItem;
      if (formItem?.controlValue != null) {
        CommonUtils.openUrl(Uri.parse(formItem!.controlValue!));
        Navigator.pop(context);
      }
      return const Visibility(visible: false, child: SizedBox());
    });
  }
}

class DynamicImageUpload extends StatefulWidget implements IFormWidget {
  const DynamicImageUpload({super.key});

  @override
  State<DynamicImageUpload> createState() => _DynamicImageUpload();

  @override
  Widget render() {
    return const DynamicImageUpload();
  }
}

class _DynamicImageUpload extends State<DynamicImageUpload> {
  String? imageFile;
  FormItem? formItem;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    formItem = BaseFormInheritedComponent.of(context)?.formItem;

    return FutureBuilder<List<CameraDescription>>(
        future: availableCameras(),
        // a previously-obtained Future<String> or null
        builder: (BuildContext context,
            AsyncSnapshot<List<CameraDescription>> snapshot) {
          Widget child = const SizedBox();
          if (snapshot.hasData) {
            child = InkWell(
                borderRadius: BorderRadius.circular(8.0),
                onTap: () async {
                  final XFile? photo =
                      await _picker.pickImage(source: ImageSource.camera);
                  setState(() {
                    imageFile = photo?.path;
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formItem!.controlText!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0)),
                      width: double.infinity,
                      height: 177,
                      child: imageFile == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 34,
                                    color: Colors.blueGrey,
                                  ),
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  Text("Tap to take picture")
                                ])
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                File(imageFile!),
                                fit: BoxFit.fitWidth,
                              )),
                    )
                  ],
                ));
          }
          return child;
        });
  }
}

class DynamicLinkedContainer extends StatefulWidget implements IFormWidget {
  const DynamicLinkedContainer({super.key});

  @override
  State<StatefulWidget> createState() => _DynamicLinkedContainerState();

  @override
  Widget render() {
    return const DynamicLinkedContainer();
  }
}

class _DynamicLinkedContainerState extends State<DynamicLinkedContainer> {
  String? controlFormat;
  List<String> buttons = [];
  List<Widget> widgets = [];
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var formItem = BaseFormInheritedComponent.of(context)?.formItem;
    var formItems = BaseFormInheritedComponent.of(context)?.formItems;

    if (formItem?.controlFormat == ControlFormat.HorizontalScroll.name) {
      for (var item in formItems!) {
        if (item.controlType == ViewType.SELECTEDTEXT.name) {
          buttons.add(item.controlText!);
        }
        if (item.controlType == ViewType.TEXT.name) {
          widgets.add(const SizedBox(
            height: 15,
          ));
          widgets.add(Consumer<GroupButtonModel>(
              builder: (context, selectedItem, child) {
            _controller.text = selectedItem.selectedItem;
            return WidgetFactory.buildTextField(
                context,
                TextFormFieldProperties(
                    controller: _controller,
                    textInputType: TextInputType.name,
                    inputDecoration:
                        InputDecoration(hintText: formItem?.controlText)),
                (string) {
              Provider.of<PluginState>(context, listen: false).addFormInput(
                  {"${formItem?.serviceParamId}": _controller.text});

              return null;
            });
          }));
          widgets.add(const SizedBox(
            height: 8,
          ));
        }
      }
    }
    if (buttons.isNotEmpty) {
      widgets.add(GroupButtonWidget(
        buttons: buttons,
      ));
    }
    widgets = widgets.reversed.toList();
    return ChangeNotifierProvider(
        create: (context) => GroupButtonModel(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets,
        ));
  }
}

class DynamicCheckBox extends StatefulWidget implements IFormWidget {
  const DynamicCheckBox({super.key});

  @override
  State<StatefulWidget> createState() => _DynamicCheckBoxState();

  @override
  Widget render() => const DynamicCheckBox();
}

class _DynamicCheckBoxState extends State<DynamicCheckBox> {
  FormItem? formItem;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    formItem = BaseFormInheritedComponent.of(context)?.formItem;
    return CheckboxFormField(
        title: Text(
          formItem?.controlText ?? "",
          style: TextStyle(fontSize: 12, fontFamily: "Manrope"),
        ),
        validator: (value) {
          validate(value);
          return null;
        });
  }

  validate(value) {
    Provider.of<PluginState>(context, listen: false)
        .addFormInput({"${formItem?.serviceParamId}": "$value"});
  }
}

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField(
      {super.key,
      required Widget title,
      required FormFieldValidator<bool> validator,
      bool initialValue = false,
      bool autovalidate = false})
      : super(
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<bool> state) {
              return CheckboxListTile(
                dense: true, // Reduces the vertical padding
                title: title,
                value: state.value,
                onChanged: state.didChange,
                controlAffinity:
                    ListTileControlAffinity.leading, // Checkbox precedes text
                activeColor:
                    APIService.appPrimaryColor, // Selected checkbox color
                checkColor: Colors.white, // Inside checkbox color when selected
                side: BorderSide(
                    color: APIService
                        .appPrimaryColor), // Unselected checkbox border color
                contentPadding: EdgeInsets
                    .zero, // Reduces default padding around the checkbox
              );
              //   CheckboxListTile(
              //   contentPadding: EdgeInsets.zero,
              //   tileColor: APIService.appPrimaryColor,
              //   dense: state.hasError,
              //   title: title,
              //   value: state.value,
              //   onChanged: state.didChange,
              //   controlAffinity: ListTileControlAffinity.leading,
              // );
            });
}

class DynamicHorizontalText extends StatefulWidget implements IFormWidget {
  const DynamicHorizontalText({super.key, required this.input});

  final Map<String?, dynamic> input;

  @override
  State<StatefulWidget> createState() => _DynamicHorizontalText();

  @override
  Widget render() => DynamicHorizontalText(
        input: input,
      );
}

class _DynamicHorizontalText extends State<DynamicHorizontalText> {
  String customerName = "";
  final _profile = ProfileRepository();

  @override
  void initState() {
    AppLogger.appLogD(tag: "$classname all input", message: " ${widget.input}");
    super.initState();
    setCustomerName();
  }

  setCustomerName() async {
    customerName = await getCustomerName() ?? "";
    setState(() {});
  }

  Future<String?> getCustomerName() async {
    return await _profile.getUserInfo(UserAccountData.FirstName) +
        " " +
        await _profile.getUserInfo(UserAccountData.LastName);
  }

  @override
  Widget build(BuildContext context) {
    var formItem = BaseFormInheritedComponent.of(context)?.formItem;
    var formInput = widget.input[formItem?.controlId];

    if (formItem?.controlId == ControlID.FROMNAME.name) {
      formInput = customerName;
    }

    AppLogger.appLogD(
        tag: "$classname@${formItem?.controlId}", message: "input $formInput");

    return formInput == null
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formItem?.controlText ?? ""),
                Text(
                  formInput ?? "****",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                )
              ],
            ));
  }
}

class TextLink extends StatefulWidget implements IFormWidget {
  const TextLink({super.key});

  @override
  State<TextLink> createState() => _TextLinkState();

  @override
  Widget render() => const TextLink();
}

class _TextLinkState extends State<TextLink> {
  final _api = APIService();

  @override
  Widget build(BuildContext context) {
    var moduleItem = BaseFormInheritedComponent.of(context)?.moduleItem;
    var formItem = BaseFormInheritedComponent.of(context)?.formItem;

    return FutureBuilder<DynamicResponse?>(
        future: _api.getDynamicLink(formItem?.actionId ?? "", moduleItem!),
        builder:
            (BuildContext context, AsyncSnapshot<DynamicResponse?> snapshot) {
          Widget child = TextButton(
              onPressed: () {
                CommonUtils.openUrl(Uri.parse(formItem?.controlValue ?? ""));
              },
              child: Text(formItem?.controlText ?? "Link"));
          if (snapshot.hasData) {
            return Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                    onPressed: () {
                      CommonUtils.openUrl(
                          Uri.parse(snapshot.data?.otherText ?? ""));
                    },
                    child: Text(formItem?.controlText ?? "Link")));
          }
          return child;
        });
  }
}

class NullWidget implements IFormWidget {
  @override
  Widget render() {
    return const Visibility(
      visible: false,
      child: SizedBox(),
    );
  }
}
