import 'package:the_big_thing/entities/folder.dart';
import 'package:floor/floor.dart';

@dao
abstract class FolderDao {
  @Query('SELECT * FROM Folder')
  Future<List<Folder>> findAllFolders();

  @Query('SELECT * FROM Folder WHERE id = :id')
  Future<Folder> findFolderById(int id);

  @insert
  Future<void> insertFolder(Folder folder);
}
