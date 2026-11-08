"""Bakes the adhan screen's arch into assets/images/art/.

    python tool/adhan_art.py [out_dir]

The ringing adhan's window, after the owner's reference assets/adhan_screen.jpg:
a tall cusped arch in one thick band of paper with a step down to the sky, a
broad scalloped plate behind it that runs off the top of the screen, a column
at each side, the mosque standing in the window, and banks of paper clouds that
climb the columns and run on down the sides, where the prayer's name sits.
Built from tool/hero_art.py's sheets and themes, so it is the same paper as the
tab headers. Like theirs, the window is see-through: AdhanRingScreen paints the
prayer's sky (and the crescent, and Isha's stars) under it.

Everything is in a 390 x 600 art space, the width of a phone in dp.
"""
import os
import sys

import numpy as np
from shapely.geometry import Point, Polygon, box
from shapely.ops import unary_union

import hero_art as H
from hero_art import SKIES, THEMES, Stack, bezier, sculpted_cloud_bank

# Keep in step with AdhanRingScreen's _artSize, _skyRect, _moon and _stars.
W, HT = 390, 600
CX = W / 2
# x, y, w, h: the sky image, cover-fitted and held to its left edge, which puts
# the sun and moon beside the minarets rather than behind them.
SKY = (CX - 150, 50, 300, 390)
MOON = (CX + 3, 131, 16)
STARS = [(CX - 23, 124, 2.4), (CX - 45, 150, 3.0), (CX + 1, 110, 2.0),
         (CX - 85, 180, 2.4), (CX + 105, 196, 2.2), (CX - 95, 220, 2.0),
         (CX + 95, 236, 2.2)]

# 3x a 390 dp phone.
PX = int(os.environ.get('NOOR_PX', 3))
MITRE = dict(join_style=2, mitre_limit=5)


def arch(apex, cusp, half, spring, foot=HT + 20):
    """A pointed crown down to a cusp on each side, then a lobe swelling out
    and down to the springing, then straight sides to the foot."""
    cx, cy = cusp
    h1, h2, dx = cy - apex, spring - cy, half - cx
    crown = bezier((0, apex), (0.35 * cx, apex + 0.25 * h1), (0.80 * cx, apex + 0.55 * h1), (cx, cy), 48)
    lobe = bezier((cx, cy), (cx + 0.6 * dx, cy - 0.08 * h2), (half, cy + 0.30 * h2), (half, spring), 48)[1:]
    right = [(CX + x, y) for x, y in crown + lobe]
    left = [(2 * CX - x, y) for x, y in reversed(right)]
    return Polygon(left[:-1] + right + [(CX + half, foot), (CX - half, foot)])


HOLE = arch(83, (74, 140), 139, 206)
BACK = arch(-14, (92, 74), 182, 158)


def column(side):
    """A column standing on the band beside the window: shaft, base ring,
    capital and abacus, and a pointed finial on top."""
    x = CX + side * 150
    shaft = box(x - 10, 244, x + 10, HT + 20)
    ring = box(x - 13, 246, x + 13, 250)
    capital = box(x - 19, 232, x + 19, 244)
    abacus = box(x - 22, 227, x + 22, 232)
    tip = bezier((x, 204), (x + 1.5, 213), (x + 8, 219), (x + 8, 227), 16)
    finial = Polygon(tip + [(2 * x - px, py) for px, py in reversed(tip)][1:])
    return shaft, unary_union([ring, capital, abacus]), finial


def mirrored(lobes):
    return lobes + [(W - x, y, r) for x, y, r in reversed(lobes) if x != CX]


# Back to front: (lobes, how far the face is lifted from the page toward the
# theme's brightest cloud, how strong its shadow is). High where they climb the
# columns and low in the middle under the mosque, each bank lower, closer to
# the page and softer than the last, until the front ones are hardly more
# than a shadow and the page takes over.
BANKS = [
    (mirrored([(-14, 368, 46), (44, 386, 34), (98, 404, 30), (150, 420, 30), (CX, 426, 32)]), 0.62, 1.0),
    (mirrored([(-4, 406, 54), (80, 426, 36), (136, 444, 28), (CX, 454, 32)]), 0.52, 0.9),
    (mirrored([(-30, 440, 50), (34, 450, 50), (110, 474, 34), (CX, 490, 30)]), 0.42, 0.8),
    (mirrored([(-6, 484, 58), (90, 510, 40), (CX, 530, 32)]), 0.32, 0.65),
    (mirrored([(-20, 520, 50), (46, 532, 54), (132, 556, 36), (CX, 568, 30)]), 0.22, 0.5),
]


