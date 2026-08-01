import 'package:dio/dio.dart';
import 'package:player/services/new_api/dto/show_dto.dart';
import 'package:player/services/new_api/dto/show_response.dto.dart';

class NewScheduleApi {
  NewScheduleApi({required this.baseUrl, Dio? dio}) {
    this.dio = dio ?? Dio();
  }
  late Dio dio;
  final String baseUrl;

  Future<ShowResponseDto> getCurrentProgram() async {
    final response = await dio.get<Map<String, dynamic>>(
      '$baseUrl/current-show',
    );
    final showResponse = ShowResponseDto.fromJson(response.data!);
    return showResponse;
  }

  Future<List<ShowDto>> getAllPrograms({bool includeAcf = true}) async {
    final response = await dio.get<List<dynamic>>(
      '$baseUrl/programs',
      queryParameters: {'include_acf': true},
    );

    return response.data?.map((entry) => ShowDto.fromJson(entry)).toList() ??
        [];
  }
}
