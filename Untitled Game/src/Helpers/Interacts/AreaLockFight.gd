extends Node

class_name AreaLockFight

onready var baseLevelScript  = load("res://src/Levels/Base/BaseLevelScript.gd")

var areaLocked = false;
var currentSpawnersInLockOut: Array
var currentDelimiterForLockOut: CustomDelimiter2D
var _countOfSpawners: int
var _defeatedSpawners: int
var _player: Node2D

signal lockout_started
signal lockout_finished
signal area_lock

func _ready():
	_player = LevelGlobals.GetPlayerActor()
	var parentLevel = self.get_parent()
	while (not parentLevel is baseLevelScript) and (is_instance_valid(parentLevel)):
		parentLevel = parentLevel.get_parent();
	#make sure that parent node inherits from base level class so it can handle area lock code
	assert(is_instance_valid(parentLevel) and parentLevel.has_method("area_lock_handler"), "Parent of scene does not inherit from base level script.")
	self.connect("area_lock", parentLevel, "area_lock_handler")
	
	#make sure there is a customdelimiter2d child for the node for the lock fight
	var children = self.get_children()
	for child in children:
		if child is CustomDelimiter2D:
			if not is_instance_valid(currentDelimiterForLockOut):
				currentDelimiterForLockOut = child;
			else:
				assert(false, "More than one custom delimiter in area fight!")
	assert(is_instance_valid(currentDelimiterForLockOut), "No custom delimiter found in the area fight.")
	
	#Make sure there is at least one spawner for enemies
	for child in children:
		if child is EnemySpawner:
			_countOfSpawners = _countOfSpawners + 1;
			currentSpawnersInLockOut.append(child);
	assert(currentSpawnersInLockOut.size() > 0, "No enemy spawners in area lockout!")
	currentDelimiterForLockOut.IsAreaLockDelimeter = true

func Disable():
	$StartArea/CollisionShape2D.set_deferred("disabled", true);
	
func Enable():
	$StartArea/CollisionShape2D.set_deferred("disabled", false);

func LockOutFightStart():
	if !areaLocked:
		#print("lockout started")
		emit_signal("lockout_started")
		areaLocked = true;
		emit_signal("area_lock", true)
		currentDelimiterForLockOut.ManualTransition_Enter();
		NextEnemySpawner();
		
func NextEnemySpawner():
	if areaLocked:
		var spawner = currentSpawnersInLockOut.pop_front()
		if is_instance_valid(spawner):
			spawner.connect("AllEnemiesDefeated", self, "SpawnerDefeated")
			spawner.spawnEnemy();
			NextEnemySpawner();
			
func SpawnerDefeated():
	_defeatedSpawners = _defeatedSpawners + 1;
	if(_defeatedSpawners == _countOfSpawners):
		LockOutFightFinish();
		
func LockOutFightFinish():
	areaLocked = false;
	emit_signal("lockout_finished")
	emit_signal("area_lock", false)
	currentDelimiterForLockOut.ManualTransition_Exit();

func _on_StartArea_body_entered(body):
	if body == _player:
		$StartArea/CollisionShape2D.set_deferred("disabled", true);
		LockOutFightStart();
