extends Node2D
func _on_ready() -> void:
	eventBUS.itemObt.connect(item_collected)
	
func item_collected(item):
	if item == "candle":
		$CandleHud.modulate = Color("#feff51")
	if item == "feather":
		$FeatherHud.modulate = Color("#feff51")
	if item == "harness":
		$HarnessHud.modulate = Color("#feff51")
