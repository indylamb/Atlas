# Atlas design system

The repo's copy of the design system (draft v0.2), for coding sessions. It's edited visually at https://claude.ai/artifact/7FDUpN8Uqqo573aTxu4EXZ (pinned in Indy's claude.ai sidebar), and every change there is copied here. In code, the tokens live in `Atlas/DesignSystem/Theme.swift`, which must match this file.

Last synced: 2026-11-19.

## Direction: Uber meets The New York Times meets Notion

- **Uber: the map and the controls.** Grayscale map, white pill search bar, round black buttons, bold sans labels. Chrome stays monochrome so friend colors are the only color on screen.
- **The New York Times: the words.** Spot names and screen titles in a serif (`display`). Friends' notes set as italic pull quotes (`quote`). Sections open with small-caps kickers and are divided by hairline rules, not boxes.
- **Notion: the details.** A spot's facts are a property list: gray labels left, values right. Thin outline icons on warm-gray tiles. Plain toggles and segmented controls with 6px corners.

## Principles

- **Provenance first.** A friend's color is on every pin, dot and row that came from them.
- **Ratings speak in words.** Stars are the input; Must hit, Good, Skip or Haven't been is the output.
- **Monochrome by default, one loud thing.** Color is reserved for friends and Must hit.
- **Nothing that looks like public reviews.** No review counts, no aggregate scores.

## Color

| Token | Light | Dark | Use |
| --- | --- | --- | --- |
| `surface` | #FFFFFF | #191919 | Sheets, panels, search bar |
| `surface-raised` | #F6F6F4 | #252525 | Chips at rest, icon tiles, inputs |
| `ink` | #111111 | #F2F2F0 | Text, primary buttons, your own pins |
| `on-ink` | #FFFFFF | #111111 | Text and icons on ink |
| `ink-muted` | #6B6B68 | #A1A19C | Labels, descriptions, captions |
| `rule` | #E7E7E4 | #2F2F2F | Hairlines, never text |
| `map-land` | #F2F2F0 | #222222 | Map land |
| `map-water` | #DFE6EC | #14202B | Map water |
| `map-park` | #E3ECDF | #1D2A1F | Map parks |
| `unsaved` | #9B9B97 | #6B6B68 | Dots for places no one you know saved (decorative only) |
| `star` | #F0A500 | #F0B429 | Star glyphs, Must hit badge |
| `rating-must` | #8A5A00 | #F0B429 | Must hit label |
| `rating-good` | = ink | = ink | Good label |
| `rating-skip` | = ink-muted | = ink-muted | Skip and Haven't been labels |
| `friend-1` | #C2410C | #FB923C | First friend |
| `friend-2` | #2F7D4F | #4ADE80 | Second friend |
| `friend-3` | #3B5BDB | #7C9CFF | Third friend |
| `friend-4` | #7C3AED | n/a yet | Fourth friend |
| `friend-5` | #0F766E | n/a yet | Fifth friend |
| `friend-6` | #BE185D | n/a yet | Sixth friend |
| `friend-7` | #A16207 | n/a yet | Seventh friend |
| `friend-8` | #475569 | n/a yet | Eighth friend |
| `share-frame` | #111111 | #F2F2F0 | Send-mode border |

## Type

Serif: Newsreader (Apple's New York in the app for now). Sans: DM Sans (SF Pro in the app for now).

| Style | Family | Size / line | Weight | Use |
| --- | --- | --- | --- | --- |
| `display` | serif | 32 / 36 | 500 | Spot names, screen titles |
| `quote` | serif italic | 16 / 22 | 400 | Friends' notes |
| `headline` | sans | 17 / 22 | 600 | Buttons, sheet headers, names in rows |
| `body` | sans | 15 / 21 | 400 | Running text and values |
| `label` | sans | 13 / 18 | 500 | Chips, rating labels, property labels |
| `kicker` | sans | 11 / 14 | 600 | Small-caps section labels, 0.08em tracking |

## Space, shape, shadow

- Spacing: 4, 8, 12, 16, 24 (`space-1` to `space-6`).
- Corners: 6 chips and tiles, 12 panels, 20 sheets, pill for search bar, round buttons and pins.
- Shadows: float `0 4 16 rgba(0,0,0,.12)`; sheet `0 -2 24 rgba(0,0,0,.12)`.

## Rating language

| Stars | Label | On the map |
| --- | --- | --- |
| None | Haven't been | Pin drawn as an outline |
| 0.5 to 2.5 | Skip | Hidden unless filtered in |
| 3 to 4 | Good | Standard pin |
| 4.5 to 5 | Must hit | Pin with a star badge |

## Pins (decision 28)

- Every saved place: a 38pt white disc with the place's Fine line icon in ink.
- A ring around it, 3.5 wide, split evenly into the colors of everyone who saved it: you in ink, friends in their colors, small gaps between segments.
- Three or more people: a small ink count badge, top left.
- Haven't been (no ratings): warm-gray center, muted icon.
- Must hit: star badge, top right.
- Places no one saved: a small gray dot with a white ring.
- In "Saved by" lines, people show as 10pt color dots.

## Open

- Dark-mode values for friend-4 to friend-8.
- Custom fonts or Apple's native New York and SF Pro.
- How many friend layers at once; automatic or chosen friend colors.
