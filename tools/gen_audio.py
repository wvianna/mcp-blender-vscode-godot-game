#!/usr/bin/env python3
"""Gera os efeitos sonoros originais do Laboratório 404.

Todos os sons são sintetizados aqui (sem material de terceiros), em WAV
16-bit mono 22050 Hz, de forma determinística.

Uso: python3 tools/gen_audio.py
"""

import math
import os
import random
import struct
import wave

RATE = 22050
OUT = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", "audio"))


def envelope(i: int, n: int, attack: float = 0.02, release: float = 0.3) -> float:
    a = int(n * attack)
    r = int(n * release)
    if i < a:
        return i / max(a, 1)
    if i > n - r:
        return max(0.0, (n - i) / max(r, 1))
    return 1.0


def write(name: str, samples: list) -> None:
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, name)
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        frames = b"".join(
            struct.pack("<h", max(-32767, min(32767, int(s * 32767)))) for s in samples
        )
        w.writeframes(frames)
    print("ok %-12s %.2f s" % (name, len(samples) / RATE))


def tone(freq, dur, vol=0.5, attack=0.02, release=0.3, harmonics=()):
    n = int(RATE * dur)
    out = []
    for i in range(n):
        t = i / RATE
        v = math.sin(2 * math.pi * freq * t)
        for h, hv in harmonics:
            v += hv * math.sin(2 * math.pi * freq * h * t)
        out.append(vol * v * envelope(i, n, attack, release))
    return out


def sweep(f0, f1, dur, vol=0.5):
    n = int(RATE * dur)
    out = []
    phase = 0.0
    for i in range(n):
        freq = f0 + (f1 - f0) * (i / n)
        phase += 2 * math.pi * freq / RATE
        out.append(vol * math.sin(phase) * envelope(i, n, 0.01, 0.4))
    return out


def noise(dur, vol=0.2, seed=404):
    rnd = random.Random(seed)
    n = int(RATE * dur)
    return [vol * rnd.uniform(-1, 1) * envelope(i, n, 0.02, 0.5) for i in range(n)]


def mix(*tracks):
    n = max(len(t) for t in tracks)
    out = [0.0] * n
    for track in tracks:
        for i, s in enumerate(track):
            out[i] += s
    return [max(-1.0, min(1.0, s)) for s in out]


def concat(*tracks):
    out = []
    for track in tracks:
        out.extend(track)
    return out


def silence(dur):
    return [0.0] * int(RATE * dur)


def main() -> None:
    write("pickup.wav", sweep(660, 1320, 0.14, 0.35))
    write("install.wav", concat(tone(440, 0.10, 0.35), tone(660, 0.14, 0.35)))
    write("door.wav", mix(sweep(140, 55, 0.7, 0.4), noise(0.7, 0.08)))
    write("error.wav", mix(tone(196, 0.22, 0.3, harmonics=((3, 0.35),)), noise(0.22, 0.05)))
    write("alarm.wav", concat(tone(990, 0.18, 0.35), silence(0.12), tone(990, 0.18, 0.35), silence(0.25)))
    write("ui.wav", tone(1200, 0.05, 0.25))

    # ambiência: drone de 4 s (60 Hz + 120 Hz + ruído suavizado), pensado para loop
    n = int(RATE * 4.0)
    rnd = random.Random(7)
    hum = []
    low = 0.0
    for i in range(n):
        t = i / RATE
        low = 0.98 * low + 0.02 * rnd.uniform(-1, 1)
        v = 0.22 * math.sin(2 * math.pi * 60 * t)
        v += 0.08 * math.sin(2 * math.pi * 120 * t)
        v += 0.5 * low
        hum.append(0.35 * v * envelope(i, n, 0.15, 0.15))
    write("hum.wav", hum)


if __name__ == "__main__":
    main()
