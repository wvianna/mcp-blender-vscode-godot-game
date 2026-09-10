extends Node3D
class_name Lab404LabGenerator

## Geração procedural determinística do laboratório (FR-025…FR-027).
##
## - Módulos em grade (8×8 m), cada um com tipo, entradas/saídas registradas, pontos de
##   interesse e iluminação própria (FR-025).
## - Mesma `seed` → mesma disposição: o RNG é local e todos os sorteios passam por ele (FR-026).
## - Conectividade garantida por construção: os módulos são adicionados como uma árvore de
##   expansão a partir da entrada, então nenhum módulo fica isolado (FR-027).

const MODULE_TYPES: PackedStringArray = [
    "corredor", "controle", "bombas", "baterias", "sensores", "arquivo", "contencao",
]

const POIS_BY_TYPE := {
    "corredor": [],
    "controle": ["terminal_aria", "painel_controle"],
    "bombas": ["bomba", "tanque"],
    "baterias": ["banco_baterias"],
    "sensores": ["sensor_remoto"],
    "arquivo": ["terminal_logs"],
    "contencao": ["nucleo_aria"],
}

const MODULE_SIZE := 8.0
const WALL_HEIGHT := 3.2

var seed_value := 404
var entrance := Vector2i.ZERO

## Vector2i (grade) -> {"type": String, "grid": Vector2i, "position": Vector3,
##                     "entries": Array[Vector2i], "exits": Array[Vector2i], "pois": Array[String]}
var modules: Dictionary = {}

func generate(p_seed: int, module_count := 6) -> void:
    seed_value = p_seed
    var count := maxi(2, module_count)
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_value

    _clear()
    modules.clear()

    var fronteira: Array = []
    var primeira_tipo: String = "arquivo" if count <= 2 else "contencao"
    _add_module(entrance, primeira_tipo, rng)
    fronteira.append(entrance)

    while modules.size() < count and not fronteira.is_empty():
        var indice: int = rng.randi_range(0, fronteira.size() - 1)
        var origem: Vector2i = fronteira[indice]
        var direcoes := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
        _embaralhar(direcoes, rng)

        var colocado := false
        for direcao in direcoes:
            var alvo: Vector2i = origem + direcao
            if modules.has(alvo):
                continue
            var tipo: String = _sortear_tipo(rng, modules.size(), count)
            _add_module(alvo, tipo, rng)
            _connect(origem, alvo)
            fronteira.append(alvo)
            colocado = true
            break
        if not colocado:
            fronteira.remove_at(indice)

    _build_geometry()

## Verifica por BFS que todos os módulos são alcançáveis a partir da entrada (FR-027).
func verify_connectivity() -> bool:
    if modules.is_empty():
        return false
    var visitados: Dictionary = {entrance: true}
    var fila: Array = [entrance]
    while not fila.is_empty():
        var atual: Vector2i = fila.pop_front()
        for vizinho in modules[atual]["exits"]:
            if not visitados.has(vizinho):
                visitados[vizinho] = true
                fila.append(vizinho)
    return visitados.size() == modules.size()

func all_pois() -> Array:
    var out: Array = []
    for grid in modules.keys():
        var mod: Dictionary = modules[grid]
        for poi in mod["pois"]:
            out.append({"module": grid, "type": mod["type"], "poi": poi,
                        "position": mod["position"] + Vector3(0.0, 0.0, 0.0)})
    return out

func pois_reachable() -> bool:
    for poi in all_pois():
        if not modules.has(poi["module"]):
            return false
    return verify_connectivity()

## Hash estável da disposição (mesma seed → mesmo hash). Exposto para testes.
func layout_hash() -> String:
    var partes: PackedStringArray = []
    var grids: Array = modules.keys()
    grids.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
        return (a.y < b.y) or (a.y == b.y and a.x < b.x)
    )
    for grid in grids:
        partes.append("%d,%d:%s" % [grid.x, grid.y, modules[grid]["type"]])
    return "|".join(partes)

func module_at(grid: Vector2i) -> Dictionary:
    return modules.get(grid, {})

# --- construção -------------------------------------------------------------

func _clear() -> void:
    for child in get_children():
        remove_child(child)
        child.queue_free()

