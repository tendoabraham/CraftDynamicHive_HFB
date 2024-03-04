import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:craft_dynamic/src/ui/forms/confirmation_form.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../builder/factory_builder.dart';

class DynamicFormRequest {
  Map<String, dynamic> requestObj = {};
  Map<String?, dynamic> formvalues = {};
  Map<String?, dynamic> encryptedvalues = {};
  final _actionControlRepository = ActionControlRepository();
  final _formsRepository = FormsRepository();
  final _services = APIService();
  final _sharedPref = CommonSharedPref();
  String? confirmationModuleID;
  PreCallData? preCallData;

  Future<DynamicResponse?> dynamicRequest(ModuleItem? moduleItem,
      {FormItem? formItem,
      dataObj,
      encryptedField,
      isList = false,
      context,
      listType = ListType.TransactionList,
      tappedButton = false,
      ActionType action = ActionType.DBCALL,
      url}) async {
    AppLogger.appLogD(
        tag: "DYNAMIC REQUEST", message: "Starting a dynamic request...");
    DynamicResponse? dynamicResponse =
        DynamicResponse(status: StatusCode.unknown.statusCode);
    try {
      formvalues.addAll(dataObj);
      encryptedvalues.addAll(encryptedField);
    } catch (e) {
      AppLogger.appLogE(tag: "error adding values", message: e);
    }

    ActionItem? actionControl;
    var merchantID = moduleItem?.merchantID ?? "BANKIMAGE";
    bool isDBCall = moduleItem?.isDBCall ?? false;

    if (dataObj == null) {
      Fluttertoast.showToast(
          msg: "Unable to process data", backgroundColor: Colors.red);
      return dynamicResponse;
    }

    ActionType actionType = action;
    if (listType == ListType.ViewOrderList ||
        listType == ListType.BeneficiaryList) {
      requestObj["EncryptedFields"] = {};
      requestObj["MerchantID"] = merchantID;
    }

    requestObj["ModuleID"] = moduleItem?.moduleId;
    requestObj["SessionID"] = Constants.getUniqueID();

    if (formItem != null) {
      actionControl =
          await _actionControlRepository.getActionControlByModuleIdAndControlId(
              moduleItem?.moduleId ?? "", formItem.controlId);
      AppLogger.appLogD(
          tag:
              "action control merchant id--> formitem control id ---> ${formItem.controlId}",
          message: actionControl?.merchantID);
    }

    if (actionControl?.displayFormID == ControlFormat.LISTDATA.name ||
        isDBCall) {
      isList = true;
    }

    if (actionControl != null) {
      var actionMerchantID = actionControl.merchantID;
      if (actionMerchantID != null && actionMerchantID != "") {
        merchantID = actionMerchantID;
      }
    }

    if (actionControl != null) {
      try {
        actionType = ActionType.values.byName(actionControl.actionType);
      } catch (e) {
        AppLogger.appLogD(tag: "GET ACTION TYPE ERROR", message: e);
      }
    }

    if (actionType == ActionType.VALIDATE) {
      setDeleteForm(context, false);
    } else {
      setDeleteForm(context, true);
    }

    if (formItem?.controlFormat == ControlFormat.SHOWDIALOG.name) {
      var form = await _formsRepository
          .getFormsByModuleId(actionControl?.confirmationModuleID ?? "");
      var title = form?.first.controlValue ?? "";
      var result = await AlertUtil.showAlertDialog(
          context, form?.first.controlText ?? "",
          isInfoAlert: true,
          isConfirm: true,
          title: title.isNotEmpty ? title : "Confirm",
          cancelButtonText: "Cancel",
          confirmButtonText: "Proceed");
      if (!result) {
        Provider.of<PluginState>(context, listen: false).setRequestState(false);
        return dynamicResponse;
      }
    }

    confirmationModuleID = actionControl?.confirmationModuleID;
    if (confirmationModuleID != null &&
        confirmationModuleID != "" &&
        formItem?.controlFormat != ControlFormat.SHOWDIALOG.name) {
      List<FormItem> form = await _formsRepository
              .getFormsByModuleId(confirmationModuleID ?? "") ??
          [];
      var result = await ConfirmationForm.confirmTransaction(
          context, form, moduleItem!, formvalues);
      if (result != null) {
        if (result == 1) {
          Provider.of<PluginState>(context, listen: false)
              .setRequestState(false);
          return dynamicResponse;
        }
      } else {
        try {
          Provider.of<PluginState>(context, listen: false)
              .setRequestState(false);
        } catch (e) {
          AppLogger.appLogE(tag: "error", message: e.toString());
        }

        return dynamicResponse;
      }
    }

    requestObj = DynamicFactory.getDynamicRequestObject(actionType,
        merchantID: merchantID,
        actionID: formItem?.actionId ?? "",
        requestMap: requestObj,
        dataObject: formvalues,
        isList: isList,
        listType: listType,
        encryptedFields:
            encryptedvalues); // Get a request map from this interface

    lastWebHeaderUsed.value = actionControl?.webHeader ?? "other";

    dynamicResponse = await _services.dynamicRequest(
        requestObj: requestObj,
        webHeader: url ?? actionControl?.webHeader,
        formID: actionType.name);

    preCallData = PreCallData(
        formID: actionType.name,
        webheader: url ?? actionControl?.webHeader,
        requestObject: requestObj);

    if (dynamicResponse.status == StatusCode.unknown.name) {
      Provider.of<PluginState>(context, listen: false).setRequestState(false);
    }

    var dynamicData = DynamicData(
        actionType: actionType,
        dynamicResponse: dynamicResponse,
        moduleItem: moduleItem,
        controlID: formItem?.controlId ?? "",
        isList: isList,
        listType: listType,
        tappedButton: tappedButton,
        preCallData: preCallData);

    dynamicResponse.dynamicData = dynamicData;

    if (moduleItem?.moduleId == StatusCode.unknown.name &&
        dynamicResponse.status == StatusCode.success.statusCode) {
      _sharedPref.setBio(false);
    }

    try {
      Provider.of<PluginState>(context, listen: false).setRequestState(false);
    } catch (e) {
      AppLogger.appLogD(tag: "loader error", message: e);
    }

    return dynamicResponse;
  }

  void setDeleteForm(context, bool status) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Provider.of<PluginState>(context, listen: false).setDeleteForm(status);
      } catch (e) {
        AppLogger.appLogE(
            tag: "dynamic request", message: "delete form error!");
      }
    });
  }
}
