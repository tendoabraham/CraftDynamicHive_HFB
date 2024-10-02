// ignore_for_file: must_be_immutable
part of craft_dynamic;

class DynamicWidget extends StatelessWidget {
  List<dynamic>? jsonDisplay, formFields;
  int? nextFormSequence;
  bool isWizard;
  ModuleItem? moduleItem;
  FrequentAccessedModule? favouriteModule;
  String? formID;
  final bool isSkyBlueTheme;

  DynamicWidget(
      {super.key,
      this.moduleItem,
      this.favouriteModule,
      this.jsonDisplay,
      this.formFields,
      this.nextFormSequence,
      this.formID,
      this.isWizard = false,
      this.isSkyBlueTheme = false});

  List<FormItem> content = [];

  @override
  Widget build(BuildContext context) {
    moduleItem = checkModuleType(
        moduleItem: moduleItem, favouriteModule: favouriteModule);

    final orientation = MediaQuery.of(context).orientation;
    // _formItems = DynamicData.readFormsJson(moduleId);
    // _moduleItems = DynamicData.readModulesJson(moduleId);

    return moduleItem?.moduleCategory == MenuCategory.FORM.name
        ? FormsListWidget(
            jsonDisplay: jsonDisplay,
            formFields: formFields,
            nextFormSequence: nextFormSequence,
            isWizard: isWizard,
            moduleItem: moduleItem!,
            isSkyBlueTheme: isSkyBlueTheme,
          )
        : ModulesListWidget(
            orientation: orientation,
            isSkyBlueTheme: isSkyBlueTheme,
            moduleItem: moduleItem,
          );
  }

  ModuleItem? checkModuleType(
      {ModuleItem? moduleItem, FrequentAccessedModule? favouriteModule}) {
    ModuleItem? item = moduleItem;
    if (favouriteModule != null) {
      item = ModuleItem(
          parentModule: favouriteModule.parentModule,
          moduleUrl: favouriteModule.moduleUrl,
          moduleId: favouriteModule.moduleID,
          moduleName: favouriteModule.moduleName,
          moduleCategory: favouriteModule.moduleCategory,
          merchantID: favouriteModule.merchantID);
    }
    return item;
  }
}
