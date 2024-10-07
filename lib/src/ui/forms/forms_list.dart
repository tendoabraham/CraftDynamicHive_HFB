// ignore_for_file: must_be_immutable

import 'package:craft_dynamic/src/ui/forms/stepper_form.dart';
import 'package:flutter/material.dart';

import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:craft_dynamic/src/ui/forms/regular_form.dart';
import 'package:craft_dynamic/src/ui/forms/tab_form.dart';
import 'package:craft_dynamic/src/util/widget_util.dart';
import 'package:provider/provider.dart';

import 'radio_form.dart';

class FormsListWidget extends StatelessWidget {
  ModuleItem moduleItem;
  bool isWizard;
  bool? deleteInput;
  int? nextFormSequence;
  List<dynamic>? jsonDisplay, formFields;
  final bool isSkyBlueTheme;

  FormsListWidget(
      {Key? key,
      required this.moduleItem,
      this.jsonDisplay,
      this.formFields,
      this.nextFormSequence,
      this.isWizard = false,
      this.deleteInput,
      this.isSkyBlueTheme = false})
      : super(key: key);

  int? currentForm;
  final myKey = UniqueKey();
  final _formsRepository = FormsRepository();

  getFormItems() => _formsRepository.getFormsByModuleId(moduleItem.moduleId);

  @override
  Widget build(BuildContext context) {
    if (Provider.of<PluginState>(context, listen: false).deleteFormInput) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<PluginState>(context, listen: false).clearDynamicInput();
        Provider.of<DropDownState>(context, listen: false).clearSelections();
        Provider.of<PluginState>(context, listen: false)
            .screenDropDowns
            .clear();
      });
    }

    return FutureBuilder<List<FormItem>?>(
        future: getFormItems(),
        builder:
            (BuildContext context, AsyncSnapshot<List<FormItem>?> snapshot) {
          Widget child = const SizedBox();
          if (snapshot.hasData) {
            int? currentFormSequence = nextFormSequence;
            if (currentFormSequence != null) {
              if (currentFormSequence == 0) {
                currentForm = 2;
              } else {
                currentForm = currentFormSequence;
              }
            } else {
              if (isWizard) {
                currentForm = 2;
              } else {
                currentForm = 1;
              }
            }
            List<FormItem> filteredFormItems = snapshot.data!
                .where(
                    (formItem) => formItem.formSequence == (currentForm ?? 1))
                .toList()
              ..removeWhere((formItem) => formItem.hidden == true)
              ..sort(((a, b) {
                return a.displayOrder!.compareTo(b.displayOrder!);
              }));
            List<FormItem> sortedForms =
                WidgetUtil.sortForms(filteredFormItems);
            bool hasRecentList = filteredFormItems
                .map((item) => item.controlType)
                .contains(ViewType.LIST.name);

            bool isRadioWidget = filteredFormItems
                .map((item) => item.controlType)
                .contains(ViewType.RBUTTON.name);

            bool isTabWidget = filteredFormItems
                .map((item) => item.controlType)
                .contains(ViewType.TAB.name);

            bool isStepperWigdet = filteredFormItems
                .map((item) => item.controlType)
                .contains(ViewType.STEPPER.name);

            if (isTabWidget) {
              child = TabWidget(
                title: "test",
                formItems: filteredFormItems,
                isSkyBlueTheme: isSkyBlueTheme,
                moduleItem: moduleItem,
              );
            } else if (isRadioWidget) {
              child = RadioWidget(
                title: "test",
                formItems: filteredFormItems,
                isSkyBlueTheme: isSkyBlueTheme,
                moduleItem: moduleItem,
              );
            } else if (isStepperWigdet) {
              child = StepperFormWidget(
                moduleItem: moduleItem,
                formItems: filteredFormItems,
              );
            } else {
              child = RegularFormWidget(
                moduleItem: moduleItem,
                sortedForms: sortedForms,
                jsonDisplay: jsonDisplay,
                isSkyBlueTheme: isSkyBlueTheme,
                formFields: formFields,
                hasRecentList: hasRecentList,
              );
            }
          }

          return child;
        });
  }
}
