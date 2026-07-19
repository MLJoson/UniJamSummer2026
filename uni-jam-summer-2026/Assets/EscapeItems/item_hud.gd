extends Node2D
var candle = false
var feather = false
var harness = false

func _on_ready() -> void:
	eventBUS.itemObt.connect(item_collected)
func item_collected(item):
	if item == "candle":
		$CandleHud.modulate = Color("#feff51")
		candle = true
		if candle and feather and harness:
			eventBUS.colorChange.emit(Color.WHITE)
			eventBUS.allItemsCollected.emit()
			$CandleHud.visible = false
			$FeatherHud.visible = false
			$HarnessHud.visible = false
			Transition.fade_in()
	if item == "feather":
		$FeatherHud.modulate = Color("#feff51")
		feather = true
		if candle and feather and harness:
			eventBUS.colorChange.emit(Color.WHITE)
			eventBUS.allItemsCollected.emit()
			$CandleHud.visible = false
			$FeatherHud.visible = false
			$HarnessHud.visible = false
			Transition.fade_in()
	if item == "harness":
		$HarnessHud.modulate = Color("#feff51")
		harness = true
		if candle and feather and harness:
			eventBUS.colorChange.emit(Color.WHITE)
			eventBUS.allItemsCollected.emit()
			$CandleHud.visible = false
			$FeatherHud.visible = false
			$HarnessHud.visible = false
			Transition.fade_in()
