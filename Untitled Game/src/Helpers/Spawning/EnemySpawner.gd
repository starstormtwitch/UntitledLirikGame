extends spawner

#Names must match enum exactly
const enemyDict = {
	"SlimeFR" : preload("res://src/Actors/SlimeFR.tscn"),
	"RatSoldier" : preload("res://src/Actors/RatSoldier.tscn"),
	"RatKing" : preload("res://src/Actors/RatKing/RatKing.tscn"),
	"ChimeraBeast" : preload("res://src/Actors/ChimeraBeast/ChimeraBeast.tscn"),
	"Shitman" : preload("res://src/Actors/shitman/Shitman.tscn"),
	"Granny" : preload("res://src/Actors/Granny.tscn"),
	"Chat" : preload("res://src/Actors/chat/chat.tscn")
}  
export(String, "SlimeFR", "RatSoldier", "RatKing", "ChimeraBeast", "Shitman", "Granny", "Chat") var enemy = "SlimeFR"

export(int) var level = 1
export(bool) var automatic = true
signal AllEnemiesDefeated

var EnemiesLeft = 1;

class_name EnemySpawner

func _ready():
	EnemiesLeft = count;
	if(automatic):
		spawnEnemy();

func spawnEnemy():
	assert(enemy != null, "Must set enemy in spawner node")
	var enemyToSpawn = enemyDict[enemy]
	var enemiesSpawned = spawnMultipleInArea(enemyToSpawn)
	return enemiesSpawned
	

func _despawned():
	._despawned()
	EnemiesLeft = EnemiesLeft - 1;
	if(EnemiesLeft < 1):
		emit_signal("AllEnemiesDefeated")
	
	
