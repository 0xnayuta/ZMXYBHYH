extends SceneTree

const OUTPUT_PATH: = "res://.codex_tmp/skill_damage_formula_ui.png"
const ENTRY_OUTPUT_PATH: = "res://.codex_tmp/skill_damage_formula_entry.png"


func _init() -> void :
	call_deferred("_run")


func _run() -> void :
	DisplayServer.window_set_size(Vector2i(940, 590))
	var scene: = load("res://Scene/Skill/Learn_skill.tscn") as PackedScene
	if scene == null:
		_fail("cannot load Learn_skill scene")
		return
	if not await _verify_skill_row_layout(scene):
		return
	var page: = scene.instantiate()
	root.add_child(page)
	await process_frame
	await process_frame

	var button: = page.get_node_or_null("bg/lh_pic/front_bg/damage_description") as Button
	if button == null or not button.visible:
		_fail("damage description button missing")
		return
	if button.text != "技能伤害公式":
		_fail("damage formula button text mismatch")
		return
	if not await _save_screenshot(ENTRY_OUTPUT_PATH):
		return
	page.call("_on_damage_description_pressed")
	await process_frame
	await process_frame

	var overlay: = page.get_node_or_null("bg/lh_pic/front_bg/SkillFormulaOverlay")
	var scroll: = _find_control_by_name(overlay, "FormulaScroll") as ScrollContainer
	var list: = page.get("_formula_list") as VBoxContainer
	var active_skills: Array = page.zd_sk.Skill_list.get(page.zd_sk.get_role_key(), [])
	if overlay == null or scroll == null or list == null:
		_fail("formula overlay hierarchy missing")
		return
	if list.get_child_count() != active_skills.size():
		_fail("formula cards do not match current role")
		return
	for card in list.get_children():
		var icon: = _find_control_by_name(card, "SkillIcon") as TextureRect
		if icon == null or icon.texture == null:
			_fail("formula skill icon missing")
			return
	if scroll.get_v_scroll_bar().max_value <= scroll.size.y:
		_fail("formula list is not vertically scrollable")
		return

	if not await _save_screenshot(OUTPUT_PATH):
		return
	print("SKILL_DAMAGE_FORMULA_UI_PROBE_OK role=%s cards=%d screenshot=%s" % [page.zd_sk.get_role_key(), list.get_child_count(), OUTPUT_PATH])
	quit(0)

func _verify_skill_row_layout(scene: PackedScene) -> bool:
	var player_data = root.get_node("PlayerData")
	var original_role: int = int(player_data.player_data["Myself"])
	for role_id in range(1, 7):
		player_data.player_data["Myself"] = role_id
		var page: = scene.instantiate()
		root.add_child(page)
		await process_frame
		await process_frame
		var active = page.zd_sk
		var heights: Array = active.get_skill_row_heights()
		var skills: Array = active.Skill_list[active.get_role_key()]
		if heights.size() != skills.size():
			_fail("skill layout row count mismatch role=%d" % role_id)
			return false
		var row_top: = 40.0
		for index in range(skills.size()):
			var row_bottom: = row_top + float(heights[index])
			var description: = active.get_node("ScrollContainer/HBoxContainer/sk_ms/s_%d" % (index + 1)) as Label
			if description.size.y + 0.1 < description.get_minimum_size().y\
			or description.offset_top < row_top + 7.9\
			or description.offset_bottom > row_bottom - 7.9:
				_fail("skill description overflows row role=%d skill=%s" % [role_id, skills[index]])
				return false
			for node_path in ["Sk_na/skill_", "sk_pi/ski_", "sk_lv/Skill_", "sk_le/sk_"]:
				var control: = active.get_node("ScrollContainer/HBoxContainer/" + node_path + str(index + 1)) as Control
				if control.offset_top < row_top or control.offset_bottom > row_bottom:
					_fail("skill control overflows row role=%d skill=%s" % [role_id, skills[index]])
					return false
			var icon: = active.get_node("ScrollContainer/HBoxContainer/sk_pi/ski_%d" % (index + 1)) as Control
			var awaken: = icon.get_node("AwakenButton") as Control
			if icon.offset_top + awaken.position.y + awaken.size.y > row_bottom:
				_fail("awaken button overflows row role=%d skill=%s" % [role_id, skills[index]])
				return false
			row_top = row_bottom
		var scroll: = active.get_node("ScrollContainer") as ScrollContainer
		if scroll.get_v_scroll_bar().max_value < row_top:
			_fail("skill scroll range does not include last row role=%d" % role_id)
			return false
		if role_id == 3:
			if not await _save_screenshot("res://.codex_tmp/skill_layout_bajie.png"):
				return false
			scroll.scroll_vertical = int(row_top)
			await process_frame
			await process_frame
			if not await _save_screenshot("res://.codex_tmp/skill_layout_bajie_bottom.png"):
				return false
		page.queue_free()
		await process_frame
	player_data.player_data["Myself"] = original_role
	print("SKILL_ROW_LAYOUT_PROBE_OK roles=6")
	return true


func _save_screenshot(path: String) -> bool:
	RenderingServer.force_draw()
	await process_frame
	var viewport_texture: = root.get_texture()
	if viewport_texture == null:
		_fail("viewport texture unavailable")
		return false
	var image: = viewport_texture.get_image()
	if image == null:
		_fail("viewport image unavailable")
		return false
	var save_error: = image.save_png(path)
	if save_error != OK:
		_fail("cannot save screenshot: " + error_string(save_error))
		return false
	return true


func _find_control_by_name(node: Node, target_name: String) -> Control:
	if node == null:
		return null
	if node.name == target_name and node is Control:
		return node as Control
	for child in node.get_children():
		var found: = _find_control_by_name(child, target_name)
		if found != null:
			return found
	return null


func _fail(reason: String) -> void :
	push_error("SKILL_DAMAGE_FORMULA_UI_PROBE_FAIL: " + reason)
	quit(1)
