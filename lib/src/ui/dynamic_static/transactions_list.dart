// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable

import 'dart:io';
import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:craft_dynamic/src/network/dynamic_request.dart';
import 'package:flutter/material.dart';

class TransactionList extends StatefulWidget {
  TransactionList({Key? key, required this.moduleItem}) : super(key: key);
  ModuleItem moduleItem;

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  List<Transaction> transactionList = [];
  final _dynamicRequest = DynamicFormRequest();

  @override
  void initState() {
    super.initState();
    DynamicInput.formInputValues.clear();
    DynamicInput.formInputValues.addAll({"HEADER": "GETTRXLIST"});
  }

  getTransactionList() => _dynamicRequest.dynamicRequest(widget.moduleItem,
      dataObj: DynamicInput.formInputValues,
      encryptedField: DynamicInput.encryptedField,
      context: context,
      listType: ListType.TransactionList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: Platform.isAndroid ? 40 : 50,
          leading: IconButton(
            onPressed: (() {
              Navigator.of(context).pop();
            }),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: Text(widget.moduleItem.moduleName),
        ),
        body: FutureBuilder<DynamicResponse?>(
            future: getTransactionList(),
            builder: (BuildContext context,
                AsyncSnapshot<DynamicResponse?> snapshot) {
              Widget widget = Center(child: LoadUtil());

              if (snapshot.hasData) {
                var list = snapshot.data?.dynamicList;
                if (list != null && list.isNotEmpty) {
                  addTransactions(list: list);
                  widget = ListView.separated(
                    itemCount: transactionList.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      return TransactionItem(
                          transaction: transactionList[index]);
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(
                      height: 8,
                    ),
                  );
                } else {
                  widget = const EmptyUtil();
                }
              }
              return widget;
            }));
  }

  @override
  void dispose() {
    super.dispose();
  }

  addTransactions({required list}) {
    list.forEach((item) {
      transactionList.add(Transaction.fromJson(item));
    });
  }
}

class TransactionItem extends StatelessWidget {
  Transaction transaction;

  TransactionItem({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Material(
            elevation: 1,
            borderRadius: BorderRadius.circular(8.0),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IntrinsicHeight(
                    child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              transaction.serviceName,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: APIService.appPrimaryColor),
                            ),
                            Text(
                              transaction.status,
                              style: TextStyle(
                                color: transaction.status == "FAIL"
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Date"),
                                  Text(
                                    transaction.date,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ]),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Amount"),
                                  Text(transaction.amount,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))
                                ])
                          ],
                        ),
                        const SizedBox(
                          height: 18,
                        )
                      ],
                    )),
                  ],
                )))));
  }
}

class Transaction {
  String bankAccountID;
  String status;
  String serviceName;
  String date;
  String amount;

  Transaction(
      {required this.bankAccountID,
      required this.status,
      required this.serviceName,
      required this.date,
      required this.amount});

  Transaction.fromJson(Map<String, dynamic> json)
      : bankAccountID = json["BankAccountID"],
        status = json["Status"],
        serviceName = json["ServiceName"],
        date = json["Date"],
        amount = json["Amount"];
}
