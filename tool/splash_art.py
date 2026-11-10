"""Bakes the Faith mark and the splash backdrops into assets/.

    python tool/splash_art.py [mask]

The mark. The owner's two logo renders (tool/sources/faith_logo_paper.jpg and
faith_logo_night.jpg) are app-icon tiles: the emblem sits on a rounded square
of clouds. The core is the emblem alone: the arch shield with its night window,
the bolt, the stars, the crescent and the two wings. The two renders share one
geometry, so a single cut-out serves both: the shield ring is found by
luminance in the night render (a hairline cap closes the gap under the
crescent, and the ring's fill is the window), the crescent by its brass colour,
and the wings are two hand-set outlines (they are charcoal on charcoal in the
night render, so no threshold finds them). The cut-out is eroded a pixel so no
tile colour rims the edge, and a soft depth shadow is baked under it, as the
other marks of the system have, in the theme's own shadow colour.

Writes assets/logo/faith-mark-{paper,night}.png at 1x, 2x and 3x (the 2.0x and
3.0x folders), plus the native splash and launcher icons the platform needs.
`mask` writes tmp_work/ previews of the cut-out instead.

The backdrops. tool/sources/splash_bg_{paper,night}.jpg are the generated
plates (the owner's splash.jpg with the foreground removed, and its night
twin). They are converted to WebP in assets/images/art/.

Needs numpy, scipy and Pillow; the app needs none.
"""
import os
import sys

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as ndi

SRC = {
    'paper': 'tool/sources/faith_logo_paper.jpg',
    'night': 'tool/sources/faith_logo_night.jpg',
}
S = 1254 / 1024  # The renders are 1254 px; the numbers below are read at 1024.

# Wing outlines, left wing, at 1024. Their top edges run inside the shield ring
# so the union has no seam; the right wing is the mirror about x = 512.
WING = [(201, 668), (236, 658), (330, 675), (430, 725), (500, 775), (512, 790),
        (512, 862), (500, 855), (460, 830), (400, 806), (300, 780), (240, 765),
        (210, 745), (201, 735)]

# Shadow and clear space, in the theme's own colours (NoorColors.depthShadow).
THEME = {
    'paper': dict(shadow=(23, 26, 33), alpha=0.30),
    'night': dict(shadow=(0, 0, 0), alpha=0.78),
}

# Artwork height at 1x. The 2x and 3x folders follow.
H1 = 220


def load(name):
    return np.asarray(Image.open(SRC[name]).convert('RGB')).astype(np.float32)


def crescent(name, n):
    """The brass crescent. The renders place it a little differently, so each
    is found in its own colours, inside a box around it."""
    d = load(name)
    r, b = d[..., 0], d[..., 2]
    # The paper tile's own warm glow sits near R-B 55, so its threshold is higher.
    gold = (r - b > (55 if name == 'night' else 85)) & (r > 140)
    box = np.zeros_like(gold)
    box[int(110 * S):int(265 * S), int(440 * S):int(600 * S)] = True
    gold = ndi.binary_closing(gold & box, iterations=3)
    lab, k = ndi.label(gold)
    sizes = ndi.sum(gold, lab, range(1, k + 1))
    return ndi.binary_fill_holes(lab == (np.argmax(sizes) + 1))


def cutout(name):
    """Alpha (0..1) of one render's emblem. The shield ring and wings come from
    the night render's geometry, the crescent from the render itself."""
    d = load('night')
    lum = d.mean(2)
    n = d.shape[0]

    ring = lum > 120
    lab, k = ndi.label(ring)
    sizes = ndi.sum(ring, lab, range(1, k + 1))
    ring = lab == (np.argmax(sizes) + 1)
    # The ring's two tips stop short of each other under the crescent: close
    # them with a hairline so the fill finds a window.
    cap = Image.new('L', (n, n), 0)
    ImageDraw.Draw(cap).line([(473 * S, 236 * S), (547 * S, 236 * S)],
                             fill=255, width=3)
    if name == 'paper':
        # The paper render's ring runs on up to the crescent, past where the
        # night render's tips stop, and meets at the apex of the window.
        ImageDraw.Draw(cap).polygon(
            [(x * S, y * S) for x, y in
             [(472, 224), (481, 214), (512, 206), (546, 214), (563, 236),
              (561, 248), (512, 240), (486, 250)]], fill=255)
    shield = ndi.binary_fill_holes(ring | (np.asarray(cap) > 0))

    gold = crescent(name, n)

    wings = Image.new('L', (n * 2, n * 2), 0)
    dr = ImageDraw.Draw(wings)
    left = [(x * S * 2, y * S * 2) for x, y in WING]
    right = [((1024 - x) * S * 2, y * S * 2) for x, y in WING]
    dr.polygon(left, fill=255)
    dr.polygon(right, fill=255)
    wings = np.asarray(wings.resize((n, n), Image.LANCZOS)) > 127

    m = shield | gold | wings
    m = ndi.binary_fill_holes(m)
    m = ndi.binary_opening(m, iterations=1)
    m = ndi.binary_erosion(m, iterations=1)
    a = ndi.gaussian_filter(m.astype(np.float32), 0.9)
    return np.clip((a - 0.25) / 0.5, 0, 1)


