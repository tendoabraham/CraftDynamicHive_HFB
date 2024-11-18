// ignore_for_file: must_be_immutable

import 'package:craft_dynamic/src/ui/dynamic_static/list_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:craft_dynamic/src/util/widget_util.dart';

const primaryColor = Color(0xff2532A1);
const secondaryAccent = Color(0xffF6B700);
const primaryLight = Color(0xffD3EFFF);
const primaryLightVariant = Color(0xffFFF9D9);

class TabWidget extends StatefulWidget {
  List<FormItem> formItems;
  String title;
  ModuleItem moduleItem;
  Function? updateState;
  final bool isSkyBlueTheme;

  TabWidget(
      {super.key,
      required this.title,
      required this.formItems,
      required this.moduleItem,
      this.updateState,
      this.isSkyBlueTheme = false});

  @override
  State<TabWidget> createState() => _TabWidgetState();
}

class _TabWidgetState extends State<TabWidget> {
  FormItem? recentList;
  List<FormItem> horizontalScroll = [];
  List<Tab> tabs = [];
  List<FormItem> tabForms = [];
  List<TabWidgetList> tabWidgetList = [];
  List<String> linkControls = [];

  @override
  void initState() {
    super.initState();
    tabWidgetList.clear();
    logForms();
    addTabWidgetList();
  }

  List<FormItem> getContainers(List<FormItem> forms) {
    List<FormItem> containers = forms
        .where((element) => element.controlType == ViewType.CONTAINER.name)
        .toList();
    return containers;
  }

  List<FormItem> getContainerForms(List<FormItem> forms, FormItem container) {
    return forms
        .where((element) =>
            element.containerID == container.controlId ||
            element.linkedToControl == container.controlId)
        .toList();
  }

  List<FormItem> getRButtonForms(List<FormItem> forms, FormItem rButton) {
    return forms
        .where((element) => element.linkedToControl == rButton.controlId)
        .toList();
  }

  logForms() {
    List<FormItem> containers = getContainers(widget.formItems);
    for (int i = 0; i < containers.length; i++) {
      List<FormItem> temp = getContainerForms(widget.formItems, containers[i]);
      for (var element in temp) {
        if (element.controlType == ViewType.RBUTTON.name ||
            element.controlType == ViewType.TAB.name) {
          linkControls.add(element.controlId!);
          tabs.add(Tab(
            text: element.controlText!.capitalize(),
          ));
        }
      }
      if (containers[i].controlType == ViewType.CONTAINER.name &&
          containers[i].controlFormat == ControlFormat.HorizontalScroll.name) {
        horizontalScroll.addAll(widget.formItems.where((item) =>
            item.containerID == containers[i].controlId ||
            item.linkedToControl == containers[i].controlId));
      }
    }
  }

  bool checkGlobalControlType(
      List<String> linkControls, String linkControl, FormItem formItem) {
    bool isGlobal = true;
    for (var element in linkControls) {
      if (element == formItem.linkedToControl) {
        isGlobal = false;
      }
    }
    return isGlobal;
  }

  List<FormItem> getTabForms(List<FormItem> formItems, String linkControl) {
    List<FormItem> items = formItems
        .where((element) =>
            element.linkedToControl == linkControl ||
            element.linkedToControl == "" ||
            element.linkedToControl == null)
        .toList();

    try {
      recentList = items.firstWhere(
        (item) => item.controlType == ViewType.LIST.name,
      );
    } catch (e) {
      AppLogger.appLogE(tag: "tab forms error", message: e.toString());
    }
    items.removeWhere((element) => element.controlType == ViewType.LIST.name);
    return items;
  }

  addTabWidgetList() {
    tabForms.clear();
    linkControls.asMap().forEach((index, linkControl) {
      tabForms = getTabForms(widget.formItems, linkControl).toList();
      tabWidgetList.add(TabWidgetList(
        moduleItem: widget.moduleItem,
        formItems: tabForms,
        updateState: widget.updateState,
        horizontalScroll: horizontalScroll,
      ));
    });
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
        child: DefaultTabController(
            length: tabs.length,
            child: Builder(builder: (BuildContext context) {
              final TabController tabController =
                  DefaultTabController.of(context);
              tabController.addListener(() {
                if (!tabController.indexIsChanging) {
                  Provider.of<PluginState>(context, listen: false)
                      .setRequestState(false,
                          currentTab: linkControls[tabController.index]);
                }
              });
              return Scaffold(
                backgroundColor: primaryColor,
                // appBar: AppBar(
                //   elevation: 2,
                //   actions: recentList != null
                //       ? [
                //           IconButton(
                //               onPressed: () {
                //                 CommonUtils.navigateToRoute(
                //                     context: context,
                //                     widget: ListDataScreen(
                //                         widget: DynamicListWidget(
                //                                 moduleItem: widget.moduleItem,
                //                                 formItem: recentList)
                //                             .render(),
                //                         title: widget.moduleItem.moduleName));
                //               },
                //               icon: const Icon(
                //                 Icons.view_list,
                //               ))
                //         ]
                //       : null,
                //   bottom: TabBar(
                //     tabs: tabs,
                //     isScrollable: true,
                //   ),
                //   title: Text(widget.moduleItem.moduleName),
                // ),
                body: Column(
                  children: [
                    Container(
                        padding: Platform.isAndroid
                            ? EdgeInsets.only(
                                left: 18, right: 10, bottom: 4, top: 36)
                            : EdgeInsets.only(
                                left: 18, right: 10, bottom: 2, top: 50),
                        color: primaryColor,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            InkWell(
                                onTap: () {
                                  // Scaffold.of(context).openDrawer();
                                  Navigator.of(context).pop();
                                },
                                child: Icon(
                                  Icons.arrow_back_sharp,
                                  size: 24,
                                  color: Colors.white,
                                )),
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
                    Container(
                        width: double.infinity,
                        color:
                            primaryColor, // Add a background color for debugging
                        child: Center(
                          child: TabBar(
                            tabs: tabs,
                            dividerColor: primaryColor,
                            isScrollable: true,
                          ),
                        )),
                    Expanded(
                        child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(30),
                                topLeft: Radius.circular(30)),
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 16),
                                color: widget.isSkyBlueTheme
                                    ? primaryLight
                                    : primaryLightVariant,
                                width: MediaQuery.of(context).size.width,
                                child: TabBarView(children: tabWidgetList))))
                  ],
                ),
              );
            })));
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class TabWidgetList extends StatefulWidget {
  final List<FormItem> formItems;
  List<FormItem>? horizontalScroll;
  Function? updateState;
  ModuleItem moduleItem;

  TabWidgetList(
      {super.key,
      required this.formItems,
      required this.moduleItem,
      this.updateState,
      this.horizontalScroll});

  @override
  State<TabWidgetList> createState() => _TabWidgetListState();
}

class _TabWidgetListState extends State<TabWidgetList> {
  final _formKey = GlobalKey<FormState>();
  List<FormItem> sortedForms = [];

  @override
  void initState() {
    super.initState();
    sortedForms = WidgetUtil.sortForms(widget.formItems);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.max, children: [
          const SizedBox(
            height: 12,
          ),
          Form(
              key: _formKey,
              child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(left: 18, right: 18, top: 8),
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
        ])));
  }

  bool get wantKeepAlive => true;
}
