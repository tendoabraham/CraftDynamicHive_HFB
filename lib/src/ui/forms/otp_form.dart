import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:craft_dynamic/src/network/dynamic_request.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

const primaryColor = Color(0xff2532A1);

class OTPForm {
  static confirmOTPTransaction(context, ModuleItem moduleItem,
      FormItem? formItem, PreCallData? preCallData) {
    return showModalBottomSheet<void>(
      backgroundColor: Color(0xffFFF9D9),
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) => ModalBottomSheet(
        moduleItem: moduleItem,
        formItem: formItem,
        preCallData: preCallData,
      ),
    );
  }
}

class ModalBottomSheet extends StatefulWidget {
  ModalBottomSheet(
      {super.key, required this.moduleItem, this.formItem, this.preCallData});

  final ModuleItem moduleItem;
  FormItem? formItem;
  PreCallData? preCallData;

  @override
  State<StatefulWidget> createState() => _ModalBottomSheetState();
}

class _ModalBottomSheetState extends State<ModalBottomSheet> with CodeAutoFill {
  static final formKey = GlobalKey<FormState>();
  static final _dynamicRequest = DynamicFormRequest();
  static final otpController = TextEditingController();
  static bool isLoading = false;
  String? code;

  @override
  void initState() {
    super.initState();
    listenForCode();
    isLoading = false;
    otpController.clear();
  }

  @override
  void codeUpdated() {
    setState(() {
      code = code;
      otpController.text = code!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16),
        child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
            opacity: .1,
            image: AssetImage(
              'assets/launcher.png',
            ),
          )),
          // padding:
          //     const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
          child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(1);
                    },
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.close),
                      Text(
                        "Cancel",
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: "DMSans",
                            fontWeight: FontWeight.bold),
                      )
                    ]),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                const Text(
                  "Enter OTP sent via sms/email to proceed with transaction",
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: "DMSans",
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 24,
                ),
                Pinput(
                  length: 6,
                  obscureText: true,
                  autofocus: false,
                  defaultPinTheme: PinTheme(
                      height: 44,
                      width: 44,
                      padding: const EdgeInsets.all(4),
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: APIService.appPrimaryColor, width: 1.5))),
                  controller: otpController,
                  onCompleted: (pin) {
                    confirmTransactionVerification(
                        widget.moduleItem, widget.preCallData, context);
                  },
                  validator: (value) {
                    return null;
                  },
                ),
                const SizedBox(
                  height: 32,
                ),
                isLoading
                    ? SpinKitSpinningLines(
                        color: primaryColor,
                        duration: Duration(milliseconds: 2000),
                        size: 40,
                      )
                    : SizedBox(
                        width: 300,
                        child: WidgetFactory.buildButton(context, () {
                          confirmTransactionVerification(
                              widget.moduleItem, widget.preCallData, context);
                        }, "CONFIRM TRANSACTION",
                            color: APIService.appPrimaryColor)),
                const SizedBox(
                  height: 32,
                ),
              ])),
        ));
  }

  confirmTransactionVerification(ModuleItem moduleItem,
      PreCallData? preCallData, BuildContext context) async {
    if (formKey.currentState!.validate()) {
      if (otpController.text.isNotEmpty) {
        if (otpController.text.length == 6) {
          if (preCallData != null) {
            setState(() {
              isLoading = true;
            });
            var obj = preCallData.requestObject;
            obj?["EncryptedFields"]
                .addAll({"TrxOTP": CryptLib.encryptField(otpController.text)});
            lastWebHeaderUsed.value = preCallData.webheader ?? "purchase";
            // lastWebHeaderUsed.value = "purchase";

            await _dynamicRequest
                .dynamicRequest(widget.moduleItem,
                    formItem: widget.formItem,
                    dataObj: obj?["PayBill"],
                    encryptedField: obj?["EncryptedFields"],
                    context: context,
                    tappedButton: true,
                    action: ActionType.PAYBILL,
                    url: lastWebHeaderUsed.value)
                .then((value) {
              DynamicPostCall.processDynamicResponse(
                  value?.dynamicData, context, widget.formItem?.controlId,
                  moduleItem: widget.moduleItem);
              if (value?.status != StatusCode.failure.statusCode) {
                Navigator.of(context).pop();
              }
            });
            setState(() {
              otpController.clear();
              isLoading = false;
            });
          }
        } else {
          Vibration.vibrate();
          CommonUtils.showToast("Invalid OTP!");
        }
      } else {
        Vibration.vibrate();
        CommonUtils.showToast("Please enter OTP!");
      }
    }
  }
}
