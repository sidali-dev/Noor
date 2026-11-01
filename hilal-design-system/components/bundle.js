/* @ds-bundle: {"format":4,"namespace":"Hilal","components":[{"name":"Button"},{"name":"PaperCard"},{"name":"ArchFrame"},{"name":"Badge"},{"name":"TextField"},{"name":"Toggle"},{"name":"TabBar"},{"name":"Ornament"},{"name":"Icon"}]} */
(function () {
  var React = window.React;
  var h = React.createElement;
  function cx() { return Array.prototype.filter.call(arguments, Boolean).join(" "); }
  function assign(t) { for (var i = 1; i < arguments.length; i++) { var s = arguments[i]; if (s) for (var k in s) if (Object.prototype.hasOwnProperty.call(s, k)) t[k] = s[k]; } return t; }
  function omit(o, keys) { var r = {}; for (var k in o) if (keys.indexOf(k) < 0) r[k] = o[k]; return r; }

  /* ---------------- Icon (24px stroke set, inherits currentColor) ---------------- */
  var PATHS = {
    home: ["M4 11.5 12 5l8 6.5", "M6 10v9h12v-9", "M10 19v-5h4v5"],
    compass: ["M12 3a9 9 0 1 0 0 18a9 9 0 1 0 0-18z", "M15.5 8.5 13.4 13.4 8.5 15.5 10.6 10.6z"],
    calendar: ["M5 6h14v14H5z", "M5 10h14", "M9 3.5v4M15 3.5v4"],
    bookmark: ["M7 4h10v16l-5-3.5L7 20z"],
    settings: ["M12 9a3 3 0 1 0 0 6a3 3 0 1 0 0-6z", "M12 3v2.5M12 18.5V21M3 12h2.5M18.5 12H21M5.6 5.6l1.8 1.8M16.6 16.6l1.8 1.8M5.6 18.4l1.8-1.8M16.6 7.4l1.8-1.8"],
    moon: ["M15.5 4.2a8 8 0 1 0 4.3 11.3A6.5 6.5 0 0 1 15.5 4.2z"],
    star: ["M12 3l2 5.2 5.2 2-5.2 2L12 17.5l-2-5.3-5.2-2 5.2-2z"],
    search: ["M10.5 4a6.5 6.5 0 1 0 0 13a6.5 6.5 0 1 0 0-13z", "M15.5 15.5 20 20"],
    bell: ["M6 16V11a6 6 0 0 1 12 0v5l1.5 2h-15z", "M10 20.5a2 2 0 0 0 4 0"],
    check: ["M5 12.5 10 17 19 7"],
    alert: ["M12 4 21 19.5H3z", "M12 10v4.5", "M12 17h.01"],
    plus: ["M12 5v14M5 12h14"]
  };
  function Icon(props) {
    var size = props.size || 24;
    var d = PATHS[props.name] || PATHS.star;
    return h("svg", { className: cx("hl-icon", props.className), width: size, height: size, viewBox: "0 0 24 24", fill: "none",
      stroke: "currentColor", strokeWidth: props.strokeWidth || 1.6, strokeLinecap: "round", strokeLinejoin: "round",
      "aria-hidden": props.label ? undefined : "true", role: props.label ? "img" : undefined, "aria-label": props.label },
      d.map(function (p, i) { return h("path", { key: i, d: p }); }));
  }
  Icon.names = Object.keys(PATHS);

  /* ---------------- Button ---------------- */
  function Button(props) {
    var variant = props.variant || "primary";
    var rest = omit(props, ["variant", "size", "icon", "className", "children"]);
    return h("button", assign({ type: "button" }, rest, {
      className: cx("hl-btn", "hl-btn-" + variant, props.size === "sm" && "hl-btn-sm", props.className)
    }), props.icon ? h(Icon, { name: props.icon }) : null, props.children);
  }

  /* ---------------- PaperCard ---------------- */
  function PaperCard(props) {
    var e = props.elevation || 2;
    var rest = omit(props, ["elevation", "tone", "eyebrow", "title", "className", "children"]);
    return h("section", assign({}, rest, {
      className: cx("hl-card", "hl-card-e" + e, props.tone === "night" && "hl-card-night", props.className)
    }),
      props.eyebrow ? h("p", { className: "hl-card-eyebrow" }, props.eyebrow) : null,
      props.title ? h("h3", { className: "hl-card-title" }, props.title) : null,
      h("div", { className: "hl-card-body" }, props.children));
  }

  /* ---------------- ArchFrame (layered shadow box) ---------------- */
  // Light comes from straight above: every layer casts a short shadow downward onto the layer behind it.
  var ARCH = [[22, 88, 30], [52, 48, 32], [100, 14, 34], [148, 48, 34], [178, 88, 32], [200, 130, 30]];
  function archPath(d) {
    var sx = (200 - 2 * d) / 200, y0 = 14 + d * 1.15, sy = (240 - y0) / 226;
    var X = function (x) { return +(d + x * sx).toFixed(2); }, Y = function (y) { return +(y0 + (y - 14) * sy).toFixed(2); };
    var p = "M" + X(0) + " 240V" + Y(130);
    ARCH.forEach(function (a) { var r = +(a[2] * sx).toFixed(2); p += "A" + r + " " + r + " 0 0 1 " + X(a[0]) + " " + Y(a[1]); });
    return p + "V240Z";
  }
  function ring(c, x, y) { return "M" + (x - c) + " " + y + "a" + c + " " + c + " 0 1 0 " + 2 * c + " 0a" + c + " " + c + " 0 1 0 " + -2 * c + " 0Z"; }
  var INSETS = { 1: [0, 13], 2: [0, 10, 19], 3: [0, 8, 15, 21] };
  var STARS = [[46, 58, 2.6], [154, 54, 2.2], [54, 156, 1.8], [148, 160, 2.2], [38, 130, 1.6], [164, 134, 1.8], [78, 44, 1.4], [124, 40, 1.4]];
  function star(x, y, r, k) {
    var d = "M" + x + " " + (y - r * 2) + "L" + (x + r * .55) + " " + (y - r * .55) + "L" + (x + r * 2) + " " + y + "L" + (x + r * .55) + " " + (y + r * .55) +
      "L" + x + " " + (y + r * 2) + "L" + (x - r * .55) + " " + (y + r * .55) + "L" + (x - r * 2) + " " + y + "L" + (x - r * .55) + " " + (y - r * .55) + "Z";
    return h("path", { key: k, className: "star", d: d });
  }
  var archSeq = 0;
  function ArchFrame(props) {
    var uid = React.useRef("hla" + (++archSeq)).current;
    var width = props.width || 280;
    var show = function (k) { return props[k] === undefined ? true : props[k]; };
    var layers = INSETS[props.layers] ? props.layers : 3;
    var ins = INSETS[layers];
    var win = archPath(ins[ins.length - 1]);
    var cast = "url(#" + uid + "-c)", castDeep = "url(#" + uid + "-cd)", wash = "url(#" + uid + "-w)";
    var k = [];
    // defs: light wash, moon glow, two cast shadows, window clip
    k.push(h("defs", { key: "defs" },
      h("linearGradient", { id: uid + "-w", gradientUnits: "userSpaceOnUse", x1: 0, y1: 10, x2: 0, y2: 250 }, h("stop", { offset: 0, className: "w-top" }), h("stop", { offset: 1, className: "w-bot" })),
      h("radialGradient", { id: uid + "-g" }, h("stop", { offset: 0, className: "g-in" }), h("stop", { offset: 1, className: "g-out" })),
      h("filter", { id: uid + "-c", x: "-20%", y: "-20%", width: "140%", height: "160%" }, h("feDropShadow", { className: "hl-cast", dx: 0, dy: 1.4, stdDeviation: 1.3 })),
      h("filter", { id: uid + "-cd", x: "-20%", y: "-20%", width: "140%", height: "160%" }, h("feDropShadow", { className: "hl-cast", dx: 0, dy: 2.6, stdDeviation: 2.4 })),
      h("clipPath", { id: uid + "-k" }, h("path", { d: win }))));
    // 1. the night window and everything seen through it
    var sky = [h("path", { key: "win", className: "window", d: win })];
    if (show("stars")) STARS.forEach(function (s, i) { sky.push(star(s[0], s[1], s[2], "s" + i)); });
    if (show("moon")) { sky.push(h("circle", { key: "m", className: "moon", cx: 100, cy: 62, r: 13 })); sky.push(h("circle", { key: "mc", className: "window", cx: 105.5, cy: 57, r: 11.5 })); }
    if (show("moon") && show("glow")) sky.push(h("circle", { key: "glow", cx: 100, cy: 62, r: 46, fill: "url(#" + uid + "-g)" }));
    if (show("skyline")) {
      var mins = [];
      [70, 130].forEach(function (x, i) {
        mins.push(h("rect", { key: "mt" + i, x: x - 3.5, y: 150, width: 7, height: 100 }));
        mins.push(h("rect", { key: "mb" + i, x: x - 6, y: 163, width: 12, height: 2.5 }));
        mins.push(h("circle", { key: "mh" + i, cx: x, cy: 150, r: 4.5 }));
        mins.push(h("rect", { key: "ms" + i, x: x - .7, y: 139, width: 1.4, height: 9 }));
      });
      sky.push(h("g", { key: "mins", className: "paper-back", filter: cast }, mins));
      sky.push(h("rect", { key: "wall", className: "paper-back", filter: cast, x: 0, y: 200, width: 200, height: 50 }));
      sky.push(h("g", { key: "domes", className: "paper", filter: cast },
        [[44, 198], [156, 198]].map(function (d, i) { return h("g", { key: i }, h("circle", { cx: d[0], cy: d[1], r: 22 }), h("rect", { x: d[0] - 22, y: d[1], width: 44, height: 50 }), h("rect", { x: d[0] - .7, y: d[1] - 31, width: 1.4, height: 10 })); })));
    }
    k.push(h("g", { key: "sky", clipPath: "url(#" + uid + "-k)" }, sky));
    // 2. paper frames, innermost (furthest back) first; each casts onto the one behind it
    for (var i = ins.length - 2; i >= 0; i--) {
      k.push(h("path", { key: "r" + i, fill: wash, fillRule: "evenodd", filter: i === 0 ? castDeep : cast, d: archPath(ins[i]) + archPath(ins[i + 1]) }));
    }
    // 3. cloud scroll: back row, then front row, hiding the base
    if (show("clouds")) {
      var back = [[10, 200, 18], [46, 192, 22], [86, 196, 20], [126, 190, 22], [166, 196, 20], [196, 202, 16]];
      var front = [[-4, 214, 14], [26, 210, 18], [62, 212, 19], [100, 208, 21], [138, 212, 19], [174, 210, 18], [204, 215, 14]];
      var under = [[8, 226, 12], [36, 228, 13], [66, 227, 13], [96, 229, 13], [126, 227, 13], [156, 228, 13], [186, 226, 12]];
      k.push(h("g", { key: "cb", className: "paper-back", filter: cast }, back.map(function (c, j) { return h("circle", { key: j, cx: c[0], cy: c[1], r: c[2] }); })));
      k.push(h("g", { key: "cf", className: "paper", filter: cast },
        h("rect", { x: -2, y: 210, width: 204, height: 32 }),
        front.concat(under).map(function (c, j) { return h("circle", { key: j, cx: c[0], cy: c[1], r: c[2] }); })));
      k.push(h("g", { key: "sw", className: "swirl" }, [[26, 212, 9], [100, 210, 11], [174, 212, 9]].map(function (s, j) {
        return h("path", { key: j, d: "M" + (s[0] - s[2]) + " " + s[1] + "a" + s[2] + " " + s[2] + " 0 1 1 " + s[2] + " " + s[2] * .6 });
      })));
    }
    // 4. lace border, the front-most layer
    if (show("lace")) {
      var lp = "M-16 262V246", holes = "";
      for (var x = -16; x < 216; x += 16) {
        lp += "a8 8 0 0 1 16 0";
        holes += ring(2.4, x + 8, 246.5) + (x + 16 < 216 ? ring(1.2, x + 16, 255) : "");
      }
      k.push(h("path", { key: "lace", className: "paper", fillRule: "evenodd", filter: castDeep, d: lp + "V262Z" + holes }));
    }
    return h("figure", { className: cx("hl-arch", props.className), style: assign({ width: width }, props.style), role: props.label ? "img" : undefined, "aria-label": props.label },
      h("svg", { className: "hl-arch-svg", viewBox: "-20 0 240 266", "aria-hidden": "true" }, k),
      props.children ? h("div", { className: "hl-arch-content", style: props.contentTop ? { top: props.contentTop } : null }, props.children) : null);
  }

  /* ---------------- Badge ---------------- */
  function Badge(props) {
    var tone = props.tone || "neutral";
    var icon = props.icon || (tone === "success" ? "check" : tone === "danger" ? "alert" : null);
    return h("span", { className: cx("hl-badge", "hl-badge-" + tone, props.className) }, icon ? h(Icon, { name: icon, size: 12, strokeWidth: 2 }) : null, props.children);
  }

  /* ---------------- TextField ---------------- */
  var fieldSeq = 0;
  function TextField(props) {
    var idRef = React.useRef(props.id || "hl-field-" + (++fieldSeq));
    var id = idRef.current;
    var rest = omit(props, ["label", "hint", "error", "className", "id"]);
    var msg = props.error || props.hint;
    return h("div", { className: cx("hl-field", props.error && "hl-field-error", props.className) },
      props.label ? h("label", { className: "hl-field-label", htmlFor: id }, props.label) : null,
      h("input", assign({ className: "hl-field-input", id: id, "aria-invalid": props.error ? "true" : undefined, "aria-describedby": msg ? id + "-msg" : undefined }, rest)),
      msg ? h("span", { className: "hl-field-hint", id: id + "-msg" }, props.error ? h(Icon, { name: "alert", size: 14, strokeWidth: 2 }) : null, props.error ? " " : null, msg) : null);
  }

  /* ---------------- Toggle ---------------- */
  function Toggle(props) {
    var controlled = props.checked !== undefined;
    var st = React.useState(!!props.defaultChecked);
    var on = controlled ? props.checked : st[0];
    return h("label", { className: cx("hl-toggle", props.className) },
      h("input", { type: "checkbox", role: "switch", checked: on, disabled: props.disabled,
        onChange: function (e) { if (!controlled) st[1](e.target.checked); if (props.onChange) props.onChange(e.target.checked); } }),
      h("span", { className: "hl-toggle-track", "aria-hidden": "true" }, h("span", { className: "hl-toggle-thumb" })),
      props.label ? h("span", null, props.label) : null);
  }

  /* ---------------- TabBar ---------------- */
  function TabBar(props) {
    var items = props.items || [];
    var st = React.useState(props.defaultActive || (items[0] && items[0].id));
    var active = props.active !== undefined ? props.active : st[0];
    return h("nav", { className: cx("hl-tabbar", props.className), "aria-label": props.label || "Main" },
      items.map(function (it) {
        return h("button", { key: it.id, type: "button", className: "hl-tab", "aria-current": it.id === active ? "page" : undefined,
          onClick: function () { if (props.active === undefined) st[1](it.id); if (props.onChange) props.onChange(it.id); } },
          h(Icon, { name: it.icon }), h("span", null, it.label));
      }));
  }

  /* ---------------- Ornament ---------------- */
  function Ornament(props) {
    return h("div", { className: cx("hl-ornament", props.className), role: "separator" },
      props.label ? h("span", { className: "hl-ornament-label" }, props.label)
        : h("svg", { viewBox: "0 0 24 24", "aria-hidden": "true" },
          h("g", { fill: "currentColor" },
            h("rect", { x: 5, y: 5, width: 14, height: 14 }),
            h("rect", { x: 5, y: 5, width: 14, height: 14, transform: "rotate(45 12 12)" }))));
  }

  var api = { Button: Button, PaperCard: PaperCard, ArchFrame: ArchFrame, Badge: Badge, TextField: TextField, Toggle: Toggle, TabBar: TabBar, Ornament: Ornament, Icon: Icon };
  window.Hilal = assign(window.Hilal || {}, api);
})();
