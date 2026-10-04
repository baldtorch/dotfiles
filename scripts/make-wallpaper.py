#!/usr/bin/env python3
"""Generate the original bundled geometric wallpaper using only Python's standard library.
Run from the repository root. The artwork is reproducible and needs no external download.
"""
import math
from pathlib import Path
import struct
import zlib
width, height = 1280, 720
rows = bytearray()
for y in range(height):
    rows.append(0)  # PNG filter: none.
    for x in range(width):
        t = y / height
        color = (int(12 + 21*t), int(20 + 25*t), int(38 + 33*t))
        if (x - 935)**2 + (y - 225)**2 < 82**2:
            color = (190, 157, 111)
        if y > 425 + 85*math.sin(x/270):
            color = (48, 75, 88)
        if y > 535 + 65*math.sin(x/205 + 2):
            color = (24, 47, 65)
        if y > 645 + 45*math.sin(x/310 + 4):
            color = (12, 27, 45)
        rows.extend(color)
def chunk(kind, data):
    return struct.pack('!I', len(data)) + kind + data + struct.pack('!I', zlib.crc32(kind + data))
png = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('!2I5B', width, height, 8, 2, 0, 0, 0))
png += chunk(b'IDAT', zlib.compress(rows, 9)) + chunk(b'IEND', b'')
Path('assets/default-wallpaper.png').write_bytes(png)