def clouds(st, t):
    """Paper clouds nearly the page's own colour, drawn by their soft shadows
    and lit rims, as in the reference, rather than white on grey."""
    page, top = H.rgb(t['page']), H.rgb(t['cloud'][0])
    sc, k = t['shadow'], t['shadow_k']
    for lobes, lift_face, shade in BANKS:
        # Raised past the lowest domes' waists, so no gap opens between them.
        bank = sculpted_cloud_bank(lobes, foot=HT + 20, full_width=True).union(
            box(-40, max(y for _, y, _ in lobes) - 16, W + 40, HT + 20))
        m = st.mask(bank)
        st.shadow(m, 0.2, 1.2, 1.2, min(0.18 * k * shade, 0.5), sc)
        st.shadow(m, 0.5, 4.0, 5.0, min(0.15 * k * shade, 0.45), sc)
        st.sheet(bank, page + (top - page) * lift_face, lift=0, theme=t,
                 edge=t['edge'] * (0.5 + 0.5 * shade), wash=0)


def dissolve(st, color, y0, y1):
    """[color] from nothing at y0 to solid at y1, eased at both ends so no
    line shows where it starts or where the page takes over."""
    y = st.y0 + (np.arange(st.H, dtype=np.float32) + .5) / st.s
    u = np.clip((y - y0) / (y1 - y0), 0, 1)
    a = u * u * (3 - 2 * u)
    st._over(H.rgb(color), np.broadcast_to(a[:, None], (st.H, st.W)).copy())


def frame(theme_name, out):
    t = THEMES[theme_name]
    rims = t['rims']
    st = Stack((0, 0, W, HT))

    # The mosque, its doors just clear of the clouds.
    st.sprite('masjid.png', CX, 292, w=228, lift=1.4, theme=t, clip=HOLE)

    # The page, and the scalloped plate behind the arch in two thin sheets.
    st.sheet(box(-20, -20, W + 20, HT + 20).difference(HOLE), t['page'],
             lift=0, theme=t, edge=0, wash=0)
    st.sheet(BACK.difference(HOLE), t['page'], lift=1.2, theme=t, edge=t['edge'] * 0.7, wash=0.02)
    st.sheet(BACK.buffer(-8, **MITRE).difference(HOLE), t['page'],
             lift=1.0, theme=t, edge=t['edge'] * 0.6, wash=0.02)

    # The step down to the sky, then the band over it.
    st.sheet(HOLE.buffer(8, **MITRE).difference(HOLE), rims[2], lift=1.4, theme=t, edge=t['edge'])
    st.sheet(HOLE.buffer(25, **MITRE).difference(HOLE.buffer(4, **MITRE)), rims[0],
             lift=2.8, theme=t, edge=t['edge'] * 1.1, wash=0.03)

    for side in (-1, 1):
        shaft, head, finial = column(side)
        st.sheet(shaft, rims[0], lift=2.2, theme=t, edge=t['edge'], wash=0.04)
        st.sheet(finial, rims[0], lift=2.0, theme=t, edge=t['edge'] * 1.2, wash=0)
        st.sheet(head, rims[0], lift=2.4, theme=t, edge=t['edge'] * 1.2, wash=0)

    clouds(st, t)
    dissolve(st, t['page'], 480, 596)

    check(st)
    return st.save(f'{out}/adhan_frame_{theme_name}.webp')


def in_window(x, y):
    """Where a point of the sky image lands: cover-fitted to SKY, left edges
    together."""
    sx, sy, sw, sh = SKY
    k = max(sw / H.SKY[2], sh / H.SKY[3])
    return (sx + (x - H.SKY[0]) * k,
            sy + sh / 2 + (y - H.SKY[1] - H.SKY[3] / 2) * k)


def check(st):
    """The window shows sky only where the sky image reaches, and nothing
    painted into it, sun, crescent or stars, falls outside it or onto the art."""
    sx, sy, sw, sh = SKY
    sky = box(sx, sy, sx + sw, sy + sh)
    assert sky.contains(HOLE.intersection(box(0, 0, W, sy + sh))), 'the window outruns the sky'
    # Below the sky image the window must be covered by mosque or cloud.
    s = st.s
    rows = slice(int((sy + sh) * s), st.H)
    hole = st.mask(HOLE)[rows]
    assert (st.a[rows][hole > 0.99] > 0.99).all(), 'the window shows through below the sky'
    inner = HOLE.buffer(-12)
    for name, d in SKIES.items():
        x, y = in_window(*d['sun'][:2])
        assert inner.contains(Point(x, y)), f'the {name} sun leaves the window'
    for x, y, r in STARS + [MOON]:
        assert inner.contains(Point(x, y).buffer(r)), f'{x},{y} leaves the window'
        # The frame's shadows reach in; only the paper itself hides a star.
        assert st.a[int(y * s), int(x * s)] < 0.4, f'{x},{y} falls on the art'


if __name__ == '__main__':
    H.PX = PX
    out = sys.argv[1] if len(sys.argv) > 1 else H.ART_DIR
    for theme in THEMES:
        frame(theme, out)
