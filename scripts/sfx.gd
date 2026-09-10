extends Node

## Autoload `Lab404Sfx` — banco de efeitos sonoros (FR-014/FR-031).
## Os WAVs são gerados por `tools/gen_audio.py` (conteúdo original, sem terceiros).

const SOUNDS := {
    "pickup": "res://audio/pickup.wav",
    "install": "res://audio/install.wav",
    "door": "res://audio/door.wav",
    "error": "res://audio/error.wav",
    "alarm": "res://audio/alarm.wav",
    "ui": "res://audio/ui.wav",
    "hum": "res://audio/hum.wav",
}

const POOL_SIZE := 6

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _hum_player: AudioStreamPlayer = null

func _ready() -> void:
    for key in SOUNDS.keys():
        var path: String = SOUNDS[key]
        if ResourceLoader.exists(path):
            _streams[key] = load(path)
    for _i in POOL_SIZE:
        var player := AudioStreamPlayer.new()
        add_child(player)
        _players.append(player)

## Toca um som pontual. Retorna false quando o banco não tem o som carregado.
func play(sound: String, volume_db := 0.0) -> bool:
    var stream: AudioStream = _streams.get(sound)
    if stream == null:
        return false
    for player in _players:
        if not player.playing:
            player.stream = stream
            player.volume_db = volume_db
            player.play()
            return true
    return false

## Frames de loop de um stream importado — a ambiência usa o arquivo inteiro.
## Os WAVs importam comprimidos em QOA: `data` guarda o bitstream, não amostras PCM,
## então o fim do loop vem da duração real (regressão em `tests/poc6_test.gd`).
static func loop_end_frames(stream: AudioStreamWAV) -> int:
    if stream == null:
        return 0
    return int(round(stream.get_length() * float(stream.mix_rate)))

## Liga/desliga a ambiência em loop (usada a partir do POC 6).
func set_ambience(enabled: bool, volume_db := -12.0) -> void:
    if not enabled:
        if _hum_player != null:
            _hum_player.stop()
            _hum_player.queue_free()
            _hum_player = null
        return
    if _hum_player != null or not _streams.has("hum"):
        return
    _hum_player = AudioStreamPlayer.new()
    var stream: AudioStreamWAV = _streams["hum"]
    stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
    stream.loop_begin = 0
    stream.loop_end = loop_end_frames(stream)
    _hum_player.stream = stream
    _hum_player.volume_db = volume_db
    add_child(_hum_player)
    _hum_player.play()

func has_sound(sound: String) -> bool:
    return _streams.has(sound)
