import 'package:the_big_thing/entities/thing.dart';
import 'package:floor/floor.dart';

@dao
abstract class ThingDao {
  @Query('SELECT * FROM Thing')
  Future<List<Thing>> findAllThings();

  @Query('SELECT * FROM Thing WHERE id = :id')
  Future<Thing> findThingById(int id);

  @insert
  Future<void> insertThing(Thing person);
}
