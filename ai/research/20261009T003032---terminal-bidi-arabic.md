# Terminal bidi and Arabic support (kitty replacement)

Author: @agent (Claude Opus 5.5, `claude-opus-5-5`)
Date: 2026-10-09

For: replacing kitty on eagle (Plasma 6 Wayland, NVIDIA) with a terminal that shows Arabic correctly, including fully vocalised Uthmani Quran text (Tanzil), while staying usable for TUIs (helix, tmux, Claude Code, Codex, Pi). Need: joined letter forms, correct bidi order, stacked marks, TUIs that do not fall apart. Wanted: kitty's GPU rendering, ligatures, true colour, image protocol, font fallback.

Checked 2026-10-09 against: nixpkgs b1b875982b17 (flake.lock), home-manager f53f3267f5d0 (flake.lock), the source of each terminal at the pinned nixpkgs version, issue trackers via the GitHub / GitLab / Codeberg / KDE Invent APIs, and local render tests (method below).

## Changelog

- 2026-10-09: first version.

## Local facts

- Desktop: Plasma 6 on Wayland (`modules/desktop.nix`, `XDG_SESSION_TYPE=wayland`). Konsole 26.08.1 is already installed by Plasma (`/run/current-system/sw/bin/konsole`).
- kitty is configured in `modules/terminals.nix`: `programs.kitty` plus three `xdg.configFile."kitty/*-theme.auto.conf"` gruvbox themes. Ghostty is also enabled there. `modules/hardware/laptop.nix` has `kitty` in the earlyoom `--avoid` regex.
- Editor: helix (`modules/editors.nix`, `defaultEditor = true`); neovim is disabled. tmux 3.7c is configured in `modules/terminals/tmux.nix`.
- Fonts: system fonts include noto-fonts, dejavu, hack. Only DejaVu Sans Mono and FreeMono are monospace fonts with Arabic glyphs. All the Quranic marks in the Tanzil text (U+0670, U+0671, U+06D6–U+06ED, U+08F0–U+08F2) are covered only by Noto Naskh/Sans/Kufi Arabic and Unifont (`fc-list :charset=…`). So every terminal falls back to Noto for Quran text.

## kitty: the claim checked

The claim is mostly right. One correction: kitty does shape Arabic letters. It has no bidi.

