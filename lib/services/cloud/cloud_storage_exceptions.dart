class CloudStorageException implements Exception {
  const CloudStorageException();
}

/// Create in crud
class CouldNotCreateNoteException extends CloudStorageException {}

/// Retrieve in crud
class CouldNotGetAllNoteException extends CloudStorageException {}

/// Update in Creud
class CouldNotUpdateNoteException extends CloudStorageException {}

///Delete in crud
class CouldNotDeleteNoteException extends CloudStorageException {}