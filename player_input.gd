class_name PlayerInput
extends Object


enum DeviceType {
	ANY,
	KEYBOARD,
	CONTROLLER,
}


static func create_map(player_index : int, device_type : DeviceType, device_index : int) -> Dictionary:
	var map := {}
	for action in InputMap.get_actions():
		if action.begins_with("ui_") or action.begins_with("p."):
			continue

		if player_index < 0:
			map[action] = action
		else:
			var new_action : StringName = StringName("p.%d.%s" % [player_index, action])
			map[action] = new_action
			InputMap.add_action(new_action, InputMap.action_get_deadzone(action))
			for event in InputMap.action_get_events(action):
				if not _event_matches_device_type(event, device_type):
					continue
				if device_index == event.device:
					InputMap.action_add_event(new_action, event)
				elif event.device < 0:
					var device_specific_event : InputEvent = event.duplicate()
					device_specific_event.device = device_index
					InputMap.action_add_event(new_action, device_specific_event)
	return map


static func remove_map(map : Dictionary) -> void:
	for action in map:
		var mapped_action : StringName = map[action]
		if mapped_action == action:
			continue
		InputMap.erase_action(mapped_action)
	map.clear()


static func _event_matches_device_type(event : InputEvent, type : DeviceType) -> bool:
	match type:
		DeviceType.ANY: return true
		DeviceType.KEYBOARD: return event is InputEventKey or event is InputEventMouseButton
		DeviceType.CONTROLLER: return event is InputEventJoypadButton or event is InputEventJoypadMotion
	return false