- kitty 0.49 docs, [`force_ltr`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.force_ltr): "kitty does not support BIDI (bidirectional text), however, for RTL scripts, words are automatically displayed in RTL", so "HELLO WORLD" shows as "WORLD HELLO". The same text is in `kitty/options/definition.py` at 0.49.0.
- Kovid Goyal's position:
  - 2018-05-10 ([#536](https://github.com/kovidgoyal/kitty/issues/536#issuecomment-388220056)): "arabic text is never going to look very good in kitty, as kitty is designed to work as a character grid".
  - 2018-05-31 ([#536](https://github.com/kovidgoyal/kitty/issues/536#issuecomment-393363403)): "kitty is never going to have perfect support for arabic … what you get now is about as good as you are going to get". He points people to mlterm.
  - 2020-02-06 ([#2109](https://github.com/kovidgoyal/kitty/issues/2109#issuecomment-582691604)): he would accept outside work only with no "significant negative performance impact on normal (i.e. no bidi) usage", and it would need a new paragraph data structure.
  - 2023-12-08 ([#6893](https://github.com/kovidgoyal/kitty/issues/6893#issuecomment-1846631981)): "There is no solution, that's why its an open issue."
- Status: [#2109 "BiDirectional text support"](https://github.com/kovidgoyal/kitty/issues/2109) has been open since 2019-11-01. Kovid has posted nothing in it since 2020. New requests are closed as duplicates of it, most recently [#10378](https://github.com/kovidgoyal/kitty/issues/10378) on 2026-08-21. He has not refused outright, but he will not build it himself and he sets a high bar for others.
- Observed (kitty 0.49.0): letters join within each word, but words appear in left-to-right order. Mixed lines and Quran lines come out scrambled.

## The spec

- [BiDi in Terminal Emulators](https://terminal-wg.pages.freedesktop.org/bidi/), Egmont Koblinger, v0.1 2019-01-29 ([about](https://terminal-wg.pages.freedesktop.org/bidi/about.html)). It is still labelled "draft proposal". VTE's `src/bidi.cc` says it implements v0.2.
- Implicit mode (the terminal runs the UBA and does Arabic shaping) is the default. Explicit mode (the app sends visual-order text, and the terminal does no bidi and no shaping) is for bidi-aware apps, and as "damage control" for complex TUIs.
- Escape sequences ([escape-sequences](https://terminal-wg.pages.freedesktop.org/bidi/recommendation/escape-sequences.html)):
  - BDSM: `CSI 8 h` selects implicit mode, `CSI 8 l` selects explicit mode.
  - SCP: `CSI 1 SP k` sets LTR, `CSI 2 SP k` sets RTL, `CSI 0 SP k` restores the terminal default.
  - `DECSET 2500` mirrors box drawing; `DECSET 2501` turns on paragraph-direction autodetection.
  - Arrow-key swapping: VTE uses `DECSET 1243`.
- Spec's own list of conforming implementations: VTE only ([implementations](https://terminal-wg.pages.freedesktop.org/bidi/implementations.html)).
- Practical problem: no TUI in this setup sends `CSI 8 l`. Neither helix nor tmux does, and tmux does not pass it through. Implicit mode therefore applies to their screens, and how each terminal handles columns and box-drawing separators decides whether a TUI survives.

## Test method

The terminals ran inside a headless wlroots compositor (`cage` 0.3.1 with `WLR_BACKENDS=headless WLR_RENDERER=pixman`, GL via Mesa llvmpipe) and were captured with `grim` from inside the terminal. Nothing appeared on the desktop. The test inputs were:

- `cat` of a sample file:
  - a plain sentence with lam-alef;
  - a mixed `Hello عالم 123 world, لا إله إلا الله (end)`;
  - Tanzil Uthmani 1:1 and 2:2 (alef wasla, dagger alef, sukun, shadda, the ۛ pause mark);
  - a box-drawing table cell;
  - a path with Arabic;
  - a line that starts with Arabic.
- A two-pane layout drawn with cursor addressing (`│` separators), in implicit mode and again after `CSI 8 l`.
- `ls`-style space-padded columns.
- helix 25.07.1 on the sample file.
- tmux 3.7c with a vertical split, each pane `cat`ting the sample.

Each terminal used its default font unless noted. All rendering was software rendering at 1280×720.

## Results per terminal

### Konsole 26.08.1 (KDE)

- Implementation (`src/terminalDisplay/TerminalDisplay.cpp` `bidiMap`):
  - ICU `ubidi` runs the UBA per screen line, not per paragraph.
  - ICU `u_shapeArabic` shapes to presentation forms.
  - Qt "word mode" draws runs as whole strings.
- Profile options (`src/profile/Profile.cpp`), all defaulting to `true`:
  - `BidiRenderingEnabled`;
  - `BidiLineLTR`: lines are always LTR; when off, the first strong character sets the direction;
  - `BidiTableDirOverride`: box-drawing characters count as strong LTR.
- Lam-alef: since [5f1fd57](https://invent.kde.org/utilities/konsole/-/commit/5f1fd57b50e7e3899ba682c021697b6a61194f76) (2024-04-24, KDE bug 478181), Konsole deliberately splits the ligature into medial lam plus final alef. The pair is readable, but it is not the correct ligature.
- There is no handling of BDSM, SCP or 2500/2501. A TUI cannot opt out.
- Observed:
  - `cat`: letters join, bidi order is correct, and every Uthmani mark is present and stacked. This was the best overall in the test.
  - Two-pane test: the panes stay intact, because of the box-drawing override. `CSI 8 l` is ignored.
  - helix: rows are intact and the gutter stays in place.
  - tmux split: both panes are intact.
  - Space-padded columns of Arabic are reordered across the gap. That is inherent to the UBA.
- Features:
  - true colour;
  - sixel, iTerm2 images and kitty graphics APC (`Vt102Emulation.cpp`; how much of the protocol it covers was not checked);
  - kitty keyboard protocol;
  - coding ligatures via word mode (`WordModeCoding` defaults to true);
  - fontconfig fallback.
  - No GPU: QPainter raster.
- Maintenance: KDE Gear release cycle. Bidi and shaping commits date from 2022-08 to 2024-04 (Matan Ziv-Av).
- Nix: in nixpkgs as `kdePackages.konsole`, already installed. home-manager has no `programs.konsole`; plasma-manager has one, but it is not a flake input here.

### WezTerm 0-unstable-2026-09-17

- Implementation:
  - `bidi_enabled` defaults to false; `bidi_direction` takes `LeftToRight | RightToLeft | AutoLeftToRight | AutoRightToLeft` (`config/src/config.rs`, `bidi/src/lib.rs`).
  - The bidi engine is wezterm's own `wezterm-bidi` crate, which passes 100% of BidiTest.txt and BidiCharacterTest.txt (`bidi/README.md`).
  - Shaping is done by HarfBuzz.
  - It honours BDSM `CSI 8 h/l` and SCP (`term/src/terminalstate/{mod,performer}.rs`). It does not handle 2500/2501.
  - The options are documented only in the changelog and in [#784](https://github.com/wezterm/wezterm/issues/784#issuecomment-1025346930) (2022-01-31). The changelog calls the feature "Experimental (and incomplete!)" (20220319 release).
- Observed with bidi on:
  - Default font (JetBrains Mono plus fallback): order is correct, but in the vocalised lines base letters disappear (`بِسْمِ` showed only `سْمِ`).
  - With `DejaVu Sans Mono` plus Noto Naskh Arabic as fallback: all letters and marks are present, and lam-alef is a true ligature. It leaves a blank cell after it. This was the best-looking Arabic of all the terminals.
  - Two-pane test and tmux split: intact. `CSI 8 l` turns bidi off as the spec says.
  - helix: words appear in logical (reversed) order on every row, the same as kitty. Inside the editor the bidi effectively does nothing.
  - With bidi off, the result looks like kitty: letters join, but every word is reversed.
- Features: GPU (OpenGL/WebGPU), ligatures, true colour, kitty graphics, sixel, iTerm2 images, kitty keyboard protocol.
- Maintenance:
  - The last tagged release is 20240203-110809-5046fc22 (2024-02-03). Commits continue (last push 2026-10-05), and nixpkgs packages a snapshot.
  - Wez, 2025-03-08 ([#784](https://github.com/wezterm/wezterm/issues/784#issuecomment-2708220679)): "I have fairly limited bandwidth at the moment". #784 is still open.
- Nix: `wezterm` in nixpkgs; home-manager has `programs.wezterm`.

### VTE 0.84.1: Ptyxis 50.1, GNOME Terminal 3.60.0, GNOME Console 50.0

- Implementation (`src/bidi.cc`, `src/modes.py`, `src/parser-seq.py`):
  - This is the spec's reference implementation. It has per-paragraph FriBidi bidi, BDSM, SCP, `DECSET 2500` (default off), `2501` (default off) and `1243` arrow swapping (default on).
  - The GObject properties `enable-bidi` and `enable-shaping` both default to true (since 0.58).
  - Shaping uses FriBidi presentation forms. Lam-alef ligatures are disabled ([vte#142](https://gitlab.gnome.org/GNOME/vte/-/work_items/142), open since 2019-06-30, "offset Arabic ligatures by half cell"). The source itself says the presentation-forms approach "should be replaced by HarfBuzz".
  - Ptyxis does not touch any of these properties.
- Observed (Ptyxis):
  - `cat`: order is correct and letters join. The marks are present but cramped, and lam-alef appears as two separate letters.
  - Two-pane test in implicit mode: **the panes swap**. Arabic in the left pane appears on the right, together with its `│`. After `CSI 8 l` the layout holds, but the Arabic is reversed and unshaped, which is what the spec intends.
  - **tmux split: text from the left pane spills across the pane border on every Arabic line.**
  - helix: intact. Only the text column holds Arabic.
- Features:
  - GTK4 GSK rendering (`src/drawing-gsk.cc`), true colour.
  - No ligatures: `fonts-pangocairo.cc` deliberately inserts a space to defeat them.
  - Sixel exists in the widget but `enable-sixel` defaults to false, and Ptyxis 50.1 has no setting for it.
  - No kitty graphics.
- Nix: `vte`, `ptyxis`, `gnome-terminal`; home-manager has `programs.ptyxis` and `programs.gnome-terminal`.

### mlterm 3.9.4 (nixpkgs; upstream 3.9.5, 2026-07-06)

- Implementation:
  - FriBidi bidi, plus optional HarfBuzz OpenType layout (`--otl`).
  - `bidi_mode=normal|left|right` and `bidi_separators` (`man/mlterm.1`, `doc/en/README.bidi`).
  - Lam-alef ligatures occupy two columns (`doc/en/ReleaseNote`).
  - It does not implement BDSM or SCP; Wez checked this on 2022-01-29 ([#784](https://github.com/wezterm/wezterm/issues/784#issuecomment-1024980382)).
- Observed (`mlterm-wl --otl`):
  - `cat`: order and joining are correct, and the RTL-first line is auto-detected and right-aligned. With no font configured, the cell spacing is wide and ugly.
  - helix: the RTL-first row is mirrored as a whole, so the line number jumps to the right edge. That breaks TUI layout under the default `bidi_mode=normal`.
- Features:
  - Sixel and ReGIS, true colour, a Wayland backend.
  - CPU rendering.
  - Its 1990s-style configuration (`~/.mlterm/main`, `font`) is a poor fit for kitty-style workflows.
- Nix: `mlterm` (the build includes `mlterm-wl`); home-manager has no module.

### Ghostty 1.3.1

- No bidi. HarfBuzz is forced to LTR (`src/font/shaper/harfbuzz.zig:280`: "for now, we force LTR because our renderers assume a strictly increasing X value").
- Mitchell Hashimoto, 2024-02-02 ([#1442](https://github.com/ghostty-org/ghostty/issues/1442#issuecomment-1924142033)): he does not plan to implement the terminal-wg spec "in the near term", but is open to partial shaping-only RTL.
- Community PR [#11079](https://github.com/ghostty-org/ghostty/pull/11079) ("add RTL shaping for Arabic and Hebrew"), opened 2026-02-28, is still open and unmerged (last update 2026-10-05). [Discussion #12624](https://github.com/ghostty-org/ghostty/discussions/12624) builds on it.
- Observed: words are reversed and letters do not join properly.
- home-manager has `programs.ghostty`; it is already enabled here.

### foot 1.28.0

- No shaping across cells and no bidi.
- dnkl, 2021-10-20 ([foot#756](https://codeberg.org/dnkl/foot/issues/756#issuecomment-271635)): "Foot currently has zero support for text shaping across cells … there's no plan to implement this."
- Observed: isolated, unjoined forms in logical order, and most of the vocalised Quran letters were missing.
- home-manager has `programs.foot`.

### Alacritty 0.17.0

- No bidi, shaping or ligatures ([#663](https://github.com/alacritty/alacritty/issues/663), [#50](https://github.com/alacritty/alacritty/issues/50)).
- chrisduerr, 2024-01-12 ([comment](https://github.com/alacritty/alacritty/issues/663#issuecomment-1888434805)): "extremely little interest in adding this … I recommend using a different terminal emulator."
- Not rendered locally.
- home-manager has `programs.alacritty`.

### Contour 0.6.3.8249 (upstream 0.7.0.8982, 2026-08-17)

- It has complex-script shaping. In `docs/internals/text-stack.md`: "Bidirectional text was not addressed in this document nor in the implementation"; `docs/vt-extensions/unicode-core.md`: "Right-to-left (RTL) text is explicitly not handled".
- Not rendered locally.
- home-manager has no module.

### Others

- Rio 0.5.28: there is no bidi code in `rio-vt`.
- QTerminal/qtermwidget 2.4.0: inherited old-Konsole Qt run-level bidi (`setBidiEnabled`, default true), without the newer ICU shaping and table override.
- mintty (Windows) and Terminal.app (macOS) have bidi but do not run on this machine.

## Comparison

"TUI-safe" means the two-pane, tmux and helix tests all stayed readable and in place.

| terminal (nixpkgs) | shaping | lam-alef | bidi | spec escapes | Uthmani marks | TUI-safe | GPU | ligatures | images | HM module | maintenance |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Konsole 26.08.1 | yes (ICU) | split into 2 forms | yes, default on, per line, LTR or first-strong | none | all present | **yes** (box-drawing override) | no | yes (word mode) | sixel, iTerm2, kitty APC | no (plasma-manager only) | KDE Gear, active |
| WezTerm 2026-09-17 | yes (HarfBuzz) | true ligature | yes, default **off**, conformant UBA | BDSM, SCP | all with DejaVu Sans Mono; letters dropped with default font | cat and tmux yes; **helix no** (words reversed) | yes | yes | kitty, sixel, iTerm2 | yes | no tag since 2024-02; commits continue |
| VTE 0.84.1 (Ptyxis, GNOME Terminal) | presentation forms | not formed | yes, default on, per paragraph | BDSM, SCP, 2500, 2501, 1243 | present, cramped | **no** (panes swap, tmux spill) unless the app sends `CSI 8 l` | GSK | no | sixel off | ptyxis, gnome-terminal | GNOME, active |
| mlterm 3.9.4 | yes (FriBidi / HarfBuzz) | 2 columns | yes, autodetect + right-align | none | present | **no** in helix (row mirrored) | no | n/a | sixel, ReGIS | no | active, 3.9.5 not in nixpkgs |
| kitty 0.49.0 | within words | gap | none | none | scrambled | n/a | yes | yes | kitty | yes | very active |
| Ghostty 1.3.1 | broken (forced LTR) | no | none (PR #11079 open) | none | scrambled | n/a | yes | yes | kitty | yes | very active |
| foot 1.28.0 | none | no | none | none | letters missing | n/a | no | no | sixel | yes | active |
| Alacritty 0.17.0 | none | no | none (won't) | none | not tested | n/a | yes | no | none | yes | active |
| Contour 0.6.3 | yes | not tested | none | none | not tested | n/a | yes | yes | sixel | no | active |

## Recommendation

**Konsole.** Make it the default terminal and remove kitty.

- It is the only terminal that passed every test: `cat`, the Quran lines with all their marks, the pane layout, helix and a tmux split. It worked with the default font.
- It needs nothing installed, and its bidi is already on by default.
- The box-drawing override is what keeps tmux and TUI borders intact when the TUI never sends a bidi escape, and none of the TUIs here do.
- Trade-offs accepted:
  - No GPU rendering. QPainter is slower for very fast output.
  - Lam-alef shows as two joined letters rather than the ligature.
  - Bidi runs per screen line, so a wrapped RTL paragraph can lay out differently on each visual line.
  - No BDSM opt-out, so a bidi-aware app cannot ask for raw mode.
  - Space-padded Arabic columns (multi-column `ls`) reorder across the gaps, as in every implicit-mode terminal.
  - kitty-only extras are lost: the kitty kitten ecosystem, `kitten ssh`, `icat` fidelity, and remote control. Konsole handles kitty-graphics APC; how much of the protocol it covers was not checked.
  - Light/dark theme following is not kitty's `*.auto.conf` mechanism; it was not verified for Konsole.
- Runner-up: **WezTerm** with `bidi_enabled = true` and a font that has Arabic glyphs. It gives better glyphs (a real lam-alef ligature), keeps GPU rendering, ligatures and kitty graphics, and honours BDSM and SCP. It is not first because:
  - helix rows showed words reversed;
  - the bidi is labelled experimental and is undocumented outside the changelog;
  - there has been no tagged release for 2.5 years.
  - Choose it over Konsole only if GPU rendering and the kitty protocols matter more than reading Arabic inside the editor.
- Not VTE, despite being the spec's reference implementation: with implicit mode on and no TUI sending `CSI 8 l`, it scrambles tmux splits and box layouts. It also forms no ligatures, programming or lam-alef.
- Not mlterm: its auto-detection mirrors whole TUI rows, its configuration is dated, and there is no HM module.

## Change needed

In `modules/terminals.nix`:

- remove `programs.kitty` and the three `kitty/*-theme.auto.conf` entries;
- add a Konsole profile and make it the default. Konsole's bidi defaults are already right, so the profile only pins the font and makes the defaults explicit.

```nix
{ config, ... }:
let
  inherit (config) owner;
in
{
  flake.modules.nixos.terminals =
    { lib, pkgs, ... }:
    {
      home-manager.users.${owner.username} = {
        programs.ghostty = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
        };

        xdg.dataFile."konsole/Main.profile".text = lib.generators.toINI { } {
          General = {
            Name = "Main";
            Parent = "FALLBACK/";
          };
          Appearance.Font = "DejaVu Sans Mono,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
          "Terminal Features" = {
            BidiRenderingEnabled = true;
            BidiLineLTR = true;
            BidiTableDirOverride = true;
          };
        };

        home.activation.konsoleDefaultProfile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file konsolerc \
            --group "Desktop Entry" --key DefaultProfile Main.profile
        '';
      };
    };
}
```

Notes on that change:

- `konsolerc` is set with `kwriteconfig6` rather than linked from the store. Konsole rewrites `konsolerc` (window state), and KConfig's rename-on-save would replace a store symlink. If Konsole's profile editor is used, it has the same effect on `Main.profile`, so change the profile in Nix only.
- Pick the font deliberately. DejaVu Sans Mono has Arabic glyphs and matches the WezTerm test. Hack, the current `monospace`, falls back for Arabic, which also rendered correctly in Konsole. Uthmani marks always come from Noto Naskh Arabic, which is installed.
- Colours: Konsole ships no gruvbox. Add `xdg.dataFile."konsole/Gruvbox.colorscheme"` and set `Appearance.ColorScheme = "Gruvbox"`; that file was not written as part of this research.
- `modules/hardware/laptop.nix`: change `kitty` to `konsole` in the earlyoom `--avoid` regex.
- Plasma's default terminal is Konsole unless it was changed in System Settings (`kdeglobals` `[General] TerminalApplication`); nothing in this repo sets it.
- For WezTerm instead: set `programs.wezterm.enable = true` and add `extraConfig` with `bidi_enabled = true`, `bidi_direction = "LeftToRight"`, and `font = wezterm.font_with_fallback({ "DejaVu Sans Mono", "Noto Naskh Arabic" })`.

## Not verified

- Claude Code, Codex and Pi were not run, because they need auth in the sandbox. Their bordered input boxes rely on the same box-drawing behaviour as the two-pane test, so Konsole should hold, but this is untested.
- Cursor placement, mouse selection and copy within RTL text, and typing Arabic through the `ara` XKB layout, were not tested in any terminal.
- All renders used software rendering (pixman and llvmpipe) at 1280×720. GPU paths and HiDPI on the NVIDIA session were not exercised.
- Not rendered at all: Alacritty, Contour, GNOME Terminal and GNOME Console. GNOME Terminal and GNOME Console share VTE 0.84.1 with Ptyxis, so they should behave the same.
- Wrapped long RTL paragraphs (Konsole per-line vs VTE per-paragraph) were not tested visually.
- How much of the kitty graphics protocol Konsole implements, and whether Konsole switches light/dark themes automatically.
- In the tmux test, the right-hand pane lost the harakat in Konsole, VTE and WezTerm alike, so the cause is likely tmux 3.7c, not the terminal. The cause was not investigated.
- The WezTerm helix failure (words reversed) was observed, but its cause in wezterm's run splitting was not traced.
