extends Node
class_name AriaClient

## Cliente HTTP do adapter local de ARIA (FR-018).
## - timeout curto no lado do jogo com fallback textual (CA-009);
## - valida a intent devolvida contra `ALLOWED_INTENTS` (CA-010);
## - nunca deixa o jogo travar esperando a LLM.

signal reply_received(text: String, intent: String)
signal reply_failed(reason: String)

const ALLOWED_INTENTS: PackedStringArray = ["HINT", "DIAGNOSE", "LORE", "STATUS", "NONE"]
const FALLBACK_TEXT := "A comunicação com ARIA está indisponível."

@export var endpoint := "http://127.0.0.1:8000/chat"
## O adapter espera até 30 s pelo Ollama (NFR-004); o cliente espera um pouco mais para
## receber a resposta real de um LLM local (um modelo 8B levou ~22 s em medição) e só
## corta em caso de conexão pendurada. Adapter fora do ar falha na hora (conexão recusada).
@export var timeout_seconds := 35.0

var _request: HTTPRequest = null
var _pending := false

func _ready() -> void:
    _request = HTTPRequest.new()
    _request.timeout = timeout_seconds
    add_child(_request)
    _request.request_completed.connect(_on_request_completed)

func is_busy() -> bool:
    return _pending

## Envia uma mensagem. Retorna false se já existe requisição em andamento.
func ask(message: String, game_state: Dictionary = {}) -> bool:
    if _pending:
        return false
    var body := JSON.stringify({"message": message, "game_state": game_state})
    var err := _request.request(
        endpoint,
        ["Content-Type: application/json"],
        HTTPClient.METHOD_POST,
        body
    )
    if err != OK:
        _fail("falha ao iniciar requisição (%d)" % err)
        return false
    _pending = true
    return true

## Converte qualquer string em uma intent permitida (CA-010). Exposto para testes.
static func sanitize_intent(value: String) -> String:
    var candidate := value.strip_edges().to_upper()
    return candidate if candidate in ALLOWED_INTENTS else "NONE"

func _on_request_completed(
    result: int,
    response_code: int,
    _headers: PackedStringArray,
    body: PackedByteArray
) -> void:
    _pending = false
    if result != HTTPRequest.RESULT_SUCCESS:
        _fail("sem resposta do adapter (resultado %d)" % result)
        return
    if response_code >= 400:
        _fail("adapter respondeu HTTP %d" % response_code)
        return
    var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
    if typeof(parsed) != TYPE_DICTIONARY:
        _fail("resposta inválida do adapter")
        return
    var text := String(parsed.get("text", ""))
    var intent := sanitize_intent(String(parsed.get("intent", "NONE")))
    if text.is_empty():
        text = FALLBACK_TEXT
    reply_received.emit(text, intent)

func _fail(reason: String) -> void:
    reply_failed.emit(reason)
    reply_received.emit(FALLBACK_TEXT, "NONE")
