// ignore_for_file: must_be_immutable

import 'package:craft_dynamic/src/ui/dynamic_static/list_data.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:provider/provider.dart';

const primaryColor = Color(0xff2532A1);
const secondaryAccent = Color(0xffF6B700);
const primaryLight = Color(0xffD3EFFF);
const primaryLightVariant = Color(0xffFFF9D9);

class RegularFormWidget extends StatefulWidget {
  final ModuleItem moduleItem;
  final List<FormItem> sortedForms;
  final List<dynamic>? jsonDisplay, formFields;
  final bool hasRecentList;

  const RegularFormWidget(
      {super.key,
      required this.moduleItem,
      required this.sortedForms,
      required this.jsonDisplay,
      required this.formFields,
      this.hasRecentList = false});

  @override
  State<RegularFormWidget> createState() => _RegularFormWidgetState();
}

class _RegularFormWidgetState extends State<RegularFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  List<FormItem> formItems = [];
  FormItem? recentList;

  @override
  initState() {
    recentList = widget.sortedForms.toList().firstWhereOrNull(
        (formItem) => formItem.controlType == ViewType.LIST.name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    formItems = widget.sortedForms.toList()
      ..removeWhere((element) => element.controlType == ViewType.LIST.name);

    return WillPopScope(
        onWillPop: () async {
          if (Provider.of<PluginState>(context, listen: false)
              .loadingNetworkData) {
            CommonUtils.showToast("Please wait...");
            return false;
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<PluginState>(context, listen: false)
                .clearDynamicDropDown();
          });
          Provider.of<PluginState>(context, listen: false)
              .setRequestState(false);
          return true;
        },
        child: Scaffold(
            backgroundColor: primaryColor,
            body: SizedBox(
                height: double.infinity,
                child: Scrollbar(
                    thickness: 6,
                    controller: _scrollController,
                    child: SingleChildScrollView(
                        child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                            padding: EdgeInsets.only(
                                left: 20, right: 20, bottom: 6, top: 30),
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
                        ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(30),
                                topLeft: Radius.circular(30)),
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 16),
                                color: primaryLightVariant,
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                child: Form(
                                    key: _formKey,
                                    child: ListView.builder(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20, top: 8),
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: formItems.length,
                                        itemBuilder: (context, index) {
                                          return BaseFormComponent(
                                              formItem: formItems[index],
                                              moduleItem: widget.moduleItem,
                                              formItems: formItems,
                                              formKey: _formKey,
                                              child: IFormWidget(
                                                      formItems[index],
                                                      jsonText:
                                                          widget.jsonDisplay,
                                                      formFields:
                                                          widget.formFields)
                                                  .render());
                                        }))))
                      ],
                    ))))));
  }
}
