import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../widgets/dropdown_widget.dart';
import 'home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(final BuildContext context) {
    var examType = 'Índice Cardíaco';
    return ChangeNotifierProvider(
      create: (final _) {
        final myController = HomeController();
        unawaited(myController.onInit());
        return myController;
      },
      child: Consumer<HomeController>(
        builder: (final context, final controller, final _) {
          final cpf = controller.cpf;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Anlix Test'),
              backgroundColor: const Color(0xff0e537a),
              foregroundColor: Colors.white,
            ),
            backgroundColor: const Color(0xff9bcbe5),
            body: SafeArea(
              child: controller.isDataLoaded
                  ? Container(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Visibility(
                            visible: examType != 'Por Data',
                            child: DropdownWidget(
                              title: 'Paciente',
                              defaultValue: controller.dropdownPatients.first,
                              options: controller.dropdownPatients,
                              onChanged: controller.dropdownPatient,
                            ),
                          ),
                          Visibility(
                            visible: examType != 'Por Data',
                            child: const SizedBox(
                              height: 10,
                            ),
                          ),
                          DropdownWidget(
                            title: 'Tipo',
                            defaultValue: 'Índice Cardíaco',
                            options: const [
                              'Índice Cardíaco',
                              'Índice Pulmonar',
                              'Ambos',
                              'Por Data',
                            ],
                            onChanged: (final type) {
                              examType = type;
                              controller.dropdownExamType();
                            },
                          ),
                          Visibility(
                            visible: examType == 'Por Data',
                            child: const SizedBox(
                              height: 10,
                            ),
                          ),
                          Visibility(
                            visible: examType == 'Por Data',
                            child: SfDateRangePicker(
                              backgroundColor: Colors.blue,
                              onSelectionChanged: (final date) {
                                controller.convertDateStringToEpoch(
                                  date.value.toString(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xff0e537a),
                              ),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.white,
                              ),
                            ),
                            onPressed: () {
                              String type;
                              if (examType == 'Índice Cardíaco') {
                                type = 'ind_card';
                              } else if (examType == 'Índice Pulmonar') {
                                type = 'ind_pul';
                              } else if (examType == 'Ambos') {
                                type = 'ambos';
                              } else {
                                type = 'data';
                              }
                              controller.searchButton(context, type, cpf);
                            },
                            child: const Text('Consultar Resultados'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Visibility(
                            visible: controller.isCardiacResultLoaded,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Data do Exame: ',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Text(
                                        controller.dateConvertedHeart,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Índice Cardíaco: ',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Text(
                                        controller.heartIndex,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: examType == 'Ambos' &&
                                controller.isCardiacResultLoaded &&
                                controller.isPulmonaryResultLoaded,
                            child: const Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Divider(
                                  color: Color(0xff0e537a),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: controller.isPulmonaryResultLoaded,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Data do Exame: ',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Text(
                                        controller.dateConvertedPulm,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Índice Pulmonar: ',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Text(
                                        controller.pulmIndex,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: controller.isCombinedResultsLoaded,
                            child: Expanded(
                              child: ListView.builder(
                                itemCount: controller.combinedData.length,
                                itemBuilder: (final context, final index) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        controller.getCpfName(
                                          controller.combinedData[index]['cpf']
                                              .toString(),
                                        ),
                                      ),
                                      if (controller.combinedData[index]
                                              ['ind_card'] !=
                                          null)
                                        Text(
                                          'Ind. Card. ${controller.combinedData[index]['ind_card']}', // ignore: lines_longer_than_80_chars
                                        )
                                      else if (controller.combinedData[index]
                                              ['ind_pulm'] !=
                                          null)
                                        Text(
                                          'Ind. Pulm. ${controller.combinedData[index]['ind_pulm']}', // ignore: lines_longer_than_80_chars
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          );
        },
      ),
    );
  }
}
