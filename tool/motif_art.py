"""Bakes the owner's two reference images into the app's motif assets.

    python tool/motif_art.py [out_dir]

Band: a seamless tile cut from the centre of the border, between two lobes.
Ornament: the button with its chevron painted out, cropped to its outline.
Disc: the ornament's centre disc alone, for ayah markers and in-pill buttons.
Each comes in Paper and in a Night twin, with a soft shadow baked in.
"""
import sys

import numpy as np
from PIL import Image
from scipy import ndimage as ni

BORDER = 'assets/images/Bordure arabesque blanche en relief.png'
BUTTON = 'assets/images/Bouton ornemental arabesque en relief.png'

# Page colours, from NoorColors: the hero band's plate must match them exactly.
PAGE = {'paper': (0xEE, 0xF0, 0xF4), 'night': (0x10, 0x12, 0x17)}

# The white paper's luminance onto charcoal sheets.
NIGHT_STOPS = [(120, (0x12, 0x14, 0x1A)), (200, (0x26, 0x2A, 0x33)),
               (240, (0x3A, 0x3F, 0x4B)), (255, (0x56, 0x5C, 0x6B))]
SHADOW = {'paper': 0.42, 'night': 0.8}

PX_PER_DP = 4
PANEL_BAND_DP = 52
PANEL_FOOT_DP = 5  # Room for the shadow under the pendants.
ORNAMENT_PX = 528  # 132 dp, the largest, at 4 px per dp.
DISC_PX = 160
FACE_R = 252  # In the reference's pixels: the flat face, inside its first groove.


def load(path):
    a = np.asarray(Image.open(path).convert('RGBA')).astype(float)
    # The cutout left a haze of alpha 1 all round the shape.
    a[..., 3] = np.where(a[..., 3] < 16, 0, a[..., 3])
    return a


def lum(a):
    return a[..., :3] @ np.array([0.299, 0.587, 0.114])


def tone(a, variant):
    if variant == 'paper':
        return a
    xs, cols = zip(*NIGHT_STOPS)
    out = a.copy()
    for i in range(3):
        out[..., i] = np.interp(lum(a), xs, [c[i] for c in cols])
    return out


def over(top, bottom):
    ta, ba = top[..., 3:] / 255, bottom[..., 3:] / 255
    oa = ta + ba * (1 - ta)
    rgb = (top[..., :3] * ta + bottom[..., :3] * ba * (1 - ta)) / np.maximum(oa, 1e-6)
    return np.dstack([rgb, oa * 255])


def cast(alpha, dy, sigma, variant, wrap=False):
    """A soft black copy of [alpha], dropped [dy] px and blurred."""
    mode = ('constant', 'wrap' if wrap else 'constant')
    s = ni.gaussian_filter(np.pad(alpha, ((dy, 0), (0, 0)))[:alpha.shape[0]], sigma, mode=mode)
    return np.dstack([np.zeros(alpha.shape + (3,)), s * SHADOW[variant]])


def bevel(a, wrap=False):
    """Lit top edges, shaded bottom ones: the paper's thickness at small sizes."""
    mode = ('nearest', 'wrap' if wrap else 'nearest')
    g = ni.sobel(ni.gaussian_filter(a[..., 3] / 255, 1.2, mode=mode), axis=0, mode=mode)
    out = a.copy()
    out[..., :3] = np.clip(out[..., :3] - 150 * g[..., None], 0, 255)
    return out


def resize(a, w, h):
    # Premultiplied, so the transparent ground does not bleed into the edge.
    p = a.copy()
    p[..., :3] *= a[..., 3:] / 255
    r = np.dstack([np.asarray(Image.fromarray(p[..., i].astype('float32'), 'F')
                              .resize((w, h), Image.LANCZOS)) for i in range(4)])
    r[..., 3] = np.clip(r[..., 3], 0, 255)
    r[..., :3] = np.clip(r[..., :3] / np.maximum(r[..., 3:] / 255, 1e-6), 0, 255)
    return r


def save(a, path, lossless=False):
    im = Image.fromarray(np.clip(a + 0.5, 0, 255).astype('uint8'), 'RGBA')
    im.save(path, 'WEBP', lossless=lossless, quality=90, alpha_quality=100, method=6)
    print(path, im.size)


