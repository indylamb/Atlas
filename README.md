# Atlas

A private map of places your friends vouch for.

## Run it

1. Open `Atlas.xcodeproj` in Xcode 16 or newer.
2. Pick an iPhone simulator (iOS 18+) and press Run (⌘R).
3. On your own iPhone: select the Atlas target, open Signing & Capabilities, choose your Team (a free Apple ID works), then plug in the phone and Run.

## What's here (slice 1)

The v2 prototype built natively on Apple Maps, with sample New York data:

- Home map: your spots (black), friends' spots (their colors, stacked when several saved one), Apple Maps places no one saved (tap any to open it).
- Spot half sheet: rating with half stars, tags, your note, friends' takes.
- Filters: Tags, Rating, Saved by, each with More.
- Send: outline the screen, Send *N*, pick a friend.
- Receive: the badge on the Send button, Allison's map, Save one or Save all, List view.

Sending is local only until slice 3. See `CLAUDE.md` for how the code is organized and what comes next.

`archive/april-prototype/` holds the earlier April 2026 prototype for reference. It isn't built.
