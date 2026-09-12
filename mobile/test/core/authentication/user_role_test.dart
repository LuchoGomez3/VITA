import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/core/authentication/user_role.dart';

void main() {
  test('parses the current backend roles and administrator compatibility', () {
    expect(UserRolePermissions.fromBackend('admin'), UserRole.admin);
    expect(UserRolePermissions.fromBackend('administrator'), UserRole.admin);
    expect(UserRolePermissions.fromBackend('owner'), UserRole.owner);
    expect(UserRolePermissions.fromBackend('employee'), UserRole.employee);
    expect(UserRolePermissions.fromBackend('invalid'), UserRole.unknown);
    expect(UserRolePermissions.fromBackend(null), UserRole.unknown);
  });

  test('serializes every role with the stable backend value', () {
    expect(UserRole.admin.backendValue, 'admin');
    expect(UserRole.owner.backendValue, 'owner');
    expect(UserRole.employee.backendValue, 'employee');
    expect(UserRole.unknown.backendValue, 'unknown');
  });

  test('grants financial access only to admin and owner', () {
    expect(UserRole.admin.canViewFinancialInformation, isTrue);
    expect(UserRole.owner.canViewFinancialInformation, isTrue);
    expect(UserRole.employee.canViewFinancialInformation, isFalse);
    expect(UserRole.unknown.canViewFinancialInformation, isFalse);
  });
}
