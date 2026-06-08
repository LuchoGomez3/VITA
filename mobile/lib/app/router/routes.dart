class AppRoutes {
  static const home = '/';
  static const animalRegister = '/registrar-animal';
  static const animalDetail = '/animals/:animalId';

  const AppRoutes._();

  static String animalDetailById(String animalId) {
    return '/animals/$animalId';
  }
}