func _add_module(grid: Vector2i, tipo: String, rng: RandomNumberGenerator) -> void:
    modules[grid] = {
        "type": tipo,
        "grid": grid,
        "position": Vector3(grid.x * MODULE_SIZE, 0.0, grid.y * MODULE_SIZE),
        "entries": [],
        "exits": [],
        "pois": (POIS_BY_TYPE.get(tipo, []) as Array).duplicate(),
        "light_energy": rng.randf_range(1.4, 2.0),
    }

func _connect(a: Vector2i, b: Vector2i) -> void:
    (modules[a]["exits"] as Array).append(b)
    (modules[b]["entries"] as Array).append(a)

func _sortear_tipo(rng: RandomNumberGenerator, indice: int, total: int) -> String:
    # O último módulo é sempre a contenção (destino narrativo do POC 6).
    if indice >= total - 1:
        return "contencao"
    var opcoes: PackedStringArray = ["corredor", "controle", "bombas", "baterias", "sensores", "arquivo"]
    return String(opcoes[rng.randi_range(0, opcoes.size() - 1)])

func _embaralhar(valores: Array, rng: RandomNumberGenerator) -> void:
    for i in range(valores.size() - 1, 0, -1):
        var j: int = rng.randi_range(0, i)
        var tmp: Variant = valores[i]
        valores[i] = valores[j]
        valores[j] = tmp

func _build_geometry() -> void:
    var malha := Node3D.new()
    malha.name = "Modulos"
    add_child(malha)
    var luzes := Node3D.new()
    luzes.name = "Lights"
    add_child(luzes)

    for grid in modules.keys():
        var mod: Dictionary = modules[grid]
        var base: Vector3 = mod["position"]
        var meio := MODULE_SIZE * 0.5

        _caixa(malha, "Piso_%d_%d" % [grid.x, grid.y],
            base + Vector3(meio, -0.1, meio), Vector3(MODULE_SIZE, 0.2, MODULE_SIZE))
        _caixa(malha, "Teto_%d_%d" % [grid.x, grid.y],
            base + Vector3(meio, WALL_HEIGHT + 0.1, meio),
            Vector3(MODULE_SIZE, 0.2, MODULE_SIZE))

        # Paredes apenas onde não há vizinho (aberturas = conexões).
        var vizinhos: Array = []
        vizinhos.append_array(mod["entries"])
        vizinhos.append_array(mod["exits"])
        if not vizinhos.has(grid + Vector2i(0, -1)):
            _caixa(malha, "ParedeN_%d_%d" % [grid.x, grid.y],
                base + Vector3(meio, WALL_HEIGHT * 0.5, 0.15),
                Vector3(MODULE_SIZE, WALL_HEIGHT, 0.3))
        if not vizinhos.has(grid + Vector2i(0, 1)):
            _caixa(malha, "ParedeS_%d_%d" % [grid.x, grid.y],
                base + Vector3(meio, WALL_HEIGHT * 0.5, MODULE_SIZE - 0.15),
                Vector3(MODULE_SIZE, WALL_HEIGHT, 0.3))
        if not vizinhos.has(grid + Vector2i(-1, 0)):
            _caixa(malha, "ParedeO_%d_%d" % [grid.x, grid.y],
                base + Vector3(0.15, WALL_HEIGHT * 0.5, meio),
                Vector3(0.3, WALL_HEIGHT, MODULE_SIZE))
        if not vizinhos.has(grid + Vector2i(1, 0)):
            _caixa(malha, "ParedeL_%d_%d" % [grid.x, grid.y],
                base + Vector3(MODULE_SIZE - 0.15, WALL_HEIGHT * 0.5, meio),
                Vector3(0.3, WALL_HEIGHT, MODULE_SIZE))

        var luz := OmniLight3D.new()
        luz.name = "Luz_%d_%d" % [grid.x, grid.y]
        luz.position = base + Vector3(meio, WALL_HEIGHT - 0.3, meio)
        luz.light_energy = float(mod["light_energy"])
        luz.omni_range = MODULE_SIZE
        luzes.add_child(luz)

func _caixa(pai: Node3D, nome: String, centro: Vector3, tamanho: Vector3) -> void:
    var corpo := StaticBody3D.new()
    corpo.name = nome
    corpo.position = centro
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = tamanho
    mesh.mesh = box
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.42, 0.44, 0.46)
    mat.roughness = 0.9
    mesh.material_override = mat
    corpo.add_child(mesh)
    var forma := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = tamanho
    forma.shape = shape
    corpo.add_child(forma)
    pai.add_child(corpo)
