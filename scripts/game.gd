extends Control

const LINES: Array = [
	[0, 1, 2], [3, 4, 5], [6, 7, 8],
	[0, 3, 6], [1, 4, 7], [2, 5, 8],
	[0, 4, 8], [2, 4, 6],
]

const COLOR_BG := Color("1b2430")
const COLOR_PANEL := Color("243044")
const COLOR_CELL := Color("31445c")
const COLOR_CELL_HOVER := Color("3d5674")
const COLOR_CELL_PRESSED := Color("28384c")
const COLOR_WIN := Color("2f6b4f")
const COLOR_TEXT := Color("f4f7fb")
const COLOR_MUTED := Color("b7c3d4")
const COLOR_X := Color("7ec8ff")
const COLOR_O := Color("ffb46b")
const COLOR_RESTART := Color("3c5168")
const COLOR_RESTART_HOVER := Color("4a6480")

var board: Array[String] = []
var cells: Array[Button] = []
var current := "X"
var game_over := false
var winning_line: Array = []

@onready var background: ColorRect = $Background
@onready var board_panel: PanelContainer = $Center/Board
@onready var title_label: Label = $Center/Board/Margin/VBox/Title
@onready var status_label: Label = $Center/Board/Margin/VBox/Status
@onready var grid: GridContainer = $Center/Board/Margin/VBox/Grid
@onready var restart_button: Button = $Center/Board/Margin/VBox/Restart


func _ready() -> void:
	background.color = COLOR_BG
	title_label.add_theme_color_override("font_color", COLOR_TEXT)
	status_label.add_theme_color_override("font_color", COLOR_MUTED)
	board_panel.add_theme_stylebox_override("panel", _panel_style())
	_style_restart()
	_build_cells()
	restart_button.pressed.connect(_new_game)
	_new_game()


func _build_cells() -> void:
	for index in 9:
		var button := Button.new()
		button.custom_minimum_size = Vector2(112, 112)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 52)
		button.pressed.connect(_on_cell_pressed.bind(index))
		grid.add_child(button)
		cells.append(button)


func _new_game() -> void:
	if board.size() != 9:
		board.resize(9)
	for index in 9:
		board[index] = ""
	current = "X"
	game_over = false
	winning_line.clear()
	status_label.text = "X's turn"
	for index in cells.size():
		_paint_cell(index)


func _on_cell_pressed(index: int) -> void:
	if game_over or board[index] != "":
		return
	board[index] = current
	var line := _find_win(current)
	if not line.is_empty():
		game_over = true
		winning_line = line.duplicate()
		status_label.text = "%s wins" % current
	elif not board.has(""):
		game_over = true
		status_label.text = "Draw"
	else:
		current = "O" if current == "X" else "X"
		status_label.text = "%s's turn" % current
	for cell_index in cells.size():
		_paint_cell(cell_index)


func _find_win(mark: String) -> Array:
	for line in LINES:
		if board[line[0]] == mark and board[line[1]] == mark and board[line[2]] == mark:
			return line
	return []


func _paint_cell(index: int) -> void:
	var button := cells[index]
	var mark := board[index]
	var won := index in winning_line
	button.text = mark
	var fill := COLOR_WIN if won else COLOR_CELL
	var hover := COLOR_WIN if won else COLOR_CELL_HOVER
	var pressed := COLOR_WIN if won else COLOR_CELL_PRESSED
	button.add_theme_stylebox_override("normal", _cell_style(fill))
	button.add_theme_stylebox_override("hover", _cell_style(hover))
	button.add_theme_stylebox_override("pressed", _cell_style(pressed))
	button.add_theme_stylebox_override("focus", _cell_style(fill))
	if mark == "X":
		button.add_theme_color_override("font_color", COLOR_X)
	elif mark == "O":
		button.add_theme_color_override("font_color", COLOR_O)


func _panel_style() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = COLOR_PANEL
	box.set_corner_radius_all(20)
	return box


func _cell_style(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(14)
	return box


func _style_restart() -> void:
	restart_button.add_theme_color_override("font_color", COLOR_TEXT)
	restart_button.add_theme_stylebox_override("normal", _button_style(COLOR_RESTART))
	restart_button.add_theme_stylebox_override("hover", _button_style(COLOR_RESTART_HOVER))
	restart_button.add_theme_stylebox_override("pressed", _button_style(COLOR_CELL_PRESSED))
	restart_button.add_theme_stylebox_override("focus", _button_style(COLOR_RESTART))


func _button_style(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(12)
	box.content_margin_top = 10
	box.content_margin_bottom = 10
	return box
