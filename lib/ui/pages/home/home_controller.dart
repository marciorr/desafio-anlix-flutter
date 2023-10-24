import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../database/results_database.dart';
import '../../../model/result.dart';

class HomeController extends ChangeNotifier {
  HomeController();

  bool isDataLoaded = false;
  bool isCardiacResultLoaded = false;
  bool isPulmonaryResultLoaded = false;
  bool isCombinedResultsLoaded = false;
  List<String> dropdownPatients = [];
  List<Map<String, dynamic>> combinedData = [];
  List<Map<String, dynamic>> patientsList = [];
  String _cpf = '';
  String get cpf => _cpf;
  String dateConvertedHeart = '';
  String dateConvertedPulm = '';
  String heartIndex = '';
  String pulmIndex = '';
  int? startEpoch;
  int? endEpoch;
  final ResultsDatabase _db = ResultsDatabase();
  double loadingProgress = 0;

  Future<void> onInit() async {
    await getPatientsData();
    await listHeartIndexFiles();
    await listPulmonaryIndexFiles();
  }

  Future<void> getPatientsData() async {
    final url = Uri.parse(
      'https://raw.githubusercontent.com/marciorr/desafio-anlix/main/dados/pacientes.json',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      patientsList = (json.decode(response.body) as List<dynamic>)
          .cast<Map<String, dynamic>>();
      for (final patient in patientsList) {
        final patientName = patient['nome'].toString();
        final patientCpf = patient['cpf'].toString();
        dropdownPatients.add('$patientName\n$patientCpf');
      }
      dropdownPatients.sort();
      final cpfPatient = dropdownPatients.first.split('\n');
      _cpf = cpfPatient[1];
    } else {
      log('Failed to fetch data: ${response.statusCode}');
    }
  }

  // Function that allows you to retrieve a name using the CPF
  String getCpfName(final String targetCpf) {
    for (final patient in patientsList) {
      if (patient['cpf'] == targetCpf) {
        return patient['nome'].toString();
      }
    }
    return 'Nome not found';
  }

  Future<void> listHeartIndexFiles() async {
    const owner = 'marciorr';
    const repo = 'desafio-anlix';
    const path = 'dados/indice_cardiaco';
    const apiBaseUrl = 'https://api.github.com/repos';

    final response =
        await http.get(Uri.parse('$apiBaseUrl/$owner/$repo/contents/$path'));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body) as List<dynamic>;
      final dataQty = responseData.length;
      final progressIncrease = 1.0 / dataQty;

