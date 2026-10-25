extends CanvasLayer
## Cena única, coordenada pela UI da sessão; seleção separada da compra.
var player: Node2D
var game: Node2D
@onready var panel: ColorRect = $Panel
@onready var heading: Label = $Panel/Heading
@onready var status: Label = $Panel/Details
@onready var notice: Label = $Panel/Notice
@onready var buy_button: Button = $Panel/Buy
var buttons: Dictionary = {}
var selected := "throw.unlock"
var status_mode := false
var opened := false
var timer := 0.0
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var ids: Array = player.Attributes.NODES.keys()
	for i in ids.size():
		var button: Button = panel.get_node("Node"+str(i))
		buttons[ids[i]] = button
		button.pressed.connect(select_node.bind(ids[i]))
		button.focus_entered.connect(select_node.bind(ids[i]))
	buy_button.pressed.connect(buy_selected)
	$Panel/Status.pressed.connect(show_status)
	player.attributes.changed.connect(refresh)
	refresh()
func effect(id: String) -> String:
	var config = player.character_config
	match id:
		"throw.unlock": return "Q · adaga de ida e retorno.\nRecarga %.1f s."%config.throw_cooldown
		"throw.edge": return "Dano da adaga +%d."%config.edge_damage_bonus
		"reach.first": return "Onda visível de %.0f px.\nSomente na fase ativa."%player.melee_reach.first_reach
		"reach.second": return "Onda ampliada para %.0f px.\nMesmo dano e cadência."%player.melee_reach.second_reach
		"parry.focus": return "Janela do parry +%.2f s.\nParry base já disponível."%config.focus_window_bonus
		"parry.guard": return "Resistência +%.0f%%.\nEscudo +%d, uma vez."%[config.guard_resistance_bonus*100,config.guard_shield_bonus]
	return ""
func select_node(id: String) -> void:
	selected = id
	status_mode = false
	refresh()
func show_status() -> void:
	status_mode = true
	refresh()
func buy_selected() -> void: purchase(selected)
func refresh() -> void:
	if not is_instance_valid(player):return
	var data = player.attributes
	heading.text = "PERSONAGEM · ATLAS"
	$Panel/Points.text = "%d ponto(s) · três ramos · compras duram nesta partida"%data.points
	for id in buttons:
		var mark := "ADQUIRIDO" if data.owned.has(id) else "DISPONÍVEL" if data.can_buy(id) else "BLOQUEADO"
		buttons[id].text = player.Attributes.NODES[id].label+"\n["+mark+"]"
	var item: Dictionary = player.Attributes.NODES[selected]
	var requirement: String = "Nenhum" if item.requires=="" else player.Attributes.NODES[item.requires].label
	status.text = "%s\n\n%s\n\nCusto: %d ponto(s)\nRequisito: %s"%[item.label,effect(selected),data.cost(selected),requirement]
	if status_mode:status.text = "ATRIBUTOS\n\nVida %d/%d · Fome %.0f/%.0f\nDano %d · Resistência %.0f%%\nEscudo %d/%d\nEsquiva %.2f px / %.2f s\nRecarga esquiva %.2f s\nParry %.2f s\nRecarga Q %.1f s\nOnda: nível %d"%[player.health,player.max_health,player.hunger,player.max_hunger,player.dagger_damage,player.resistance*100,player.shield,player.max_shield,player.dodge_distance,player.dodge_duration,player.dodge_cooldown,player.parry_window,data.cooldowns.throw,player.reach_level]
	buy_button.disabled = status_mode or not data.can_buy(selected)
	buy_button.text = "Adquirido" if data.owned.has(selected) else "Adquirir · %d ponto(s)"%data.cost(selected)
func purchase(id: String) -> void:
	if not opened or player.dead:return
	if player.attributes.buy(id):
		notice.text = "Adquirido: "+player.Attributes.NODES[id].label
		player.skills_changed.emit()
	else:notice.text = "Compra indisponível: confira pontos e requisito."
	refresh()
func open() -> bool:
	if opened or player.dead or game.ending!=&"none":return false
	if not game.session_ui.claim(&"tree"):return false
	player.attributes.retire_tracking()
	opened = true
	panel.visible = true
	notice.text = "Selecione um nó; a compra exige confirmação no botão."
	refresh()
	buttons[selected].grab_focus()
	return true
func close() -> void:
	if not opened:return
	opened = false
	panel.visible = false
	player.input_guard_frames = 2
	game.session_ui.release(&"tree")
func _process(delta: float) -> void:
	if not opened:return
	timer += delta
	if timer>=0.1:timer = 0;refresh()
