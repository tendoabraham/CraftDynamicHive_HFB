// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:provider/provider.dart';

const primaryColor = Color(0xff2532A1);
const secondaryAccent = Color(0xffF6B700);
const primaryLight = Color(0xffD3EFFF);
const primaryLightVariant = Color(0xffFFF9D9);

class ModulesListWidget extends StatefulWidget {
  Orientation orientation;
  ModuleItem? moduleItem;
  FrequentAccessedModule? favouriteModule;
  final bool isSkyBlueTheme;

  ModulesListWidget(
      {super.key,
      required this.orientation,
      required this.moduleItem,
      this.favouriteModule,
      this.isSkyBlueTheme = false});

  @override
  State<ModulesListWidget> createState() => _ModulesListWidgetState();
}

class _ModulesListWidgetState extends State<ModulesListWidget> {
  final _moduleRepository = ModuleRepository();

  Future<List<ModuleItem>?> getModules() async {
    List<ModuleItem>? modules = await _moduleRepository.getModulesById(
        widget.favouriteModule == null
            ? widget.moduleItem!.moduleId
            : widget.favouriteModule!.moduleID);

    return modules;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DynamicState>(builder: (context, state, child) {
      BlockSpacing? blockSpacing = widget.moduleItem?.blockSpacing;

      return WillPopScope(
          onWillPop: () async {
            Provider.of<PluginState>(context, listen: false)
                .setRequestState(false);
            return true;
          },
          child: Scaffold(
              backgroundColor: primaryColor,
              body: FutureBuilder<List<ModuleItem>?>(
                  future: getModules(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<ModuleItem>?> snapshot) {
                    Widget child = const Center(child: Text("Please wait..."));
                    if (snapshot.hasData) {
                      var modules = snapshot.data?.toList();
                      modules?.removeWhere((module) => module.isHidden == true);

                      if (modules != null) {
                        child = SingleChildScrollView(
                          child: SizedBox(
                            child: Column(
                              children: [
                                Container(
                                    padding: EdgeInsets.only(
                                        left: 24,
                                        right: 24,
                                        bottom: 16,
                                        top: 40),
                                    color: primaryColor,
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                          widget.favouriteModule == null
                                              ? widget.moduleItem?.moduleName ??
                                                  ""
                                              : widget
                                                  .favouriteModule!.moduleName,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: "DMSans",
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: Image.asset(
                                              "assets/images/notification.png",
                                              fit: BoxFit.cover,
                                              width: 18,
                                            ),
                                          ),
                                        ),
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
                                        color: widget.isSkyBlueTheme
                                            ? primaryLight
                                            : primaryLightVariant,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: GridView.builder(
                                            // physics: const NeverScrollableScrollPhysics(),
                                            padding: const EdgeInsets.only(
                                                left: 14,
                                                right: 14,
                                                top: 8,
                                                bottom: 8),
                                            shrinkWrap: true,
                                            itemCount: modules.length,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4,
                                              crossAxisSpacing: 1,
                                              mainAxisSpacing: 20,
                                              mainAxisExtent: 100,
                                            ),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              var module = modules[index];
                                              return ModuleItemWidget(
                                                  moduleItem: module);
                                            })))
                              ],
                            ),
                          ),
                        );
                      }
                    }
                    return child;
                  })));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
