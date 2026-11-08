"""Bakes the NoorHero paper-cut art into assets/images/art/.

    python tool/hero_art.py [out_dir] [tab ...]

flutter_svg has no blur and a live blur on every tab janks, so each stack of cut
paper is rendered here once: real soft shadows and lit paper edges, in the app's
exact paper colours, composited with the high-resolution illustrated assets
(masjid.png, quran.png, tasbih.png, kaaba.png). Needs numpy, scipy, shapely and
Pillow; the app needs none.

Everything is in the hero's 390 x 240 art space. A frame is opaque paper around
a see-through ogee window, so the sky drawn under it needs no clipping at
runtime. The cloud strip runs across the band's foot, under the frame's
foreground, and tiles. The look follows the owner's references,
assets/day_states.png, assets/screen_bg.png and assets/preview.png.
"""
import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw
from scipy.ndimage import gaussian_filter
from shapely import affinity
from shapely.geometry import LineString, Point, Polygon, box
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

ART_DIR = 'assets/images/art'


def rgb(h):
    return np.array([int(h[i:i + 2], 16) for i in (1, 3, 5)], dtype=np.float32) / 255


# Must match NoorColors.light.paper / dark.paper, or a seam shows: art_assets_test.
THEMES = {
    'paper': dict(page='#eef0f4', rims=['#ffffff', '#f8f9fb', '#eceef3', '#dfe3ec'],
                  cloud=['#ffffff', '#f6f7fa', '#e9ecf2'],
                  shadow='#252934', shadow_k=1.0, edge=0.09),
    'night': dict(page='#101217', rims=['#2b303b', '#222630', '#191c24', '#0e1015'],
                  cloud=['#2b303b', '#22262f', '#191c23'],
                  shadow='#000000', shadow_k=1.75, edge=0.16),
}
MOON = '#fbfaf7'
MOON_SHADE = '#eae7e1'
MOON_DEEP = '#d5d1c8'
GOLD = '#c9a24e'


def blur(m, sigma, wrap=False):
    """Gaussian blur; a wide one runs on a smaller copy, which looks the same."""
    if wrap:
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


_ASSET_CACHE = {}


