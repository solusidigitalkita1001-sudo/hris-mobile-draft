import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_app/features/self_service/data/datasources/request_local_datasource.dart';
import 'package:hrm_app/features/self_service/data/repositories/request_repository_impl.dart';
import 'package:hrm_app/features/self_service/domain/entities/request_command.dart';

void main() {
  test('submitted request becomes the newest pending request', () async {
    final repository = RequestRepositoryImpl(DemoRequestLocalDataSource());

    await repository.submit(const SubmitRequestCommand(type: 'Annual Leave'));

    expect(repository.current.first.type, 'Annual Leave');
    expect(repository.current.first.status.name, 'pending');
    expect(repository.current, hasLength(6));
  });
}