# ------------------------------------------------------------------------ Band
def band_tile(a):
    """Centre of the border: a lobe's axis to the next, forced seamless."""
    alpha = a[..., 3]
    seam = min(range(480, 601), key=lambda x: np.abs(
        alpha[:, x - 60:x][:, ::-1] - alpha[:, x:x + 60]).mean())
    half = a[:, seam:a.shape[1] // 2]
    # The art is nearly symmetric; mirroring makes the tile's two ends the same.
    tile = np.concatenate([half, half[:, ::-1]], axis=1)
    rows = np.where(tile[..., 3].max(axis=1) > 0)[0]
    print('band seam at x =', seam, 'tile', tile.shape[1], 'x', rows[-1] - rows[0] + 1)
    return tile[rows[0]:rows[-1] + 1]


def fit_width(tile, h):
    # The art test wants widths divisible by 4.
    return 4 * round(tile.shape[1] * h / tile.shape[0] / 4)


def panel_band(tile, variant, out):
    """Cards and sheets: real holes, on whatever paper is behind."""
    H, foot = PANEL_BAND_DP * PX_PER_DP, PANEL_FOOT_DP * PX_PER_DP
    art_h = H - foot
    w = fit_width(tile, art_h)
    art = np.zeros((H, w, 4))
    art[:art_h] = resize(bevel(tone(tile, variant), wrap=True), w, art_h)
    save(over(art, cast(art[..., 3], 5, 5, variant, wrap=True)),
         f'{out}/motif_band_{variant}.webp')


def paint_out_chevron(a):
    """Returns the art with its disc's chevron gone, the centre and disc radius."""
    al = a[..., 3]
    ys, xs = np.where(al > 128)
    cx, cy = (xs.min() + xs.max()) / 2, (ys.min() + ys.max()) / 2
    Y, X = np.mgrid[:al.shape[0], :al.shape[1]]
    R = np.hypot(X - cx, Y - cy)

    # The disc ends at the dark groove between it and the ring.
    L = lum(a)
    radii = list(range(220, 340, 2))
    rim = radii[int(np.argmin([np.median(L[(R >= r) & (R < r + 2)]) for r in radii]))]
    r = rim - 4
    print('ornament centre', cx, cy, 'disc radius', r)

    # The disc's shading is smooth: fit it, refitting without what stands off
    # the fit, which is the chevron and its shadow.
    inside = R < FACE_R - 6
    xn, yn = (X - cx) / r, (Y - cy) / r
    basis = np.stack([np.ones_like(xn), xn, yn, xn * yn, xn ** 2, yn ** 2,
                      xn ** 3, yn ** 3, xn ** 2 * yn, xn * yn ** 2], axis=-1)
    keep = inside.copy()
    for _ in range(5):
        fit = np.dstack([basis @ np.linalg.lstsq(basis[keep], a[..., c][keep], rcond=None)[0]
                         for c in range(3)])
        off = np.abs(a[..., :3] - fit).mean(axis=-1)
        keep = inside & (off < 2.5)
    mask = ni.binary_dilation(inside & ~keep, iterations=12)
    soft = ni.gaussian_filter(mask.astype(float), 6)[..., None]
    out = a.copy()
    out[..., :3] = a[..., :3] * (1 - soft) + fit * soft
    return out, cx, cy, r


def ornament(clean, cx, cy, r, variant, out):
    a = bevel(tone(clean, variant))
    ys, xs = np.where(a[..., 3] > 128)
    half = max(xs.max() - cx, cx - xs.min(), ys.max() - cy, cy - ys.min())
    side = 2 * int(half * 1.08)  # 8 percent all round, for the shadow.
    x0, y0 = int(cx - side / 2), int(cy - side / 2)
    canvas = np.zeros((side, side, 4))
    sub = a[max(y0, 0):y0 + side, max(x0, 0):x0 + side]
    canvas[max(-y0, 0):max(-y0, 0) + sub.shape[0],
           max(-x0, 0):max(-x0, 0) + sub.shape[1]] = sub
    s = resize(canvas, ORNAMENT_PX, ORNAMENT_PX)
    print('disc is', round(2 * r / side, 3), 'of the ornament image')
    save(over(s, cast(s[..., 3], 12, 11, variant)), f'{out}/motif_ornament_{variant}.webp')


def disc(clean, cx, cy, r, variant, out):
    side = int(r * 2.2)
    x0, y0 = int(cx - side / 2), int(cy - side / 2)
    sub = tone(clean, variant)[y0:y0 + side, x0:x0 + side].copy()
    Y, X = np.mgrid[:side, :side]
    R = np.hypot(X - side / 2, Y - side / 2)
    # Round off at the rim: the ring and petals go.
    sub[..., 3] = np.clip(r + 1 - R, 0, 1) * 255
    # Lit lip above, shaded lip below: the disc's own relief.
    lip = np.clip((R - (r - 14)) / 14, 0, 1) * (Y - side / 2) / r
    sub[..., :3] = np.clip(sub[..., :3] - 40 * lip[..., None], 0, 255)
    s = resize(sub, DISC_PX, DISC_PX)
    save(over(s, cast(s[..., 3], 4, 4, variant)), f'{out}/motif_disc_{variant}.webp')


if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else 'assets/images/art'
    tile = band_tile(load(BORDER))
    clean, cx, cy, r = paint_out_chevron(load(BUTTON))
    for variant in PAGE:
        panel_band(tile, variant, out)
        ornament(clean, cx, cy, r, variant, out)
        disc(clean, cx, cy, r, variant, out)
