"""Bakes the NoorHero paper-cut art into assets/images/art/.

    python tool/hero_art.py [out_dir] [tab ...]

flutter_svg has no blur and a live blur on every tab janks, so each stack of cut
paper is rendered here once: real soft shadows and lit paper edges, in the app's
exact paper colours. Needs numpy, scipy, shapely and Pillow; the app needs none.

Everything is in the hero's 390 x 240 art space. A frame is opaque paper around
a see-through ogee window, so the sky drawn under it needs no clipping at
runtime. The cloud strip runs across the band's foot, over the frame, and tiles.
The look follows the owner's references, assets/day_states.png and
assets/screen_bg.png.
"""
import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw
from scipy.ndimage import gaussian_filter
from shapely import affinity
from shapely.geometry import LineString, MultiPolygon, Point, Polygon, box
from shapely.ops import unary_union

# Keep in step with NoorHero's _frameRect, _skyRect and _cloudsTop.
FRAME = (167, 0, 240, 240)  # x, y, w, h; wider than the art, so shadows fade out
SKY = (205, 16, 164, 180)
CLOUDS = (0, 168, 390, 72)
CX = FRAME[0] + FRAME[2] / 2

# Final pixels per art unit: 3x phone at full width, with room for tablets.
# NOOR_PX=2 for quick previews only.
PX = int(os.environ.get('NOOR_PX', 4))
SS = 2  # Supersampling while drawing.


def rgb(h):
    return np.array([int(h[i:i + 2], 16) for i in (1, 3, 5)], dtype=np.float32) / 255


# Must match NoorColors.light.paper / dark.paper, or a seam shows: art_assets_test.
THEMES = {
    'paper': dict(page='#eef0f4', rims=['#ffffff', '#f7f8fa', '#e9ebf0', '#dcdfe6'],
                  cloud=['#ffffff', '#f6f7f9', '#e8eaef'],
                  shadow='#2a2e38', shadow_k=1.0, edge=0.08),
    'night': dict(page='#101217', rims=['#2b303b', '#1f232b', '#181b22', '#0c0d11'],
                  cloud=['#2b303b', '#22262f', '#1a1d24'],
                  shadow='#000000', shadow_k=1.7, edge=0.16),
}
MOON = '#fbfaf7'
MOON_SHADE = '#e6e4df'
MOON_DEEP = '#cdcac4'
GOLD = '#c9a24e'
GOLD_DEEP = '#9c7a33'
KAABA = '#17191f'
KAABA_SIDE = '#0b0c0f'
WOOD = '#a8713f'
WOOD_DEEP = '#7d4f28'
AMBER = '#e3962f'
AMBER_DEEP = '#b86e1c'


