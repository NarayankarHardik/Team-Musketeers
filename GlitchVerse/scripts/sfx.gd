extends Node
## Tiny procedural sound-effect synth (autoload: Sfx). No audio files needed.

var _sounds := {}
var _players: Array = []
var _next := 0


func _ready() -> void:
    _sounds["jump"] = _tone(280.0, 620.0, 0.12, 0.22, "square")
    _sounds["land"] = _tone(140.0, 60.0, 0.08, 0.30, "sine")
    _sounds["collect"] = _tone(700.0, 1500.0, 0.15, 0.20, "square")
    _sounds["key"] = _tone(500.0, 1700.0, 0.32, 0.28, "sine")
    _sounds["flip"] = _tone(900.0, 180.0, 0.28, 0.32, "sine")
    _sounds["phase"] = _tone(300.0, 300.0, 0.20, 0.22, "noise")
    _sounds["freeze"] = _tone(1300.0, 260.0, 0.55, 0.28, "sine")
    _sounds["dash"] = _tone(420.0, 1650.0, 0.10, 0.23, "noise")
    _sounds["unfreeze"] = _tone(260.0, 900.0, 0.22, 0.24, "sine")
    _sounds["deny"] = _tone(160.0, 120.0, 0.12, 0.28, "square")
    _sounds["die"] = _tone(420.0, 45.0, 0.45, 0.30, "square")
    _sounds["win"] = _tone(400.0, 1300.0, 0.6, 0.30, "sine")
    for i in 8:
        var p := AudioStreamPlayer.new()
        p.volume_db = -6.0
        add_child(p)
        _players.append(p)


func play(sound_name: String, pitch: float = 1.0) -> void:
    if not _sounds.has(sound_name):
        return
    var p: AudioStreamPlayer = _players[_next]
    _next = (_next + 1) % _players.size()
    p.stream = _sounds[sound_name]
    p.pitch_scale = pitch
    p.play()


func _tone(f_start: float, f_end: float, duration: float, volume: float, wave: String) -> AudioStreamWAV:
    var rate := 22050
    var count := int(rate * duration)
    var data := PackedByteArray()
    data.resize(count * 2)
    var phase := 0.0
    for i in count:
        var t := float(i) / float(count)
        phase += lerpf(f_start, f_end, t) / float(rate)
        var s := 0.0
        if wave == "square":
            s = 1.0 if fmod(phase, 1.0) < 0.5 else -1.0
        elif wave == "noise":
            s = randf() * 2.0 - 1.0
        else:
            s = sin(TAU * phase)
        s *= volume * (1.0 - t)
        data.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 32767.0))
    var wav := AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = rate
    wav.stereo = false
    wav.data = data
    return wav
