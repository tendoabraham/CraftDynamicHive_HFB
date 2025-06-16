// ignore_for_file: must_be_immutable

import 'package:craft_dynamic/src/ui/dynamic_static/list_data.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:craft_dynamic/src/util/widget_util.dart';
import 'package:provider/provider.dart';

const primaryColor = Color(0xff2532A1);
const secondaryAccent = Color(0xffF6B700);
const primaryLight = Color(0xffD3EFFF);
const primaryLightVariant = Color(0xffFFF9D9);

class RadioWidget extends StatefulWidget {
  List<FormItem> formItems;
  String title;
  ModuleItem moduleItem;
  Function? updateState;
  final bool isSkyBlueTheme;

  RadioWidget(
      {super.key,
      required this.title,
      required this.formItems,
      required this.moduleItem,
      this.updateState,
      this.isSkyBlueTheme = false});

  @override
  State<RadioWidget> createState() => _RadioWidgetState();
}

class _RadioWidgetState extends State<RadioWidget> {
  FormItem? recentList;
  List<FormItem> radioFormControls = [];

  @override
  void initState() {
    radioFormControls = widget.formItems;
    try {
      recentList = radioFormControls.firstWhere(
        (item) => item.controlType == ViewType.LIST.name,
      );
    } catch (e) {
      AppLogger.appLogE(tag: "recent list error", message: e.toString());
    }
    radioFormControls
        .removeWhere((formItem) => formItem.controlType == ViewType.LIST.name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (Provider.of<PluginState>(context, listen: false)
              .loadingNetworkData) {
            CommonUtils.showToast("Please wait...");
            return false;
          }
          return true;
        },
        child: Scaffold(
            backgroundColor: primaryColor,
            body: SizedBox(
                height: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                        padding: Platform.isAndroid
                            ? EdgeInsets.only(
                                left: 14, right: 10, bottom: 4, top: 30)
                            : EdgeInsets.only(
                                left: 14, right: 10, bottom: 2, top: 45),
                        color: primaryColor,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Image.asset(
                                "assets/images/back2.png",
                                width: 30,
                                color: Colors.white,
                              ),
                              // child: Icon(
                              //   Icons.arrow_back_sharp,
                              //   size: 24,
                              //   color: Colors.white,
                              // )
                            ),
                            Spacer(),
                            Text(
                              "${widget.moduleItem?.moduleName}",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: "DMSans",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Spacer(),
                            Padding(
                                padding: const EdgeInsets.all(0),
                                child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      CommonUtils.navigateToRoute(
                                          context: context,
                                          widget: ListDataScreen(
                                              widget: DynamicListWidget(
                                                      moduleItem:
                                                          widget.moduleItem,
                                                      formItem: recentList)
                                                  .render(),
                                              title: widget
                                                  .moduleItem.moduleName));
                                    },
                                    icon: const Icon(
                                      Icons.view_list,
                                      color: Colors.white,
                                    ))),
                            // )
                          ],
                        )),
                    Expanded(
                        child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(30),
                                topLeft: Radius.circular(30)),
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                                color: widget.isSkyBlueTheme
                                    ? primaryLight
                                    : primaryLightVariant,
                                // height: MediaQuery.of(context).size.height,
                                // width: MediaQuery.of(context).size.width,
                                child: RadioWidgetList(
                                  formItems: radioFormControls,
                                  moduleItem: widget.moduleItem,
                                ))))
                  ],
                ))));
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class RadioWidgetList extends StatefulWidget {
  final List<FormItem> formItems;
  ModuleItem moduleItem;

  RadioWidgetList(
      {super.key, required this.formItems, required this.moduleItem});

  @override
  State<RadioWidgetList> createState() => _RadioWidgetListState();
}

class _RadioWidgetListState extends State<RadioWidgetList> {
  final _formKey = GlobalKey<FormState>();
  List<FormItem> sortedForms = [];
  List<Widget> chips = [];
  List<FormItem> chipChoices = [];
  List<FormItem> rButtonForms = [];
  int? _value = 0;

  @override
  void initState() {
    super.initState();
  }

  List<FormItem> getRButtons() => widget.formItems
      .where((formItem) => formItem.controlType == ViewType.RBUTTON.name)
      .toList();

  addChips(List<FormItem> formItems) {
    chips.clear();
    chipChoices.clear();
    formItems.asMap().forEach((index, formItem) {
      chipChoices.add(formItem);
      chips.add(Expanded(
          flex: 1,
          child: Container(
              margin: EdgeInsets.zero,
              child: ChoiceChip(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: index == 0 ? Radius.circular(12) : Radius.zero,
                    bottomLeft: index == 0 ? Radius.circular(12) : Radius.zero,
                    topRight: index == 1 ? Radius.circular(12) : Radius.zero,
                    bottomRight: index == 1 ? Radius.circular(12) : Radius.zero,
                  ),
                ),
                side: _value == index
                    ? null
                    : BorderSide(
                        color: Theme.of(context).primaryColor.withOpacity(.4)),
                labelStyle: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: _value == index
                      ? Colors.white
                      : APIService.appPrimaryColor,
                  fontSize: 13,
                  fontFamily: "DMSans",
                  fontWeight: FontWeight.bold,
                ),
                label: SizedBox(
                  width: double.infinity,
                  child: Text(
                    formItem.controlText ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: "DMSans",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                selected: _value == index,
                onSelected: (bool selected) {
                  if (_value != index) {
                    setState(() {
                      _value = selected ? index : null;
                    });
                  }
                },
              ))));
    });
  }

  getRButtonForms(FormItem formItem) {
    sortedForms.clear();
    rButtonForms.clear();
    rButtonForms = widget.formItems
        .where((element) =>
            element.linkedToControl == formItem.controlId ||
            element.linkedToControl == "" ||
            element.linkedToControl == null)
        .toList();

    rButtonForms
        .removeWhere((element) => element.controlType == ViewType.LIST.name);
    sortedForms = WidgetUtil.sortForms(rButtonForms);
  }

  @override
  Widget build(BuildContext context) {
    addChips(getRButtons());
    getRButtonForms(chipChoices[_value ?? 0]);

    return WillPopScope(
        onWillPop: () async {
          Provider.of<PluginState>(context, listen: false)
              .setRequestState(false);
          return true;
        },
        child: SizedBox(
            // height: double.infinity,
            // width: double.infinity,
            child: SingleChildScrollView(
                child: Column(
                    // mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                child: const Text(
                  "Choose receipient",
                  style: TextStyle(
                      fontSize: 13,
                      fontFamily: "Manrope",
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                  child: Align(
                      child: Row(
                    children: chips,
                  ))),
              const SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.zero,
                color: APIService.appSecondaryColor,
                width: MediaQuery.of(context).size.width,
                height: 1,
              ),
              const SizedBox(
                height: 16,
              ),
              Form(
                  key: _formKey,
                  child: ListView.builder(
                      shrinkWrap: true,
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 4),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedForms.length,
                      itemBuilder: (context, index) {
                        return BaseFormComponent(
                            formItem: sortedForms[index],
                            moduleItem: widget.moduleItem,
                            formKey: _formKey,
                            formItems: sortedForms,
                            child: IFormWidget(
                              sortedForms[index],
                            ).render());
                      }))
            ]))));
  }
}