def blur(m, sigma, wrap=False):
    """Gaussian blur; a wide one runs on a smaller copy, which looks the same."""
    if wrap:
        # Blur a copy padded with its own far edges, so the ends still meet.
        pad = min(int(sigma * 3) + 1, m.shape[1])
        return blur(np.pad(m, ((0, 0), (pad, pad)), mode='wrap'), sigma)[:, pad:-pad]
    k = int(sigma / 3)
    if k < 2:
        return gaussian_filter(m, sigma, truncate=3, mode='nearest')
    h, w = m.shape
    small = m[:h - h % k, :w - w % k].reshape(h // k, k, w // k, k).mean((1, 3))
    small = gaussian_filter(small, sigma / k, truncate=3, mode='nearest')
    img = Image.fromarray(small, 'F').resize((w, h), Image.BILINEAR)
    return np.asarray(img, dtype=np.float32)


class Stack:
    """Layers composited back to front, in straight colour over premultiplied alpha.

    A [wrap] stack is a horizontal tile: shapes and shadows run off one side and
    back in on the other, so it repeats without a seam.
    """

    def __init__(self, rect, wrap=False):
        self.x0, self.y0, self.w, h = rect
        self.wrap = wrap
        self.s = PX * SS
        self.W, self.H = int(round(self.w * self.s)), int(round(h * self.s))
        self.rgb = np.zeros((self.H, self.W, 3), dtype=np.float32)
        self.a = np.zeros((self.H, self.W), dtype=np.float32)

    def mask(self, geom):
        if self.wrap:
            geom = unary_union([affinity.translate(geom, dx) for dx in (-self.w, 0, self.w)])
        img = Image.new('L', (self.W, self.H), 0)
        d = ImageDraw.Draw(img)
        polys = geom.geoms if hasattr(geom, 'geoms') else [geom]
        pt = lambda c: [((x - self.x0) * self.s, (y - self.y0) * self.s) for x, y in c]
        for p in polys:
            if p.is_empty or not isinstance(p, Polygon):
                continue
            d.polygon(pt(p.exterior.coords), fill=255)
            for hole in p.interiors:
                d.polygon(pt(hole.coords), fill=0)
        return np.asarray(img, dtype=np.float32) / 255

    def _over(self, color, alpha):
        keep = 1 - alpha
        self.rgb = color * alpha[..., None] + self.rgb * keep[..., None]
        self.a = alpha + self.a * keep

    def shadow(self, m, dx, dy, sigma, opacity, color):
        """A soft cast shadow, which falls on whatever is below, or stays as alpha."""
        s = self.s
        shifted = np.roll(np.roll(m, int(dy * s), axis=0), int(dx * s), axis=1)
        # What rolled off one edge must not come back on the other, but a tile's does.
        shifted[:max(int(dy * s), 0)] = 0
        if not self.wrap:
            if dx > 0:
                shifted[:, :int(dx * s)] = 0
            elif dx < 0:
                shifted[:, int(dx * s):] = 0
        self._over(rgb(color), blur(shifted, sigma * s, self.wrap) * opacity)

    def sheet(self, geom, face, lift=1.0, theme=None, edge=0.12, wash=0.05, opacity=1.0):
        """One sheet of paper: its cast shadow, then its lit face."""
        t = theme or THEMES['paper']
        m = self.mask(geom)
        if lift > 0:
            sc, k = t['shadow'], t['shadow_k']
            # A tight contact shadow and a wide soft one, falling down from a
            # light above: what reads as real depth.
            self.shadow(m, 0.1 * lift, 0.6 * lift, 0.5 * lift, min(0.34 * k, 0.8), sc)
            self.shadow(m, 0.3 * lift, 2.2 * lift, 2.6 * lift, min(0.28 * k, 0.7), sc)
        c = rgb(face) if isinstance(face, str) else face
        col = np.broadcast_to(c, (self.H, self.W, 3)).astype(np.float32).copy()
        # Lit from above and a little left: a sheet's thickness catches it on top.
        gy, gx = np.gradient(blur(m, 0.32 * self.s, self.wrap))
        lit = (gx * 0.35 + gy * 0.94) * self.s * 0.9
        col = col + (np.clip(lit, -1, 1) * edge)[..., None]
        if wash:
            ramp = np.linspace(1 + wash / 2, 1 - wash / 2, self.H, dtype=np.float32)
            col = col * ramp[:, None, None]
        self._over(np.clip(col, 0, 1), m * opacity)

    def glow(self, x, y, r, color, opacity):
        s = self.s
        yy, xx = np.ogrid[:self.H, :self.W]
        d = np.hypot(xx - (x - self.x0) * s, yy - (y - self.y0) * s) / (r * s)
        self._over(rgb(color), np.clip(1 - d, 0, 1) ** 2 * opacity)

    def gradient(self, stops):
        """A vertical wash through (t, colour) stops, t from 0 at the top to 1."""
        t = np.linspace(0, 1, self.H, dtype=np.float32)
        ts = [p for p, _ in stops]
        cols = np.array([rgb(c) for _, c in stops])
        col = np.stack([np.interp(t, ts, cols[:, i]) for i in range(3)], -1)
        self._over(np.broadcast_to(col[:, None, :], (self.H, self.W, 3)), np.ones((self.H, self.W), np.float32))

    def fade(self, color, y0, y1):
        """[color] coming in from nothing at y0 to solid at y1 and below."""
        y = self.y0 + (np.arange(self.H, dtype=np.float32) + .5) / self.s
        a = np.clip((y - y0) / (y1 - y0), 0, 1) ** 1.5
        self._over(rgb(color), np.broadcast_to(a[:, None], (self.H, self.W)).copy())

    def save(self, path, lossless=True, crop=None):
        s = SS
        h, w = self.H // s, self.W // s
        down = lambda a: a[:h * s, :w * s].reshape(h, s, w, s, *a.shape[2:]).mean((1, 3))
        al = np.clip(down(self.a), 0, 1)
        col = np.clip(down(self.rgb), 0, 1)
        straight = np.divide(col, al[..., None], out=np.zeros_like(col), where=al[..., None] > 1e-4)
        out = np.dstack([straight, al]) * 255
        out = np.round(np.clip(out, 0, 255)).astype(np.uint8)
        out[out[..., 3] == 0, :3] = 0  # Clean zero-alpha pixels compress far better.
        img = Image.fromarray(out, 'RGBA')
        if crop:
            img = img.crop((crop[0] * PX, 0, crop[1] * PX, img.height))
        if lossless:
            img.save(path, 'WEBP', lossless=True, quality=100, method=6, exact=False)
        else:
            img.convert('RGB').save(path, 'WEBP', quality=88, method=6)
        return img


def mirror(g, cx=CX):
    return unary_union([g, affinity.scale(g, -1, 1, origin=(cx, 0))])


def circle(x, y, r):
    return Point(x, y).buffer(r, 48)


def star8(x, y, r):
    a = box(x - r * .71, y - r * .71, x + r * .71, y + r * .71)
    return unary_union([a, affinity.rotate(a, 45, origin=(x, y))])


def crescent(x, y, r):
    return circle(x, y, r).difference(circle(x + r * .42, y - r * .2, r * .84))


def bezier(p0, p1, p2, p3, n=32):
    out = []
    for i in range(n + 1):
        t = i / n
        a, b, c, d = (1 - t) ** 3, 3 * t * (1 - t) ** 2, 3 * t * t * (1 - t), t ** 3
        out.append((a * p0[0] + b * p1[0] + c * p2[0] + d * p3[0],
                    a * p0[1] + b * p1[1] + c * p2[1] + d * p3[1]))
    return out


def ogee(half, spring, apex, bulge=0.12, neck=0.42, foot=240):
    """An onion arch: a pointed tip that flares, swells past the sides at the
    shoulder, then drops on straight sides to the foot."""
    h = spring - apex
    m = (0.55 * half, apex + neck * h)
    right = bezier((0, apex), (0.03 * half, apex + 0.22 * neck * h),
                   (0.2 * half, apex + 0.75 * neck * h), m)
    right += bezier(m, (0.95 * half, apex + 1.2 * neck * h),
                    ((1 + 2.2 * bulge) * half, spring - 0.42 * h), (half, spring))[1:]
    right = [(CX + x, y) for x, y in right]
    left = [(2 * CX - x, y) for x, y in reversed(right)]
    return Polygon(left[:-1] + right + [(CX + half, foot), (CX - half, foot)])


def cloud(x, y, w, h, seed=0):
    """A puffy cut-paper cloud: a flat-bottomed run of round puffs."""
    rnd = np.random.default_rng(seed)
    n = max(3, int(w / (h * .8)))
    puffs = []
    for i in range(n):
        u = (i + .5) / n
        r = h * (.5 + .5 * math.sin(u * math.pi)) * (0.85 + 0.3 * rnd.random())
        puffs.append(circle(x - w / 2 + u * w, y - r * .45, r))
    # A lower row of small puffs rounds the foot off instead of a flat cut.
    base = [circle(x - w / 2 + (i + .5) / (n + 1) * w, y + h * .2, h * .42) for i in range(n + 1)]
    return unary_union(puffs + base)


# ----------------------------------------------------------------- Mosque
def minaret(x, top, foot, w=5.0):
    """A minaret: finial, cone, gallery, shaft."""
    return unary_union([
        box(x - .35, top, x + .35, top + 5),
        Polygon([(x, top + 3), (x + w * .5, top + 12), (x - w * .5, top + 12)]),
        box(x - w * .45, top + 12, x + w * .45, top + 20),
        box(x - w * .9, top + 20, x + w * .9, top + 22.5),
        box(x - w * .55, top + 22.5, x + w * .55, top + 36),
        box(x - w * .85, top + 36, x + w * .85, top + 38.5),
        box(x - w * .62, top + 38.5, x + w * .62, foot),
    ])


def dome(x, y, r):
    """An onion dome sitting on y, with its finial."""
    d = circle(x, y - r * .45, r)
    neck = Polygon([(x - r * .45, y - r * 1.3), (x, y - r * 1.68), (x + r * .45, y - r * 1.3)])
    body = unary_union([d, neck]).intersection(box(x - r * 2, y - r * 3, x + r * 2, y))
    return unary_union([body, box(x - .4, y - r * 2.1, x + .4, y - r * 1.6),
                        circle(x, y - r * 1.75, .9)])


def arches(x0, x1, y, h, n, w_frac=0.6):
    """A row of pointed openings to cut out of a wall."""
    step = (x1 - x0) / n
    w = step * w_frac
    out = []
    for i in range(n):
        cx = x0 + step * (i + .5)
        top = y + w * .75
        out.append(Polygon([(cx - w / 2, y + h), (cx - w / 2, top), (cx - w * .28, y + w * .22),
                            (cx, y), (cx + w * .28, y + w * .22), (cx + w / 2, top), (cx + w / 2, y + h)]))
    return unary_union(out)


def mosque(st, base, k=1.0, far=True, minarets=True, hall=True):
    """A white mosque standing on [base]: far wings and minarets in shade, the
    domed hall in front, each plane casting on the one behind."""
    def at(dx, dy):
        return CX + dx * k, base - dy * k

    if far:
        wing = box(CX - 52 * k, base - 22 * k, CX + 52 * k, base + 4)
        domes = mirror(dome(*at(34, 22), 9 * k))
        st.sheet(unary_union([wing, domes]), MOON_DEEP, lift=0.6, edge=0.06)
        st.sheet(arches(CX - 50 * k, CX + 50 * k, base - 16 * k, 20 * k, 11, .45), '#bdb9b2', lift=0, edge=0, wash=0)
    if minarets:
        st.sheet(mirror(minaret(*at(58, 98), base + 4, 5.2 * k)), MOON_SHADE, lift=0.9, edge=0.1)
        st.sheet(mirror(minaret(*at(42, 82), base + 4, 4.4 * k)), MOON_SHADE, lift=0.8, edge=0.1)
    if not hall:
        return
    side = mirror(unary_union([box(CX + 18 * k, base - 30 * k, CX + 38 * k, base + 4), dome(*at(28, 30), 10.5 * k)]))
    st.sheet(side, MOON, lift=1.0, edge=0.12)
    st.sheet(mirror(arches(CX + 20 * k, CX + 36 * k, base - 22 * k, 22 * k, 2, .5)), MOON_DEEP, lift=0, edge=0, wash=0)
    body = unary_union([box(CX - 22 * k, base - 46 * k, CX + 22 * k, base + 4), dome(*at(0, 46), 21 * k)])
    st.sheet(body, MOON, lift=1.6, edge=0.14)
    # Shade on the far half of the dome, and the drum's windows and the portal.
    st.sheet(dome(*at(0, 46), 21 * k).intersection(box(CX + 6 * k, 0, CX + 40 * k, base)),
             MOON_SHADE, lift=0, edge=0, opacity=.8)
    st.sheet(arches(CX - 18 * k, CX + 18 * k, base - 42 * k, 7 * k, 5, .5), MOON_DEEP, lift=0, edge=0, wash=0)
    st.sheet(arches(CX - 9 * k, CX + 9 * k, base - 28 * k, 32 * k, 1, .9).buffer(1.2 * k), MOON_SHADE, lift=0.4, edge=0.1)
    st.sheet(arches(CX - 9 * k, CX + 9 * k, base - 28 * k, 32 * k, 1, .9), '#c2beb7', lift=0, edge=0.04, wash=0)


# --------------------------------------------------------------- Windows
# Each tab's window, after the references: an onion arch, wider and fuller
# shouldered for Athkar, rounder for Qibla.
WINDOWS = {
    'quran': ogee(64, 118, 24, bulge=.1),
    'prayers': ogee(68, 112, 22, bulge=.13),
    'athkar': ogee(70, 106, 24, bulge=.16, neck=.38),
    'qibla': ogee(68, 116, 26, bulge=.06, neck=.55),
}


def clouds_in(st, t, hole, y):
    """A bank of clouds along a window's foot, so the sky ends in cloud."""
    c = t['cloud']
    st.sheet(unary_union([cloud(CX - 40, y + 8, 62, 15, 1), cloud(CX + 38, y + 6, 66, 16, 2)]),
             c[2], lift=0.8, theme=t, edge=t['edge'])
    st.sheet(unary_union([cloud(CX - 52, y + 22, 70, 18, 3), cloud(CX + 6, y + 26, 84, 20, 4),
                          cloud(CX + 60, y + 22, 64, 16, 5)]), c[1], lift=1.2, theme=t, edge=t['edge'])


def draw_quran(st, t):
    mosque(st, 172, .78)
    clouds_in(st, t, WINDOWS['quran'], 172)


def draw_quran_front(st, t):
    # The rehal: two crossed slats, the far one in shade.
    st.sheet(Polygon([(CX - 40, 150), (CX - 30, 150), (CX + 36, 214), (CX + 25, 214)]), WOOD_DEEP, lift=1.6, edge=0.08)
    st.sheet(Polygon([(CX + 40, 150), (CX + 30, 150), (CX - 36, 214), (CX - 25, 214)]), WOOD, lift=1.8, edge=0.14)

    def page(side, inset=0.0, drop=0.0):
        """An open page lying back on the rehal, its top edge curling up."""
        pts = [(CX + side * 1, 150 + drop)]
        for i in range(1, 25):
            u = i / 24
            pts.append((CX + side * (1 + (54 - inset) * u), 150 + drop - 11 * math.sin(u * math.pi * .7) + 7 * u))
        pts += [(CX + side * (56 - inset), 178 + drop), (CX + side * 1, 171 + drop)]
        return Polygon(pts)

    st.sheet(mirror(page(1).buffer(2.2)), WOOD_DEEP, lift=2.2, edge=0.12, wash=0)
    st.sheet(mirror(page(1, 0, 1.6)), MOON_DEEP, lift=0.4, edge=0.06)
    st.sheet(mirror(page(1, .8)), MOON, lift=0.6, edge=0.12)
    # An illuminated opening: a gold frame and star, never false text.
    rule = page(1, .8).buffer(-3.4).difference(page(1, .8).buffer(-4.3))
    st.sheet(mirror(rule), GOLD, lift=0, edge=0, wash=0)
    st.sheet(mirror(star8(CX + 28, 160, 7.4).difference(star8(CX + 28, 160, 4.6))), GOLD, lift=0.2, edge=0.08, wash=0)
    st.sheet(mirror(star8(CX + 28, 160, 2.6)), GOLD_DEEP, lift=0, edge=0, wash=0)
    st.sheet(box(CX - 1, 148, CX + 1, 172), MOON_DEEP, lift=0, edge=0, wash=0)


def draw_prayers(st, t):
    mosque(st, 190, .95)
    clouds_in(st, t, WINDOWS['prayers'], 190)


def draw_athkar(st, t):
    mosque(st, 178, .9)
    clouds_in(st, t, WINDOWS['athkar'], 180)


def draw_athkar_front(st, t):
    # A misbaha thrown across the window's foot, its tassel hanging out of it.
    path = LineString(bezier((CX - 58, 196), (CX - 30, 150), (CX + 30, 138), (CX + 48, 166), 40)
                      + bezier((CX + 48, 166), (CX + 60, 190), (CX + 6, 206), (CX - 58, 196), 40)[1:])
    beads = [path.interpolate(i / 34, normalized=True) for i in range(34)]
    st.sheet(unary_union([circle(p.x, p.y, 4.3) for p in beads]), AMBER, lift=1.5, edge=0.2, wash=0.06)
    st.sheet(unary_union([circle(p.x - 1.3, p.y - 1.4, 1.5) for p in beads]), '#f6c46f', lift=0, edge=0, wash=0)
    # The imam bead and the tassel.
    x, y = CX + 52, 172
    strips = [Polygon([(x + dx - .8, y + 8), (x + dx + .8, y + 8), (x + dx * 1.8 + .8, y + 40), (x + dx * 1.8 - .8, y + 40)])
              for dx in (-3, -1, 1, 3)]
    st.sheet(unary_union(strips), AMBER_DEEP, lift=1.0, edge=0.1)
    st.sheet(box(x - 3, y + 4, x + 3, y + 10), GOLD, lift=0.5, edge=0.14)
    st.sheet(circle(x, y + 1, 4.4), AMBER, lift=1.2, edge=0.2, wash=0)


def draw_qibla(st, t):
    mosque(st, 156, .95, far=False, hall=False)
    # Arcades either side of the Kaaba, two storeys of pointed arches.
    for y, op, tone in ((150, 22, MOON_SHADE), (166, 18, MOON)):
        wall = box(CX - 76, y, CX + 76, 240)
        cuts = unary_union([arches(CX - 76, CX - 34, y + 4, op - 6, 3), arches(CX + 34, CX + 76, y + 4, op - 6, 3)])
        st.sheet(wall.difference(cuts), tone, lift=1.0, edge=0.1)

    # The Kaaba, seen a little from the left, so one side shows.
    top_l, top_m, top_r = (CX - 40, 122), (CX - 26, 117), (CX + 38, 121)
    foot_l, foot_m, foot_r = (CX - 40, 192), (CX - 26, 199), (CX + 38, 194)
    side = Polygon([top_l, top_m, foot_m, foot_l])
    front = Polygon([top_m, top_r, foot_r, foot_m])
    st.sheet(unary_union([side, front]), KAABA, lift=2.8, edge=0.06, wash=0)
    st.sheet(side, KAABA_SIDE, lift=0, edge=0.04, wash=0)

    def on(face, u, v):
        (a, b), (c, d) = face
        ty = a[1] + (b[1] - a[1]) * u
        by = c[1] + (d[1] - c[1]) * u
        return (a[0] + (b[0] - a[0]) * u, ty + (by - ty) * v)

    faces = (((top_m, top_r), (foot_m, foot_r)), ((top_l, top_m), (foot_l, foot_m)))
    # The gold band: a lattice, not writing, so nothing reads as false text.
    st.sheet(unary_union([Polygon([on(f, 0, .17), on(f, 1, .17), on(f, 1, .3), on(f, 0, .3)]) for f in faces]),
             GOLD, lift=0.3, edge=0.14, wash=0)
    cuts = []
    for f, n in ((faces[0], 14), (faces[1], 3)):
        for i in range(n):
            x, y = on(f, (i + .5) / n, .235)
            cuts.append(Polygon([(x, y - 1.4), (x + 1, y), (x, y + 1.4), (x - 1, y)]))
    st.sheet(unary_union(cuts), GOLD_DEEP, lift=0, edge=0, wash=0)
    door = Polygon([on(faces[0], .62, .44), on(faces[0], .86, .44), on(faces[0], .86, .84), on(faces[0], .62, .84)])
    st.sheet(door, GOLD, lift=0.5, edge=0.14, wash=0)
    st.sheet(door.buffer(-1.2), GOLD_DEEP, lift=0, edge=0.05, wash=0)
    x, y = door.centroid.coords[0]
    st.sheet(star8(x, y, 2.6), GOLD, lift=0.2, edge=0.1, wash=0)
    clouds_in(st, t, WINDOWS['qibla'], 196)


TABS = {
    'prayers': (draw_prayers, None),
    'quran': (draw_quran, draw_quran_front),
    'athkar': (draw_athkar, draw_athkar_front),
    'qibla': (draw_qibla, None),
}


def frame(name, theme_name, out):
    hole = WINDOWS[name]
    back, front = TABS[name]
    t = THEMES[theme_name]
    st = Stack(FRAME)
    back(st, t)
    rims = t['rims']
    whole = box(0, 0, 500, 240)
    # Back to front: each deeper sheet's window is smaller, so each edge shadows
    # the sheet below it, all the way down to the sky.
    st.sheet(whole.difference(hole.buffer(-7.5)), rims[3], lift=1.2, theme=t, edge=t['edge'])
    st.sheet(whole.difference(hole.buffer(-5.0)), rims[2], lift=1.4, theme=t, edge=t['edge'])
    st.sheet(whole.difference(hole.buffer(-2.5)), rims[1], lift=1.6, theme=t, edge=t['edge'])
    # The page, cut under the front sheets so its edge never shows.
    st.sheet(whole.difference(hole.buffer(3.0)), t['page'], lift=0, theme=t, edge=0, wash=0)
    # A cut-out cloud behind each shoulder, the way the references frame the arch.
    b = hole.bounds
    # Tucked in: the title column ends at x = 195 on every phone, so they must not
    # reach far past the rim.
    puffs = mirror(unary_union([circle(b[2] + 2, 94, 11), circle(b[2] + 8, 110, 9), circle(b[2] + 3, 124, 11),
                                circle(b[2] + 8, 138, 9)]))
    st.sheet(puffs.difference(hole), rims[1], lift=1.0, theme=t, edge=t['edge'], wash=0.03)
    # The arch's face, three sheets stepping in, the back one with a finial.
    finial = Polygon([(CX - 3.4, b[1] - 9), (CX, b[1] - 18), (CX + 3.4, b[1] - 9)]).union(circle(CX, b[1] - 11, 2.8))
    st.sheet(hole.buffer(13).union(finial).difference(hole.buffer(8)), rims[1], lift=2.6, theme=t, edge=t['edge'], wash=0.03)
    st.sheet(hole.buffer(8.5).difference(hole.buffer(4)), rims[0], lift=2.0, theme=t, edge=t['edge'], wash=0.03)
    st.sheet(hole.buffer(4.5).difference(hole), rims[0], lift=1.4, theme=t, edge=t['edge'], wash=0.03)
    if front:
        front(st, t)
    # Clouds gathering at the arch's foot, in front of everything.
    c = t['cloud']
    st.sheet(mirror(unary_union([cloud(CX + 70, 214, 56, 16, 7), cloud(CX + 96, 222, 44, 13, 8)])),
             c[1], lift=1.2, theme=t, edge=t['edge'])
    return st.save(f'{out}/hero_{name}_{theme_name}.webp')


def strip(theme_name, out):
    """The cloud bank along the band's foot: a tile, its foot the page exactly."""
    t = THEMES[theme_name]
    st = Stack(CLOUDS, wrap=True)
    c = t['cloud']
    W = CLOUDS[2]
    off = 18  # Puts the seam inside a puff: a cloud's side there would read as a seam.
    far = [((x + off) % W, y, w, h) for x, y, w, h in
           [(20, 214, 70, 15), (110, 210, 84, 17), (205, 216, 64, 14), (290, 211, 86, 17), (372, 215, 60, 14)]]
    near = [((x + off) % W, y, w, h) for x, y, w, h in
            [(60, 230, 96, 14), (160, 233, 90, 12), (250, 231, 100, 15), (345, 234, 92, 12)]]
    st.sheet(unary_union([cloud(x, y, w, h, i) for i, (x, y, w, h) in enumerate(far)]),
             c[2], lift=1.0, theme=t, edge=t['edge'])
    st.sheet(unary_union([cloud(x, y, w, h, i + 10) for i, (x, y, w, h) in enumerate(near)]),
             c[0], lift=1.4, theme=t, edge=t['edge'])
    st.fade(t['page'], 224, 239)
    assert W * PX % 4 == 0
    # Lossless: the foot has to be the page's exact colour, or a seam shows.
    img = st.save(f'{out}/hero_clouds_{theme_name}.webp')
    # The tile's two ends meet: art_assets_test checks the same.
    px = np.asarray(img).astype(int)
    assert np.abs(px[:, 0] - px[:, -1]).max() <= 40, 'the cloud tile shows a seam'
    return img


# ------------------------------------------------------------------------ Sky
# A smooth wash from the top to the horizon, from the references, and the sun
# or moon. Every sun's centre must land inside every tab's window: check_skies.
SKIES = {
    'fajr': dict(stops=[(0, '#a9b6d6'), (.42, '#d3c3cf'), (.72, '#f1cba7'), (1, '#f7bf79')],
                 sun=(CX, 156, 15, '#fff2d2'), glow=.75, cloud='#f5ddd0', birds='#6f6a78'),
    'dhuhr': dict(stops=[(0, '#79b2e4'), (.55, '#a9d0ef'), (1, '#d9eaf6')],
                  sun=(CX + 14, 74, 11, '#fbf1c4'), glow=.5, cloud='#f4f9fd', birds='#4d6179'),
    'asr': dict(stops=[(0, '#f0cf9b'), (.5, '#f3b46d'), (1, '#ee9f52')],
                sun=(CX + 20, 82, 12, '#fdf0c8'), glow=.55, cloud='#f8d3a2', birds='#7a5a3e'),
    'maghrib': dict(stops=[(0, '#6a4257'), (.4, '#9c5650'), (.75, '#d9834b'), (1, '#f1a456')],
                    sun=(CX, 160, 15, '#ffd98c'), glow=.8, cloud='#8a4c5a', birds='#4a2b38', hills=True),
    'isha': dict(stops=[(0, '#131c2d'), (.6, '#222f47'), (1, '#36455f')],
                 sun=(CX + 12, 88, 13, '#f5f1e4'), glow=.25, cloud='#3a4862', birds=None),
}


def birds(st, color, at):
    for x, y, s in at:
        v = LineString([(x - s, y - s * .5), (x - s * .3, y - s * .2), (x, y), (x + s * .3, y - s * .2), (x + s, y - s * .5)])
        st.sheet(v.buffer(.38), color, lift=0, edge=0, wash=0, opacity=.7)


def sky(name, out):
    d = SKIES[name]
    st = Stack(SKY)
    st.gradient(d['stops'])
    sx, sy, sr, sc = d['sun']
    st.glow(sx, sy, sr * 4.2, sc, d['glow'])
    if name == 'isha':
        st.sheet(crescent(sx, sy, sr), sc, lift=0.5, edge=0.06, wash=0)
    else:
        st.sheet(circle(sx, sy, sr), sc, lift=0, edge=0.04, wash=0)
    if d.get('hills'):
        st.sheet(unary_union([circle(CX - 50, 196, 34), circle(CX + 46, 200, 38)]), '#7a4656', lift=0.6, edge=0.04, wash=0)
        st.sheet(unary_union([circle(CX - 10, 210, 40), circle(CX + 70, 206, 30)]), '#5e3747', lift=0.6, edge=0.04, wash=0)
    # Soft paper clouds drifting high in the window.
    st.sheet(unary_union([cloud(CX - 34, 104, 34, 7, 20), cloud(CX + 44, 120, 30, 6, 21)]),
             d['cloud'], lift=0.4, edge=0.05, wash=0, opacity=.85)
    if d['birds']:
        birds(st, d['birds'], [(CX - 28, 70, 3.2), (CX - 18, 78, 2.4), (CX + 34, 100, 2.6)])
    return st.save(f'{out}/sky_{name}.webp', lossless=False)


# The painted stars of Isha, in NoorHero's noorHeroStars: keep the two in step.
STARS = [(262, 74, 2.6), (306, 62, 2.2), (252, 108, 2.2), (332, 122, 2.0),
         (287, 50, 2.0), (244, 140, 2.2), (316, 146, 1.8)]


def check_skies():
    """The one shared sky: every sun or moon shows in every window."""
    windows = {n: h.buffer(-7.5) for n, h in WINDOWS.items()}
    bounds = box(SKY[0], SKY[1], SKY[0] + SKY[2], SKY[1] + SKY[3])
    for n, w in windows.items():
        assert bounds.contains(w.intersection(box(0, 0, 400, SKY[1] + SKY[3]))), f'{n} window outruns the sky'
    for name, d in SKIES.items():
        sx, sy, _, _ = d['sun']
        for n, w in windows.items():
            assert w.contains(Point(sx, sy)), f'{name} sun leaves the {n} window'
    for x, y, r in STARS:
        assert windows['prayers'].contains(circle(x, y, r)), f'star {x},{y} leaves the prayers window'


if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else 'assets/images/art'
    if sys.argv[2:] == ['clouds']:
        for theme in THEMES:
            strip(theme, out)
        sys.exit()
    tabs = sys.argv[2:] or list(TABS)
    check_skies()
    for name in SKIES:
        sky(name, out)
    for theme in THEMES:
        strip(theme, out)
    for tab in tabs:
        for theme in THEMES:
            frame(tab, theme, out)
