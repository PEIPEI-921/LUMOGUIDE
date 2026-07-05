import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';

class PublishCityController extends GetxController with ApiMixin {
  static const String _draftKey = 'publish_city_draft';

  int id = 0;
  bool _submitSuccess = false;

  final _cityInfo = GuidePublishCity().obs;
  GuidePublishCity get cityInfo => _cityInfo.value;

  final pictures = <String>[].obs;

  final continents = <Category>[].obs;
  final subContinents = <Category>[].obs;
  final countries = <Category>[].obs;

  // Text controllers
  final nameController = TextEditingController();
  final nameEnController = TextEditingController();
  final currencyController = TextEditingController();
  final languageController = TextEditingController();
  final populationController = TextEditingController();
  final raceController = TextEditingController();
  final overviewController = TextEditingController();
  final historyController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      id = Get.arguments['id'] as int? ?? 0;
    }
    _fetchCityInfo();
    _fetchContinents();
  }

  @override
  void onReady() {
    super.onReady();
    if (id == 0) _checkDraftAndPrompt();
  }

  @override
  void onClose() {
    if (id == 0 && !_submitSuccess) _saveDraft();
    nameController.dispose();
    nameEnController.dispose();
    currencyController.dispose();
    languageController.dispose();
    populationController.dispose();
    raceController.dispose();
    overviewController.dispose();
    historyController.dispose();
    super.onClose();
  }

  onSelectContinent() async {
    if (continents.isEmpty) {
      Loading.toast('暫無數據'.tr);
      return;
    }
    final res = await ValuePicker.show(
      title: '請選擇所在大洲'.tr,
      datas: continents.map((e) => e.name ?? '').toList(),
      selectedDatas: [cityInfo.continentsName ?? ''],
    );
    if (res.isEmpty) {
      return;
    }
    final continent = continents.firstWhere((e) => e.name == res!.first);
    _cityInfo.update((val) {
      val?.continentsId = continent.id;
      val?.continentsName = continent.name;
    });
    _fetchContinents(continent.id ?? 0);
  }

  onSelectSubContinent() async {
    if (cityInfo.continentsId == null) {
      Loading.toast('請選擇所在大洲'.tr);
      return;
    }
    if (subContinents.isEmpty) {
      Loading.toast('暫無數據'.tr);
      return;
    }
    final res = await ValuePicker.show(
      title: '請選擇城市所屬地區'.tr,
      datas: subContinents.map((e) => e.name ?? '').toList(),
      selectedDatas: [cityInfo.areaName ?? ''],
    );
    if (res.isEmpty) {
      return;
    }
    final subContinent = subContinents.firstWhere((e) => e.name == res!.first);
    _cityInfo.update((val) {
      val?.areaId = subContinent.id;
      val?.areaName = subContinent.name;
    });
    _fetchCountries(subContinent.id ?? 0);
  }

  onSelectCountry() async {
    if (cityInfo.areaId == null) {
      Loading.toast('請選擇城市所屬地區'.tr);
      return;
    }
    if (countries.isEmpty) {
      Loading.toast('暫無數據'.tr);
      return;
    }
    final res = await ValuePicker.show(
      title: '請選擇城市所屬國家'.tr,
      datas: countries.map((e) => e.name ?? '').toList(),
      selectedDatas: [cityInfo.countryName ?? ''],
    );
    if (res.isEmpty) {
      return;
    }
    final country = countries.firstWhere((e) => e.name == res!.first);
    _cityInfo.update((val) {
      val?.countryId = country.id;
      val?.countryName = country.name;
    });
  }

  onToggleCapital(bool isCapital) {
    _cityInfo.update((val) {
      val?.isCapital = isCapital ? 1 : 0;
    });
  }

  Future<void> selectImage({int? index}) async {
    final path = await ImagePickerUtil.selectImage(Get.context!);
    if (path.isEmpty) {
      return;
    }
    if (index != null && index < pictures.length) {
      pictures[index] = path;
    } else {
      pictures.add(path);
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < pictures.length) pictures.removeAt(index);
  }

  onSubmit() async {

    Loading.show();
    final url = id == 0 ? ApiUrl.guidePublishCity : ApiUrl.guideEditCity;
    final res = await post(url, data: cityInfo.toJson());
    Loading.dismiss();
    if (!res.isSuccess) {
      AlertUtils.error(res.message);
      return;
    }
    await AlertUtils.customAlert(
      assets: Assets.iconReview,
      imageSize: Size(50.w, 50.w),
      title: '發布成功，請等待管理員審核~'.tr,
      confirmText: '關閉'.tr,
    );
    await _clearDraft();
    _submitSuccess = true;
    Get.back(result: true);
  }

  /// 若有任意可保存内容则写入草稿（仅新建 id==0 时在 onClose 调用）
  Future<void> _saveDraft() async {
    if (id != 0) return;
    final map = _buildDraftMap();
    if (!_draftHasContent(map)) return;
    await StorageService.to.setString(_draftKey, jsonEncode(map));
  }

  bool _draftHasContent(Map<String, dynamic> map) {
    final name = map['name'] as String?;
    if (name != null && name.trim().isNotEmpty) return true;
    final nameEn = map['name_en'] as String?;
    if (nameEn != null && nameEn.trim().isNotEmpty) return true;
    final pics = map['pictures'] as List<dynamic>?;
    if (pics != null && pics.isNotEmpty) return true;
    return false;
  }

  Map<String, dynamic> _buildDraftMap() {
    _cityInfo.update((val) {
      val?.name = nameController.text;
      val?.nameEn = nameEnController.text;
      val?.currency = currencyController.text;
      val?.language = languageController.text;
      val?.population = populationController.text;
      val?.race = raceController.text;
      val?.overview = overviewController.text;
      val?.history = historyController.text;
    });
    return {
      'name': cityInfo.name,
      'name_en': cityInfo.nameEn,
      'continents_id': cityInfo.continentsId,
      'continents_name': cityInfo.continentsName,
      'area_id': cityInfo.areaId,
      'area_name': cityInfo.areaName,
      'country_id': cityInfo.countryId,
      'country_name': cityInfo.countryName,
      'is_capital': cityInfo.isCapital,
      'currency': cityInfo.currency,
      'language': cityInfo.language,
      'population': cityInfo.population,
      'race': cityInfo.race,
      'overview': cityInfo.overview,
      'history': cityInfo.history,
      'pictures': pictures.toList(),
    };
  }

  Future<void> _clearDraft() async {
    await StorageService.to.remove(_draftKey);
  }

  Map<String, dynamic>? _getDraftMap() {
    final s = StorageService.to.getString(_draftKey);
    if (s.isEmpty) return null;
    try {
      return jsonDecode(s) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  /// 进入页且为新建时：若有草稿则弹窗询问是否使用
  Future<void> _checkDraftAndPrompt() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final draft = _getDraftMap();
    if (draft == null) return;
    final use = await AlertUtils.show(
      title: '提示'.tr,
      content: '檢測到上次未提交的填寫數據，是否使用？'.tr,
      cancelText: '不使用'.tr,
      confirmText: '使用'.tr,
    );
    if (use == true) {
      _fillFromDraft(draft);
      final cid = draft['continents_id'] as int?;
      final aid = draft['area_id'] as int?;
      if (cid != null && cid > 0) await _fetchContinents(cid);
      if (aid != null && aid > 0) await _fetchCountries(aid);
    } else {
      await _clearDraft();
    }
  }

  void _fillFromDraft(Map<String, dynamic> draft) {
    nameController.text = draft['name'] as String? ?? '';
    nameEnController.text = draft['name_en'] as String? ?? '';
    currencyController.text = draft['currency'] as String? ?? '';
    languageController.text = draft['language'] as String? ?? '';
    populationController.text = draft['population'] as String? ?? '';
    raceController.text = draft['race'] as String? ?? '';
    overviewController.text = draft['overview'] as String? ?? '';
    historyController.text = draft['history'] as String? ?? '';
    _cityInfo.update((val) {
      val?.continentsId = draft['continents_id'] as int?;
      val?.continentsName = draft['continents_name'] as String?;
      val?.areaId = draft['area_id'] as int?;
      val?.areaName = draft['area_name'] as String?;
      val?.countryId = draft['country_id'] as int?;
      val?.countryName = draft['country_name'] as String?;
      val?.isCapital = draft['is_capital'] as int? ?? 0;
    });
    final pics = draft['pictures'];
    if (pics is List<dynamic>) {
      pictures.value = pics.map((e) => e.toString()).toList();
    }
  }
}

