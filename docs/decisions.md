# Atlas product decisions

The build's copy of the decision log. The discussion happens in the product plan (https://claude.ai/artifact/KrXX51vr7fGbrnPoXQRG3q), and every decision made there is copied here. A decision made during a coding session gets added here too, with the date, and flagged to Indy.

Last synced: 2026-11-04.

## North star

Atlas puts the knowledge of your network and of locals ahead of generic AI and public reviews. Every recommendation comes from someone you know, or someone they trust.

- **Provenance is the product.** Who said it stays visible wherever privacy allows.
- **Pull, not broadcast.** No public feed, followers or likes.
- **Near-zero effort to give.** Sharing is about one tap; filtering is optional.
- **Places, not city lines.** Shares follow what's on screen.
- **AI only answers from your network.**
- **Your experience refines the map.**

## Core model

- **Place:** a real location, shared by everyone. Keyed by Apple Maps place ID from slice 2.
- **Take:** one person's relationship to a place: rating (0 = Haven't been), note, tags, and a private "via" source.
- **Shared map:** a live window onto a friend's takes in an area, with the filters they chose.
- **View:** a saved mix of your map, friend layers and filters (for example, "Rio, Dec 2026").
- **Request:** asking a full-access friend for one of their maps (later).

## Rating scale

| Stars | Label | Default behavior |
| --- | --- | --- |
| None | Haven't been | Shown, drawn as an outline |
| 0.5 to 2.5 | Skip | Hidden from maps and shares unless filtered in |
| 3 to 4 | Good | Shown |
| 4.5 to 5 | Must hit | Shown with a star badge |

## Decisions

| # | Decision | Choice |
| --- | --- | --- |
| 1 | How a share starts | Text a link first. Later, full-access friends can see your map list and request one. |
| 2 | Rating | 1 to 5 stars, half stars, labels as above. |
| 3 | Snapshot or live | Live: a friend's later additions show up. |
| 4 | Sender effort | Default is "send what's on screen." Filtering is optional. |
| 5 | Resharing | Onward shares can include spots you got from friends, carrying your name and note, never theirs. Can be filtered out. |
| 6 | Skip spots | Travel with a share, hidden by default. |
| 7 | Recipients | Atlas download required. A link opens straight onto the shared map. |
| 8 | Main story | Sharing is the main story; managing your own maps is part of it. |
| 9 | AI | Trip planning and Q&A grounded only in network data. |
| 10 | Friend tiers | Friends you've added, plus full-access friends you choose. |
| 11 | Merged view | A color per friend; stacked dots when several saved a spot. |
| 12 | Ended shares | Spots you saved stay when a friend stops sharing. |
| 13 | Sign-in and finding friends | Phone number and contacts. |
| 14 | Tags in shares | Tags come with a share; the recipient can keep or remove them. |
| 15 | Logging visits | By hand, plus a Rate your spots screen for every unrated spot. |
| 16 | Backend | Supabase project "Atlas" (see `docs/backend.md`). |
| 17 | AI in V1 | Included, built as the last V1 slice. |
| 18 | Home screen | One pannable, zoomable map: your spots, friends' spots, Apple Maps places no one saved. |
| 19 | Spot detail | Half-screen sheet: icon, name, description, who saved it, your rating, tags, note, then friends' takes. |
| 20 | Filters | Panel under the search bar: Tags, Rating, Saved by. Each has a quick action and More. |
| 21 | Sending | Send button outlines the screen; becomes Cancel and Send N; Filters stays available; Send asks who, with friend search. |
| 22 | Receiving | Send button carries the notification badge. Opening a friend's map shows only their spots. Save one (unrated by default) or Save all, from map or list, after filtering if wanted. Back on your map, their takes stay under Saved by. |
| 23 | Map data | Apple Maps (MapKit) for the map and places. Places store a source and source ID so another provider (such as Google) can be added later if travel coverage is thin. |
| 24 | Photos on takes (2026-11-04) | A take can include photos, alongside stars, tags and a note. Prototype shows up to 6. |
| 25 | Adding tags (2026-11-04) | Tags must be easy to add from the spot sheet: type to search your existing tags, or create a new one in one tap. Tags can be removed from the same row. |
| 26 | Playlists (2026-11-04) | A playlist is an ordered sequence of places, a day someone designs (for example: Wildwood Trail, then Afuri Ramen, then a Timbers game). Build it step by step, add the next stop, drag to reorder, share it. Viewers open it in map mode, stop 1 first, then the next. Working name: Playlists. |

## Open questions

- Icons: pick one of four directions (fine line, bold solid, color tiles, your emoji) on the v3 prototype page.
- Friends on the map: initial disc, photo with color ring, serif monogram, or a ring of friend colors around the place icon.
- Navigation: a bottom tab bar (Map, Playlists, You) or keep one map screen with Playlists reached from it.
- Playlists: can a stop have a time and travel mode? Can friends add to someone's playlist? Is "Playlists" the final name?

- What full access unlocks beyond regular friends.
- When Rate your spots appears: on demand only, or prompted after a trip.
- Friend colors: automatic or chosen; how many layers at once.
- AI model: Apple's on-device model or a cloud model.
- Notifications: what triggers one.
- Done on a received map without saving: keep it as a live layer (current build) or dismiss it.
- Send button: always open the menu (current build) or go straight to send mode when there's nothing new.