def bbox(alphas):
    """One box for both themes, so Paper and Night swap without a jump."""
    ys, xs = np.where(np.maximum(*alphas.values()) > 0.02)
    return ys.min(), ys.max() + 1, xs.min(), xs.max() + 1


def compose(name, alpha, box, pad_frac=0.09):
    """The emblem on a transparent canvas with a soft shadow, cropped to size."""
    rgb = load(name)
    y0, y1, x0, x1 = box
    h, w = y1 - y0, x1 - x0
    pad = int(h * pad_frac)
    top, bottom, side = pad, int(pad * 1.7), pad
    out_h, out_w = h + top + bottom, w + 2 * side
    out = np.zeros((out_h, out_w, 4), np.float32)

    a = np.zeros((out_h, out_w), np.float32)
    a[top:top + h, side:side + w] = alpha[y0:y1, x0:x1]
    c = np.zeros((out_h, out_w, 3), np.float32)
    c[top:top + h, side:side + w] = rgb[y0:y1, x0:x1]
    # Colour under the soft edge: pull it from inside, so no tile rim shows.
    inside = ndi.maximum_filter(np.where(a[..., None] > 0.98, c, 0), size=(5, 5, 1))
    c = np.where(a[..., None] > 0.98, c, np.where(inside > 0, inside, c))

    t = THEME[name]
    sh = np.roll(a, int(h * 0.012), axis=0)
    sh = ndi.gaussian_filter(sh, h * 0.012) * t['alpha'] * 0.75
    sh2 = ndi.gaussian_filter(np.roll(a, int(h * 0.04), axis=0), h * 0.03)
    sh = np.clip(sh + sh2 * t['alpha'] * 0.45, 0, 1)

    # Shadow, then the emblem over it.
    ao = a + sh * (1 - a)
    col = np.zeros_like(c)
    sc = np.array(t['shadow'], np.float32)
    safe = np.maximum(ao, 1e-6)[..., None]
    col = (c * a[..., None] + sc * (sh * (1 - a))[..., None]) / safe
    out[..., :3] = col
    out[..., 3] = ao
    return out, (h, w, top, bottom, side)


def to_png(arr, height):
    img = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8)
                          if arr.dtype != np.uint8 else arr, 'RGBA')
    w = round(img.width * height / img.height)
    return img.resize((w, height), Image.LANCZOS)


def bake_marks(alphas, box):
    info = None
    for name in ('paper', 'night'):
        arr, info = compose(name, alphas[name], box)
        arr[..., 3] *= 255
        for scale, folder in ((1, ''), (2, '2.0x/'), (3, '3.0x/')):
            os.makedirs(f'assets/logo/{folder}', exist_ok=True)
            to_png(arr, H1 * scale).save(f'assets/logo/{folder}faith-mark-{name}.png',
                                         optimize=True)
        # Native and launcher art need the emblem on its own, no shadow.
    h, w, top, bottom, side = info
    print('emblem', w, 'x', h, '| canvas aspect', (w + 2 * side) / (h + top + bottom))
    print('NoorMark: aspect', round((w + 2 * side) / (h + top + bottom), 5),
          'emblem', w / h, 'top', top / (h + top + bottom))


def bake_icons(alphas, box):
    """Launcher and native-splash art from the same cut-out (no shadow)."""
    y0, y1, x0, x1 = box
    for name in ('paper', 'night'):
        rgb = load(name)
        e = np.dstack([rgb, alphas[name] * 255])[y0:y1, x0:x1].astype(np.uint8)
        yield name, Image.fromarray(e, 'RGBA')