def load_rgba_cropped(filename, rotate_deg=0.0, sub_box=None):
    """Loads an RGBA PNG from assets/images/art, strips cutout alpha haze,
    optionally crops a normalized sub_box (u0, v0, u1, v1) or rotates it, and
    crops to its non-empty bounding box."""
    key = (filename, rotate_deg, sub_box)
    if key in _ASSET_CACHE:
        return _ASSET_CACHE[key]
    path = os.path.join(ART_DIR, filename)
    im = Image.open(path).convert('RGBA')
    if sub_box is not None:
        w, h = im.size
        im = im.crop((int(sub_box[0] * w), int(sub_box[1] * h),
                      int(sub_box[2] * w), int(sub_box[3] * h)))
    if rotate_deg != 0.0:
        im = im.rotate(rotate_deg, resample=Image.BICUBIC, expand=True)
    arr = np.asarray(im, dtype=np.float32) / 255.0
    # Clean faint background matting haze so the sky behind is 100% clean
    arr[..., 3] = np.clip((arr[..., 3] - 0.18) / 0.75, 0.0, 1.0)
    ys, xs = np.where(arr[..., 3] > 0.05)
    arr = arr[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    _ASSET_CACHE[key] = arr
    return arr


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
        shifted[:max(int(dy * s), 0)] = 0
        if not self.wrap:
            if dx > 0:
                shifted[:, :int(dx * s)] = 0
            elif dx < 0:
                shifted[:, int(dx * s):] = 0
        self._over(rgb(color), blur(shifted, sigma * s, self.wrap) * opacity)

    def sheet(self, geom, face, lift=1.0, theme=None, edge=0.12, wash=0.05, opacity=1.0, clip=None):
        """One sheet of paper: its cast shadow, then its lit face."""
        t = theme or THEMES['paper']
        m = self.mask(geom)
        if clip is not None:
            m = m * self.mask(clip)
        if lift > 0:
            sc, k = t['shadow'], t['shadow_k']
            self.shadow(m, 0.1 * lift, 0.6 * lift, 0.5 * lift, min(0.32 * k, 0.8), sc)
            self.shadow(m, 0.3 * lift, 2.2 * lift, 2.6 * lift, min(0.26 * k, 0.7), sc)
        c = rgb(face) if isinstance(face, str) else face
        col = np.broadcast_to(c, (self.H, self.W, 3)).astype(np.float32).copy()
        gy, gx = np.gradient(blur(m, 0.35 * self.s, self.wrap))
        lit = (gx * 0.35 + gy * 0.94) * self.s * 0.9
        col = col + (np.clip(lit, -1, 1) * edge)[..., None]
        if wash:
            ramp = np.linspace(1 + wash / 2, 1 - wash / 2, self.H, dtype=np.float32)
            col = col * ramp[:, None, None]
        self._over(np.clip(col, 0, 1), m * opacity)

    def sprite(self, filename, cx, cy, w=None, h=None, lift=1.5, theme=None,
               clip=None, opacity=1.0, rotate_deg=0.0, sub_box=None,
               wash_color=None, wash_amt=0.0):
        """Composites a high-resolution RGBA PNG asset centered at (cx, cy) in
        art space, with premultiplied Lanczos resampling and a soft drop shadow."""
        t = theme or THEMES['paper']
        src = load_rgba_cropped(filename, rotate_deg=rotate_deg, sub_box=sub_box)
        sh, sw = src.shape[:2]
        if w is None and h is None:
            raise ValueError('Specify w or h')
        if w is None:
            w = h * (sw / sh)
        elif h is None:
            h = w * (sh / sw)

        pw = max(1, int(round(w * self.s)))
        ph = max(1, int(round(h * self.s)))

        pre = src.copy()
        pre[..., :3] *= pre[..., 3:]
        resized = np.dstack([
            np.asarray(
                Image.fromarray(pre[..., c].astype(np.float32), 'F').resize((pw, ph), Image.LANCZOS),
                dtype=np.float32,
            )
            for c in range(4)
        ])
        al = np.clip(resized[..., 3], 0.0, 1.0)
        col = np.divide(
            resized[..., :3],
            al[..., None],
            out=np.zeros_like(resized[..., :3]),
            where=al[..., None] > 1e-4,
        )
        col = np.clip(col, 0.0, 1.0)
        if wash_color is not None and wash_amt > 0:
            wc = rgb(wash_color)
            col = col * (1.0 - wash_amt) + wc * wash_amt

        x_left = int(round((cx - w / 2 - self.x0) * self.s))
        y_top = int(round((cy - h / 2 - self.y0) * self.s))

        sx0 = max(0, -x_left)
        sy0 = max(0, -y_top)
        dx0 = max(0, x_left)
        dy0 = max(0, y_top)
        copy_w = min(pw - sx0, self.W - dx0)
        copy_h = min(ph - sy0, self.H - dy0)
        if copy_w <= 0 or copy_h <= 0:
            return

        canvas_rgb = np.zeros((self.H, self.W, 3), dtype=np.float32)
        canvas_a = np.zeros((self.H, self.W), dtype=np.float32)
        canvas_rgb[dy0:dy0 + copy_h, dx0:dx0 + copy_w] = col[sy0:sy0 + copy_h, sx0:sx0 + copy_w]
        canvas_a[dy0:dy0 + copy_h, dx0:dx0 + copy_w] = al[sy0:sy0 + copy_h, sx0:sx0 + copy_w]

        if clip is not None:
            canvas_a *= self.mask(clip)

        if lift > 0:
            sc, k = t['shadow'], t['shadow_k']
            self.shadow(canvas_a, 0.1 * lift, 0.7 * lift, 0.6 * lift, min(0.28 * k, 0.72), sc)
            self.shadow(canvas_a, 0.3 * lift, 2.2 * lift, 2.6 * lift, min(0.22 * k, 0.62), sc)

        self._over(canvas_rgb, canvas_a * opacity)

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

    def fade(self, color, y0, y1, mask_by_alpha=False):
        """[color] coming in from nothing at y0 to solid at y1 and below."""
        y = self.y0 + (np.arange(self.H, dtype=np.float32) + .5) / self.s
        a = np.clip((y - y0) / (y1 - y0), 0, 1) ** 1.5
        alpha = np.broadcast_to(a[:, None], (self.H, self.W)).copy()
        if mask_by_alpha:
            alpha *= self.a
        self._over(rgb(color), alpha)

    def save(self, path, lossless=True, crop=None):
        s = SS
        h, w = self.H // s, self.W // s
        down = lambda a: a[:h * s, :w * s].reshape(h, s, w, s, *a.shape[2:]).mean((1, 3))
        al = np.clip(down(self.a), 0, 1)
        col = np.clip(down(self.rgb), 0, 1)
        straight = np.divide(col, al[..., None], out=np.zeros_like(col), where=al[..., None] > 1e-4)
        out = np.dstack([straight, al]) * 255
        out = np.round(np.clip(out, 0, 255)).astype(np.uint8)
        out[out[..., 3] == 0, :3] = 0
        img = Image.fromarray(out, 'RGBA')
        if crop:
            img = img.crop((crop[0] * PX, 0, crop[1] * PX, img.height))
        if lossless:
            img.save(path, 'WEBP', lossless=True, quality=100, method=6, exact=False)
        else:
            img.convert('RGB').save(path, 'WEBP', quality=90, method=6)
        return img


def mirror(g, cx=CX):
    return unary_union([g, affinity.scale(g, -1, 1, origin=(cx, 0))])


def circle(x, y, r):
    return Point(x, y).buffer(r, 64)


def ellipse(x, y, rx, ry):
    return affinity.scale(Point(x, y).buffer(1.0, 64), rx, ry, origin=(x, y))


def crescent(x, y, r):
    return circle(x, y, r).difference(circle(x + r * .44, y - r * .22, r * .82))


def bezier(p0, p1, p2, p3, n=40):
    out = []
    for i in range(n + 1):
        t = i / n
        a, b, c, d = (1 - t) ** 3, 3 * t * (1 - t) ** 2, 3 * t * t * (1 - t), t ** 3
        out.append((a * p0[0] + b * p1[0] + c * p2[0] + d * p3[0],
                    a * p0[1] + b * p1[1] + c * p2[1] + d * p3[1]))
    return out


def ogee(half, spring, apex, bulge=0.11, neck=0.40, foot=240):
    """An onion arch: a pointed tip that flares, swells past the sides at the
    shoulder, then drops on straight sides to the foot."""
    h = spring - apex
    m = (0.54 * half, apex + neck * h)
    right = bezier((0, apex), (0.03 * half, apex + 0.22 * neck * h),
                   (0.20 * half, apex + 0.74 * neck * h), m)
    right += bezier(m, (0.94 * half, apex + 1.18 * neck * h),
                    ((1 + 2.1 * bulge) * half, spring - 0.42 * h), (half, spring))[1:]
    right = [(CX + x, y) for x, y in right]
    left = [(2 * CX - x, y) for x, y in reversed(right)]
    return Polygon(left[:-1] + right + [(CX + half, foot), (CX - half, foot)])


def cusped_ogee(half, spring, apex, foot=240):
    """The cusped/lobed arch for Athkar (as in preview.png and screen_bg.png):
    a pointed ogee upper dome that steps into a rounded shoulder lobe before
    dropping straight to the foot."""
    c1 = (0.58 * half, apex + 0.42 * (spring - apex))
    seg1 = bezier((0, apex), (0.05 * half, apex + 10), (0.36 * half, apex + 16), c1, 28)
    seg2 = bezier(c1, (0.86 * half, c1[1] + 4), (1.03 * half, spring - 22), (half, spring), 28)[1:]
    right = [(CX + x, y) for x, y in seg1 + seg2]
    left = [(2 * CX - x, y) for x, y in reversed(right)]
    return Polygon(left[:-1] + right + [(CX + half, foot), (CX - half, foot)])


def sky_cloud(x, y, w, h):
    """A soft flat-bottomed cloud for the sky."""
    base_y = y + h * 0.35
    puffs = [
        ellipse(x, base_y, w * 0.48, h * 0.32),
        circle(x - w * 0.26, y + h * 0.08, h * 0.36),
        circle(x - w * 0.04, y - h * 0.12, h * 0.48),
        circle(x + w * 0.22, y + h * 0.04, h * 0.38),
    ]
    return unary_union(puffs).intersection(box(x - w, y - h, x + w, base_y + h * 0.15))


def sculpted_cloud_bank(lobes, foot=240, full_width=False):
    """Builds a smooth, broad paper-cut cloud bank from a list of (x, y, r)
    domes, connected across the base down to [foot]."""
    shapes = []
    xs = [x for x, _, _ in lobes]
    ys = [y for _, y, _ in lobes]
    for x, y, r in lobes:
        shapes.append(circle(x, y, r))
    if full_width:
        shapes.append(box(-40, max(ys), 440, foot))
    elif len(lobes) >= 2:
        shapes.append(box(min(xs), max(ys), max(xs), foot))
    return unary_union(shapes)


def flat_cloud_puff(cx, base_y, w, h, side=1):
    """Small flat-bottomed paper cloud puff sitting on the arch shoulder, as in
    proto.jpg."""
    d = side
    r_end = h * 0.22
    base_capsule = LineString([
        (cx - w * 0.38, base_y - r_end),
        (cx + w * 0.38, base_y - r_end),
    ]).buffer(r_end, 32)
    puffs = [
        base_capsule,
        circle(cx - d * w * 0.26, base_y - h * 0.24, h * 0.24),
        circle(cx - d * w * 0.08, base_y - h * 0.44, h * 0.44),
        circle(cx + d * w * 0.16, base_y - h * 0.33, h * 0.33),
        circle(cx + d * w * 0.30, base_y - h * 0.20, h * 0.20),
    ]
    return unary_union(puffs).intersection(box(cx - w, base_y - h * 1.4, cx + w, base_y))


def wave_ribbon(p0, p1, p2, p3, p4, p5, p6, rim_w=4.2, foot=240):
    """Builds a sleek paper-cut wave from two connected cubic Bezier segments
    (p0..p3 rising to the crest, p3..p6 descending), returning (body_poly, rim_poly)
    where rim_poly is the sculpted ribbon lip along the top curve."""
    seg1 = bezier(p0, p1, p2, p3, 36)
    seg2 = bezier(p3, p4, p5, p6, 36)[1:]
    top = seg1 + seg2
    n = len(top) - 1
    bot_rim = []
    for i in range(n, -1, -1):
        u = i / n
        x, y = top[i]
        w = rim_w * (math.sin(math.pi * u) ** 0.55)
        bot_rim.append((x, y + w))
    rim_poly = Polygon(top + bot_rim)
    body_poly = Polygon(top + [(p6[0], foot), (p0[0], foot)])
    return body_poly, rim_poly


def draw_wave_clouds(st, t):
    """Draws the single layer of sleek, ribbon-rimmed wave clouds at the foot
    of the arch (as in proto.jpg), tapering down toward the separator."""
    c = t['cloud']
    # Left sweeping wave tapering down toward the centre separator
    fl_body, fl_rim = wave_ribbon(
        (CX - 118, 236), (CX - 94, 230), (CX - 70, 193), (CX - 42, 193),
        (CX - 18, 193), (CX - 1, 212), (CX + 22, 235),
        rim_w=5.2,
    )
    st.sheet(fl_body, c[1], lift=1.5, theme=t, edge=t['edge'], wash=0.02)
    st.sheet(fl_rim, c[0], lift=1.4, theme=t, edge=t['edge'] * 1.1, wash=0.01)

    # Right sweeping wave overlapping at the centre-right
    fr_body, fr_rim = wave_ribbon(
        (CX - 18, 235), (CX + 6, 212), (CX + 28, 190), (CX + 54, 190),
        (CX + 78, 190), (CX + 98, 210), (CX + 118, 236),
        rim_w=5.2,
    )
    st.sheet(fr_body, c[1], lift=1.6, theme=t, edge=t['edge'], wash=0.02)
    st.sheet(fr_rim, c[0], lift=1.4, theme=t, edge=t['edge'] * 1.1, wash=0.01)


def draw_shoulder_clouds(st, t):
    """Draws the two signature flat-bottomed paper clouds on the left and right
    shoulders of the arch (as in proto.jpg)."""
    c = t['cloud']
    left_puff = flat_cloud_puff(CX - 67, 114, 40, 15, side=1)
    right_puff = flat_cloud_puff(CX + 67, 111, 44, 17, side=-1)
    st.sheet(unary_union([left_puff, right_puff]), c[0], lift=1.8, theme=t, edge=t['edge'])


def arches(x0, x1, y, h, n, w_frac=0.62):
    """A row of pointed openings to cut out of a wall."""
    step = (x1 - x0) / n
    w = step * w_frac
    out = []
    for i in range(n):
        cx = x0 + step * (i + .5)
        top = y + w * .75
        out.append(Polygon([
            (cx - w / 2, y + h), (cx - w / 2, top),
            (cx - w * .28, y + w * .22), (cx, y),
            (cx + w * .28, y + w * .22), (cx + w / 2, top),
            (cx + w / 2, y + h),
        ]))
    return unary_union(out)


# --------------------------------------------------------------- Windows
WINDOWS = {
    'quran': ogee(65, 114, 24, bulge=.10, neck=.40),
    'prayers': ogee(66, 114, 23, bulge=.11, neck=.40),
    'athkar': cusped_ogee(68, 110, 24),
    'qibla': ogee(67, 114, 24, bulge=.09, neck=.44),
}


def outer_arch_shape(name, dr, d_apex):
    """Smooth continuous outer arch ring that rises to a tall pointed finial
    spire at the apex without any rectangular step."""
    if name == 'athkar':
        return cusped_ogee(68 + dr, 110 + dr * 0.15, 24 - d_apex)
    params = {
        'quran': (65, 114, 24, .10, .40),
        'prayers': (66, 114, 23, .11, .40),
        'qibla': (67, 114, 24, .09, .44),
    }[name]
    half, spring, apex, bulge, neck = params
    return ogee(half + dr, spring + dr * 0.15, apex - d_apex, bulge=bulge, neck=neck * 0.96)


def draw_quran(st, t):
    hole = WINDOWS['quran']
    # Grand mosque inside the window, softly atmospheric behind the Quran stand
    st.sprite('masjid.png', CX, 142, w=174, lift=0.8, theme=t, clip=hole,
              wash_color='#f3dfd0', wash_amt=0.16)


def draw_quran_front(st, t):
    # Open Quran on its carved wooden rehal stand resting in front of the wave clouds
    st.sprite('quran.png', CX, 192, w=114, lift=2.2, theme=t)


def draw_prayers(st, t):
    hole = WINDOWS['prayers']
    # Grand white and gold mosque framed by the two tall main minarets
    st.sprite('masjid.png', CX, 144, w=178, lift=1.2, theme=t, clip=hole)


def draw_athkar(st, t):
    hole = WINDOWS['athkar']
    st.sprite('masjid.png', CX, 146, w=176, lift=1.2, theme=t, clip=hole)


def draw_athkar_front(st, t):
    # Amber misbaha / tasbih draped over the bottom-right wave cloud
    st.sprite('tasbih.png', CX + 18, 194, w=88, lift=2.0, theme=t, rotate_deg=-6.0)


def draw_qibla(st, t):
    hole = WINDOWS['qibla']
    # Flanking minarets from masjid.png on left and right of the courtyard
    minaret_crop = (0.13, 0.01, 0.27, 0.72)
    st.sprite('masjid.png', CX - 47, 134, w=23, lift=1.0, theme=t,
              clip=hole, sub_box=minaret_crop)
    st.sprite('masjid.png', CX + 47, 134, w=23, lift=1.0, theme=t,
              clip=hole, sub_box=minaret_crop)

    # Two-storey pointed-arch courtyard arcades flanking the Kaaba
    for y, op, tone, inner_tone in ((144, 22, MOON_SHADE, '#9a8e80'), (164, 24, MOON, '#7d7368')):
        wall = box(CX - 74, y, CX + 74, 220)
        cuts = unary_union([
            arches(CX - 68, CX - 30, y + 4, op - 5, 3, 0.64),
            arches(CX + 30, CX + 68, y + 4, op - 5, 3, 0.64),
        ])
        st.sheet(wall, inner_tone, lift=0, theme=t, edge=0, wash=0, clip=hole)
        st.sheet(wall.difference(cuts), tone, lift=1.0, theme=t, edge=0.10, clip=hole)

    # The Kaaba in the centre of the sanctuary
    st.sprite('kaaba.png', CX, 162, w=78, lift=2.4, theme=t, clip=hole)


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
    arch_ring = hole.buffer(12, join_style=2)
    whole = box(0, 0, 500, 240)

    # Back to front: recessed inner arch rims stepping down toward the sky
    st.sheet(arch_ring.difference(hole.buffer(-6.5, join_style=2)), rims[3], lift=1.2, theme=t, edge=t['edge'])
    st.sheet(arch_ring.difference(hole.buffer(-4.2, join_style=2)), rims[2], lift=1.4, theme=t, edge=t['edge'])
    st.sheet(arch_ring.difference(hole.buffer(-2.0, join_style=2)), rims[1], lift=1.6, theme=t, edge=t['edge'])

    # Clean flat page ground around the arch (no side pillar clouds)
    st.sheet(whole.difference(hole.buffer(3.5, join_style=2)), t['page'], lift=0, theme=t, edge=0, wash=0)

    # The sculpted outer arch frame rising smoothly into a pointed spire finial
    outer_arch = outer_arch_shape(name, 11.5, 13)
    mid_arch = outer_arch_shape(name, 7.2, 8)
    inner_arch = outer_arch_shape(name, 3.8, 3.5)

    st.sheet(outer_arch.difference(outer_arch_shape(name, 6.8, 7.5)), rims[1], lift=2.4, theme=t, edge=t['edge'], wash=0.03)
    st.sheet(mid_arch.difference(outer_arch_shape(name, 3.4, 3.0)), rims[0], lift=1.8, theme=t, edge=t['edge'], wash=0.02)
    st.sheet(inner_arch.difference(hole), rims[0], lift=1.3, theme=t, edge=t['edge'], wash=0.02)

    # The two signature flat-bottomed clouds on the arch shoulders (all 4 tabs)
    draw_shoulder_clouds(st, t)

    # Sleek, ribbon-rimmed wave clouds at the base of the arch (as in proto.jpg)
    draw_wave_clouds(st, t)

    # Fade the bottom of the wave clouds into the page colour BEFORE drawing
    # the foreground hero objects (Quran rehal, Athkar tasbih)
    st.fade(t['page'], 222, 235)

    if front:
        front(st, t)

    return st.save(f'{out}/hero_{name}_{theme_name}.webp')


def strip(theme_name, out):
    """The cloud bank along the band's foot: smooth overlapping paper domes that
    tile seamlessly and fade into the page colour at the bottom."""
    t = THEMES[theme_name]
    st = Stack(CLOUDS, wrap=True)
    c = t['cloud']
    # Keep all dome tops (y - r >= 184) well inside CLOUDS (y = 168..240) so
    # nothing is clipped at y = 168, and place a dome centre at x = 0 so the
    # horizontal tile boundary has zero slope.
    far_lobes = [
        (0, 222, 34), (64, 220, 34), (128, 224, 32),
        (194, 218, 36), (262, 221, 34), (328, 223, 32),
    ]
    mid_lobes = [
        (0, 228, 36), (62, 226, 36), (126, 229, 34),
        (192, 225, 38), (258, 227, 36), (326, 226, 36),
    ]
    near_lobes = [
        (0, 234, 38), (68, 233, 38), (136, 235, 36),
        (204, 232, 40), (274, 234, 38), (338, 235, 36),
    ]
    st.sheet(sculpted_cloud_bank(far_lobes, full_width=True), c[2], lift=1.0, theme=t, edge=t['edge'])
    st.sheet(sculpted_cloud_bank(mid_lobes, full_width=True), c[1], lift=1.2, theme=t, edge=t['edge'])
    st.sheet(sculpted_cloud_bank(near_lobes, full_width=True), c[0], lift=1.4, theme=t, edge=t['edge'])
    st.fade(t['page'], 226, 239)
    W = CLOUDS[2]
    assert W * PX % 4 == 0
    img = st.save(f'{out}/hero_clouds_{theme_name}.webp')
    px = np.asarray(img).astype(int)
    assert np.abs(px[:, 0] - px[:, -1]).max() <= 40, 'the cloud tile shows a seam'
    return img


# ------------------------------------------------------------------------ Sky
SKIES = {
    'fajr': dict(
        stops=[(0, '#a5b3ca'), (.38, '#d4c3c1'), (.70, '#f1cba5'), (1, '#f8dc97')],
        sun=(CX + 22, 86, 12.5, '#fff5d6'),
        glow=.70,
        horizon_glow=(CX, 148, 56, '#ffe6a3', .65),
        cloud='#f5dfd0',
        birds='#6b6268',
    ),
    'dhuhr': dict(
        stops=[(0, '#6aa5d6'), (.52, '#9ac6e7'), (1, '#d4e8f6')],
        sun=(CX + 8, 68, 12.0, '#fef3ca'),
        glow=.55,
        cloud='#edf6fc',
        birds='#4a6078',
    ),
    'asr': dict(
        stops=[(0, '#dc9e6b'), (.48, '#f1b66d'), (1, '#f8d28e')],
        sun=(CX + 22, 80, 12.5, '#fff5d4'),
        glow=.60,
        cloud='#f9d7a7',
        birds='#735338',
    ),
    'maghrib': dict(
        stops=[(0, '#6c424b'), (.38, '#a8594b'), (.74, '#df8246'), (1, '#f7b254')],
        sun=(CX + 10, 118, 14.5, '#ffdf91'),
        glow=.82,
        cloud='#8d5056',
        birds='#4a2b33',
        hills=True,
    ),
    'isha': dict(
        stops=[(0, '#0a1626'), (.55, '#122338'), (1, '#1d324b')],
        sun=(CX + 6, 68, 15.0, '#f7f5f0'),
        glow=.28,
        cloud='#243750',
        birds=None,
    ),
}


def birds(st, color, at):
    for x, y, s in at:
        v = LineString([
            (x - s, y - s * .48),
            (x - s * .32, y - s * .22),
            (x, y),
            (x + s * .32, y - s * .22),
            (x + s, y - s * .48),
        ])
        st.sheet(v.buffer(.38), color, lift=0, edge=0, wash=0, opacity=.72)


def sky(name, out):
    d = SKIES[name]
    st = Stack(SKY)
    st.gradient(d['stops'])
    if 'horizon_glow' in d:
        hx, hy, hr, hc, ho = d['horizon_glow']
        st.glow(hx, hy, hr, hc, ho)
    sx, sy, sr, sc = d['sun']
    st.glow(sx, sy, sr * 4.2, sc, d['glow'])
    if name == 'isha':
        st.sheet(crescent(sx, sy, sr), sc, lift=0.6, edge=0.08, wash=0)
    else:
        st.sheet(circle(sx, sy, sr), sc, lift=0, edge=0.04, wash=0)
    if d.get('hills'):
        st.sheet(unary_union([circle(CX - 48, 192, 36), circle(CX + 44, 196, 40)]),
                 '#75444e', lift=0.6, edge=0.04, wash=0)
        st.sheet(unary_union([circle(CX - 8, 204, 42), circle(CX + 68, 202, 32)]),
                 '#59333d', lift=0.6, edge=0.04, wash=0)
    # Soft flat-bottomed clouds drifting in the upper sky
    st.sheet(unary_union([sky_cloud(CX - 34, 98, 34, 10), sky_cloud(CX + 42, 112, 30, 9)]),
             d['cloud'], lift=0.4, edge=0.05, wash=0, opacity=.85)
    if d['birds']:
        birds(st, d['birds'], [(CX - 26, 68, 3.0), (CX - 16, 76, 2.3), (CX + 30, 96, 2.5)])
    return st.save(f'{out}/sky_{name}.webp', lossless=False)


# The painted stars of Isha, in NoorHero's noorHeroStars: keep the two in step.
STARS = [(262, 74, 2.6), (306, 62, 2.2), (252, 108, 2.2), (332, 122, 2.0),
         (287, 50, 2.0), (244, 140, 2.2), (316, 146, 1.8)]


def check_skies():
    """The one shared sky: every sun or moon shows in every window."""
    windows = {n: h.buffer(-6.5) for n, h in WINDOWS.items()}
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
    if not sys.argv[2:]:
        for name in SKIES:
            sky(name, out)
        for theme in THEMES:
            strip(theme, out)
    for tab in tabs:
        for theme in THEMES:
            frame(tab, theme, out)
