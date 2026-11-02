# Atlas

A private map of places your friends vouch for. Network and locals over generic AI and public reviews.

- Product plan and decisions: https://claude.ai/artifact/KrXX51vr7fGbrnPoXQRG3q
- Design system: https://claude.ai/artifact/7FDUpN8Uqqo573aTxu4EXZ
- Prototype: https://claude.ai/artifact/Luz4nDh7dYsz6WsmQ58exD

Indy (PM and designer) makes every product and design decision. The UX and UI will keep changing, so build for change.

## Product rules the code must keep

- Ratings: 0 = Haven't been, 0.5 to 2.5 = Skip, 3 to 4 = Good, 4.5 to 5 = Must hit. Half stars allowed. See `RatingLabel`.
- Skip spots are hidden by default.
- Provenance is private. When you share onward, spots you got from friends carry your name and note, never theirs.
- No public reviews, aggregate scores or review counts anywhere.
- The AI answers only from data the user can already see (their own takes plus maps shared with them).

## Code layout

- `Atlas/DesignSystem/Theme.swift` holds every color, font, spacing and radius. Views never hard-code a color or size; add a token instead.
- `Atlas/DesignSystem/Components/` holds shared pieces (chips, stars, pins, avatars, buttons).
- `Atlas/Models/` holds plain value types: `Place`, `Take`, `Person`, `IncomingMap`.
- `Atlas/Data/AtlasStore.swift` is the only source of data. Slice 1 runs on sample data (`SampleData.swift`). Supabase replaces the sample data behind the same methods in slice 2, so screens shouldn't change.
- `Atlas/Features/<Feature>/` holds one folder per feature: Map (home), Spot (half sheet), Filters, Share (send and receive).
- `MapFilter.swift` holds the pure filtering logic that decides which pins show. Keep it free of SwiftUI so it can be unit tested.

## Conventions

- SwiftUI, iOS 18+, Swift 5 language mode, `@Observable` for state.
- Keep views small. Split any view body over about 80 lines.
- The Xcode project uses folder-synced groups: files added under `Atlas/` are picked up automatically, so never edit `project.pbxproj` by hand to add files.
- Fonts are Apple's New York (serif) and SF Pro (sans) for now. Swapping to custom fonts happens in `Theme.Font` only.

## Slices

1. Native prototype on sample data: home map, spot sheet, filters, send, receive. (current)
2. Supabase: phone sign-in, contacts, schema with row-level security, real places from Apple Maps search.
3. Real sending and receiving: share links, push notifications, live layers.
4. Rate your spots, resharing rules.
5. Ask Atlas (Supabase Edge Function plus an LLM, network data only).
