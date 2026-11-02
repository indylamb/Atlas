# Atlas backend

- **Provider:** Supabase
- **Project:** "Atlas", ref `lhkzrnlerdeoghwxktme`, region us-east-1
- **API URL:** https://lhkzrnlerdeoghwxktme.supabase.co
- **Status (2026-11-02):** empty, no tables yet. The schema arrives in slice 2.

The publishable (anon) key is safe to ship in the app. It goes in `Atlas/Config/Supabase.swift` when slice 2 starts. Never commit the service-role key or any secret key.

All access control lives in Postgres row-level security, so the app can only read the takes a user is allowed to see. The AI in slice 5 must go through the same rules.
