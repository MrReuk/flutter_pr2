class RepositoryException implements Exception {
  final String message;

  const RepositoryException(this.message);

  @override
  String toString() => message;
}

class DeleteBlockedException extends RepositoryException {
  const DeleteBlockedException(super.message);
}

class FieldConflictException extends RepositoryException {
  final Map<String, String> errors;

  const FieldConflictException(this.errors)
      : super('Значения полей конфликтуют с существующими записями');
}