def square(img, size, fill):
    """The emblem centred in a square canvas, [fill] of the side tall."""
    s = img.copy()
    k = size * fill / s.height
    s = s.resize((round(s.width * k), round(s.height * k)), Image.LANCZOS)
    out = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    out.paste(s, ((size - s.width) // 2, (size - s.height) // 2), s)
    return out


def bake_platform(alphas, box):
    emblems = dict(bake_icons(alphas, box))
    paper, night = emblems['paper'], emblems['night']
    # flutter_native_splash: the pre-Android-12 splash image, and the Android 12
    # icon, which the system clips to a circle (so the emblem stays inside the
    # inner two thirds).
    square(paper, 1152, 0.80).save('assets/logo/splash.png')
    square(night, 1152, 0.80).save('assets/logo/splash_dark.png')
    square(paper, 960, 0.50).save('assets/logo/splash_icon.png')
    square(night, 960, 0.50).save('assets/logo/splash_icon_dark.png')
    # Adaptive icon foreground: the safe zone is the inner 66 %.
    square(paper, 1024, 0.52).save('assets/logo/app_icon_foreground.png')
    # Full icons: the emblem on the system's ground, no alpha on iOS.
    for fn, ground, emb in (('app_icon', (238, 240, 244), paper),
                            ('app_icon_ios', (238, 240, 244), paper)):
        base = Image.new('RGBA', (1024, 1024), ground + (255,))
        base.alpha_composite(square(emb, 1024, 0.66))
        base = base.convert('RGB') if fn.endswith('ios') else base
        base.save(f'assets/logo/{fn}.png')


# Page ground of each theme (NoorColors.paper) and the moon-white of the mosque.
GROUND = {'paper': (238, 240, 244), 'night': (16, 18, 23)}
MOON = (247, 247, 244)
# The plates are generated in the owner's cream and a slightly warm charcoal.
# They are recoloured onto the app's own ground; only the warm light in the
# mosque's windows keeps its warmth.
PLATE = {'paper': dict(y_ground=237, warm_base=20),
         'night': dict(y_ground=26, warm_base=6)}


def smooth(x, lo, hi):
    t = np.clip((x - lo) / (hi - lo), 0, 1)
    return t * t * (3 - 2 * t)


def recolour(name, im):
    """The plate's light and shade, on the app's ground colour."""
    a = np.asarray(im).astype(np.float32)
    y = (0.299 * a[..., 0] + 0.587 * a[..., 1] + 0.114 * a[..., 2])[..., None]
    p = PLATE[name]
    ground = np.array(GROUND[name], np.float32)
    if name == 'paper':
        # Shade darkens the ground; light lifts it to white.
        low = ground * (y / p['y_ground'])
        high = ground + (255 - ground) * np.clip(
            (y - p['y_ground']) / (255 - p['y_ground']), 0, 1)
        out = np.where(y <= p['y_ground'], low, high)
    else:
        # Paper layers step up from the ground; the mosque is moon-white.
        layers = ground * (y / p['y_ground'])
        mosque = np.array(MOON, np.float32) * (y / 255)
        out = layers + (mosque - layers) * smooth(y, 55, 130)
    warm = np.clip((a[..., 0] - a[..., 2])[..., None] - p['warm_base'], 0, None)
    out = out + warm * np.array([0.6, 0.28, -0.7], np.float32)
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), 'RGB')


def bake_backdrops():
    for name in ('paper', 'night'):
        im = Image.open(f'tool/sources/splash_bg_{name}.jpg').convert('RGB')
        im = recolour(name, im)
        im.save(f'assets/images/art/splash_bg_{name}.webp', quality=92, method=6)
        print(name, im.size)


def preview(alphas, box):
    os.makedirs('tmp_work', exist_ok=True)
    for name, bg in (('paper', (238, 240, 244)), ('night', (16, 18, 23))):
        arr, _ = compose(name, alphas[name], box)
        img = Image.fromarray(arr.astype(np.float32).clip(0, 255).astype(np.uint8)
                              if False else
                              np.dstack([arr[..., :3], arr[..., 3] * 255])
                              .astype(np.uint8), 'RGBA')
        base = Image.new('RGBA', img.size, bg + (255,))
        base.alpha_composite(img)
        base.save(f'tmp_work/mark_{name}_preview.png')


if __name__ == '__main__':
    alphas = {n: cutout(n) for n in ('paper', 'night')}
    box = bbox(alphas)
    if 'mask' in sys.argv:
        preview(alphas, box)
    else:
        bake_marks(alphas, box)
        bake_platform(alphas, box)
        bake_backdrops()
