extends Node

## Teste automatizado do POC 5 (headless) — CA-012.
## Geração determinística (FR-026) e conectividade garantida (FR-027).

const SEEDS := [1, 7, 42, 404, 999, 12345]

var _checks := 0
var _failures: PackedStringArray = []

func _ready() -> void:
    await get_tree().process_frame

    var a := _gerar(404, 6)
    var b := _gerar(404, 6)
    var c := _gerar(405, 6)

    print("== FR-025: módulos, POIs e iluminação ==")
    _check("módulos gerados conforme pedido (6)", a.modules.size() == 6)
    _check("módulo final é a contenção", String(a.module_at(_ultimo_grid(a))["type"]) == "contencao")
    _check("todos os tipos são válidos", _tipos_validos(a))
    _check("POIs existem (nucleo_aria na contenção)", _tem_poi(a, "nucleo_aria"))
    _check("geometria construída (corpos estáticos)", _contar(a, "StaticBody3D") > 0)
    _check("iluminação por módulo", _contar(a, "OmniLight3D") == a.modules.size())
    _check("saídas e entradas recíprocas", _reciprocidade_ok(a))

    print("== FR-026 / CA-012: determinismo por seed ==")
    _check("mesma seed → mesmo layout", a.layout_hash() == b.layout_hash())
    _check("hash não vazio", not a.layout_hash().is_empty())
    _check("seed diferente → layout diferente", a.layout_hash() != c.layout_hash())

    print("== FR-027 / CA-012: conectividade garantida ==")
    for seed_value in SEEDS:
        var gerador := _gerar(int(seed_value), 8)
        var conectado: bool = gerador.verify_connectivity()
        _check("seed %d: nenhuma sala inacessível" % int(seed_value), conectado)
        _check("seed %d: pontos de interesse alcançáveis" % int(seed_value), gerador.pois_reachable())

    print("== FR-025: módulos contêm POIs coerentes ==")
    var com_poi := 0
    for grid in a.modules.keys():
        if not (a.module_at(grid)["pois"] as Array).is_empty():
            com_poi += 1
    _check("há módulos com pontos de interesse (%d)" % com_poi, com_poi >= 1)

    _report()

# --- utilitários ------------------------------------------------------------

func _gerar(seed_value: int, count: int) -> Lab404LabGenerator:
    var gerador := Lab404LabGenerator.new()
    get_tree().root.add_child(gerador)
    gerador.generate(seed_value, count)
    return gerador

func _ultimo_grid(gerador: Lab404LabGenerator) -> Vector2i:
    for grid in gerador.modules.keys():
        if String(gerador.module_at(grid)["type"]) == "contencao":
            return grid
    return Vector2i.ZERO

func _tipos_validos(gerador: Lab404LabGenerator) -> bool:
    for grid in gerador.modules.keys():
        if String(gerador.module_at(grid)["type"]) not in Lab404LabGenerator.MODULE_TYPES:
            return false
    return true

func _tem_poi(gerador: Lab404LabGenerator, poi_name: String) -> bool:
    for poi in gerador.all_pois():
        if String(poi["poi"]) == poi_name:
            return true
    return false

func _contar(gerador: Lab404LabGenerator, tipo: String) -> int:
    var total := 0
    var pilha: Array = [gerador]
    while not pilha.is_empty():
        var node: Node = pilha.pop_back()
        for child in node.get_children():
            if child.is_class(tipo):
                total += 1
            pilha.append(child)
    return total

func _reciprocidade_ok(gerador: Lab404LabGenerator) -> bool:
    for grid in gerador.modules.keys():
        for destino in gerador.module_at(grid)["exits"]:
            var mod_destino: Dictionary = gerador.module_at(destino)
            if mod_destino.is_empty():
                return false
            if not (mod_destino["entries"] as Array).has(grid):
                return false
    return true

func _check(label: String, condition: bool) -> void:
    _checks += 1
    if condition:
        print("  [PASS] %s" % label)
    else:
        _failures.append(label)
        print("  [FALHA] %s" % label)

func _report() -> void:
    print("")
    print("== RESULTADO POC 5: %d verificações, %d falha(s) ==" % [_checks, _failures.size()])
    for failure in _failures:
        print("  FALHA: %s" % failure)
    get_tree().quit(1 if _failures.size() > 0 else 0)