extension on PublishCityController {
  _fetchContinents([int id = 0]) async {
    final res = await get(
      ApiUrl.getContinentsList,
      parameters: {'parent_id': id},
    );
    if (!res.isSuccess) return;
    final data = res.dataList;
    final continents = data.map((e) => Category.fromJson(e)).toList();
    if (id == 0) {
      this.continents.value = continents;
      subContinents.value = [];
    } else {
      subContinents.value = continents;
    }
  }

  _fetchCountries([int id = 0]) async {
    final res = await get(
      ApiUrl.getContinentsList,
      parameters: {'parent_id': id},
    );
    if (!res.isSuccess) return;
    final data = res.dataList;
    final countries = data.map((e) => Category.fromJson(e)).toList();
    this.countries.value = countries;
  }

  _fetchCityInfo() async {
    if (id == 0) return;
    Loading.show();
    final res = await get(ApiUrl.guideCityInfo, parameters: {'id': id});
    Loading.dismiss();
    if (!res.isSuccess) return;
    _cityInfo.value = GuidePublishCity.fromJson(res.dataJson);
    _fillData();
  }

  _fillData() {
    if (id == 0) return;
    nameController.text = cityInfo.name ?? '';
    nameEnController.text = cityInfo.nameEn ?? '';
    currencyController.text = cityInfo.currency ?? '';
    languageController.text = cityInfo.language ?? '';
    populationController.text = cityInfo.population ?? '';
    raceController.text = cityInfo.race ?? '';
    overviewController.text = cityInfo.overview ?? '';
    historyController.text = cityInfo.history ?? '';
    pictures.value = cityInfo.pictures;
  }
}
