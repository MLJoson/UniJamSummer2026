extends AudioStreamPlayer

@onready var sync_stream: AudioStreamSynchronized = stream
@export var minotaur: CharacterBody3D
@export var transitionTime: float = 1
var currentIndex: int = 0
const ZERO_VOLUME: float = -80

func _ready() -> void:
	play()
	for i in range(sync_stream.stream_count):
		sync_stream.set_sync_stream_volume(i, ZERO_VOLUME)
	
	sync_stream.set_sync_stream_volume(currentIndex, 0)


func set_current_track(newSongIndex: int):
	var tween: Tween = create_tween().set_parallel(true)
	
	# Fade out old track, fade in new track
	tween.tween_method(
		func(v: float) -> void: sync_stream.set_sync_stream_volume(newSongIndex, linear_to_db(v)),
		db_to_linear(sync_stream.get_sync_stream_volume(newSongIndex)), 1, transitionTime
	)
	if newSongIndex != currentIndex:
		tween.tween_method(
			func(v: float) -> void: sync_stream.set_sync_stream_volume(currentIndex, linear_to_db(v)),
			db_to_linear(sync_stream.get_sync_stream_volume(currentIndex)), 0.0, transitionTime
		)
	await tween.finished
	currentIndex = newSongIndex
	print(currentIndex)