      for (final dynamic data in responseData) {
        if (data is Map<String, dynamic>) {
          final fileName = data['name'].toString();

          final response = await http.get(
            Uri.parse(
              'https://raw.githubusercontent.com/$owner/$repo/main/dados/indice_cardiaco/$fileName',
            ),
          );
          await parseHeartFileContent(response.body);
        }
        loadingProgress += progressIncrease / 2;
        notifyListeners();
      }
    } else {
      log('Failed to list files: ${response.statusCode}');
    }
  }

  Future<void> listPulmonaryIndexFiles() async {
    const owner = 'marciorr';
    const repo = 'desafio-anlix';
    const path = 'dados/indice_pulmonar';
    const apiBaseUrl = 'https://api.github.com/repos';
    final response =
        await http.get(Uri.parse('$apiBaseUrl/$owner/$repo/contents/$path'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body) as List<dynamic>;
      final dataQty = responseData.length;
      final progressIncrease = 1.0 / dataQty;

      for (final dynamic data in responseData) {
        if (data is Map<String, dynamic>) {
          final fileName = data['name'].toString();

          final response = await http.get(
            Uri.parse(
              'https://raw.githubusercontent.com/$owner/$repo/main/dados/indice_pulmonar/$fileName',
            ),
          );
          await parsePulmFileContent(response.body);
        }
        loadingProgress += progressIncrease / 2;
        notifyListeners();
      }
      isDataLoaded = true;
      notifyListeners();
    } else {
      log('Failed to list files: ${response.statusCode}');
    }
  }

  // Function to convert an epoch timestamp to a human-readable date
  String convertEpochToDateString(final String epoch) {
    final epochInt = int.tryParse(epoch) ?? 0;
    final date = DateTime.fromMillisecondsSinceEpoch(epochInt * 1000);
    final formattedDate =
        '${date.day}/${date.month}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return formattedDate;
  }

  // Function to convert a date to an epoch timestamp
  void convertDateStringToEpoch(final String dateString) {
    final year = int.parse(dateString.substring(0, 4));
    final month = int.parse(dateString.substring(5, 7));
    final day = int.parse(dateString.substring(8, 10));
    final date = DateTime(year, month, day);
    // Start of the day (00:00:00)
    final startOfDay = DateTime(date.year, date.month, date.day);
    // End of the day (23:59:59)
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    // Convert to epoch time (in seconds)
    startEpoch = startOfDay.millisecondsSinceEpoch ~/ 1000;
    endEpoch = endOfDay.millisecondsSinceEpoch ~/ 1000;
    isCombinedResultsLoaded = false;
    notifyListeners();
  }

  Future<void> parseHeartFileContent(
    final String content,
  ) async {
    final lines = content.split('\n');
    final data = <Map<String, dynamic>>[];

    for (final line in lines) {
      final parts = line.split(' ');

      if (parts.length == 3) {
        final cpf = parts[0];
        final epoch = int.parse(parts[1]);
        final indCard = double.parse(parts[2]);

        final rowData = {
          'cpf': cpf,
          'epoch': epoch,
          'ind_card': indCard,
        };

        data.add(rowData);
        await _saveResult(
          cpf,
          epoch.toString(),
          'ind_card',
          indCard.toString(),
        );
      }
    }
  }

  Future<void> parsePulmFileContent(
    final String content,
  ) async {
    final lines = content.split('\n');
    final data = <Map<String, dynamic>>[];

    for (final line in lines) {
      final parts = line.split(' ');

      if (parts.length == 3) {
        final cpf = parts[0];
        final epoch = int.parse(parts[1]);
        final indCard = double.parse(parts[2]);

        final rowData = {
          'cpf': cpf,
          'epoch': epoch,
          'ind_pulm': indCard,
        };

        data.add(rowData);
        await _saveResult(
          cpf,
          epoch.toString(),
          'ind_pulm',
          indCard.toString(),
        );
      }
    }
  }

  Future<void> searchButton(
    final BuildContext context,
    final String type,
    final String cpf,
  ) async {
    if (type == 'ind_card') {
      await latestHeartIndex(cpf);
    } else if (type == 'ind_pul') {
      await latestPulmonaryIndex(cpf);
    } else if (type == 'ambos') {
      await latestHeartIndex(cpf);
      await latestPulmonaryIndex(cpf);
    } else if (type == 'data') {
      if (startEpoch == null && endEpoch == null) {
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        startEpoch = startOfDay.millisecondsSinceEpoch ~/ 1000;
        endEpoch = endOfDay.millisecondsSinceEpoch ~/ 1000;
      }
      await combinedResultsByDate(context, startEpoch ?? 0, endEpoch ?? 0);
    }
  }

  // Function to find the latest Heart Index based on the CPF
  Future<void> latestHeartIndex(final String targetCpf) async {
    final latestResult = await _db.getLatestIndCard(targetCpf);
    if (latestResult != null) {
      dateConvertedHeart =
          convertEpochToDateString(latestResult['epoch'].toString());
      heartIndex = latestResult['result_data'].toString();
      isCardiacResultLoaded = true;
      notifyListeners();
    } else {
      log('No data found for $targetCpf');
    }
  }

  // Function to find the latest Pulmonary Index based on the CPF
  Future<void> latestPulmonaryIndex(final String targetCpf) async {
    final latestResult = await _db.getLatestPulmCard(targetCpf);
    if (latestResult != null) {
      dateConvertedPulm =
          convertEpochToDateString(latestResult['epoch'].toString());
      pulmIndex = latestResult['result_data'].toString();
      isPulmonaryResultLoaded = true;
      notifyListeners();
    } else {
      log('No data found for $targetCpf');
    }
  }

  // Creates a list with both heart and pulmonary indexes ordered by epoch
  Future<void> combinedResultsByDate(
    final BuildContext context,
    final int startDate,
    final int endDate,
  ) async {
    combinedData.clear();
    combinedData = (await _db.getCombinedResultsByDate(startDate, endDate))!;
    if (combinedData.isEmpty) {
      if (context.mounted) {
        _showSnackBar(context, 'Nenhum resultado nesta data!');
      }
    }
    isCombinedResultsLoaded = true;
    notifyListeners();
  }

  void dropdownPatient(final String patient) {
    final nameCpf = patient.split('\n');
    _cpf = nameCpf[1];
    isCardiacResultLoaded = false;
    isPulmonaryResultLoaded = false;
    isCombinedResultsLoaded = false;
    notifyListeners();
  }

  void dropdownExamType() {
    isCardiacResultLoaded = false;
    isPulmonaryResultLoaded = false;
    isCombinedResultsLoaded = false;
    notifyListeners();
  }

  // SnackBar for Alerts
  void _showSnackBar(final BuildContext context, final String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Save Favorite
  Future<void> _saveResult(
    final String cpf,
    final String epoch,
    final String resultType,
    final String resultData,
  ) async {
    final existingResult = await _db.getResult(cpf, epoch, resultType);

    if (existingResult == null) {
      final result = Result(
        cpf,
        epoch,
        resultType,
        resultData,
      );
      await _db.saveResult(result);
    }
  }
}
