# Putting the R in ArcGIS — Outline

Scenario: DC Department of Urban Forestry. Residents report problem trees
via Survey123 at the top of the session; the workshop builds a hosted
tree inventory, grows it live from those reports, and finishes by routing
crews to the newly reported trees.

## Session flow

- **Kickoff — Survey123**
  - Audience submits DC tree problem reports live (geometry + request
    type only, no attachments/photos — the form doesn't support them by
    design)
  - QR code on slide, extent-locked to DC, streams to a hosted layer

- **What is the R-ArcGIS Bridge** (existing slides, capability grid incl.
  `{arcgisrouting}`)

- **App reveal** — mini-AGOL Shiny app (motivate, showcases
  `arcgislayers`/`arcgisgeocode`/`calcite`)

- **Demo 1 — Read + Publish** (`01-read-data.R`)
  - Connect to public DC tree inventory (no auth), explore fields
  - Filter to oaks, Ward 2
  - Stamp a `modified_at` column
  - Publish subset as a new hosted layer: `sprintf("trees-%s", ulid::ulid())`
  - → this published layer becomes "the arborist inventory" the rest of
    the session acts on

- **Demo 2 — Portal + Content Browsing** (`02-connect-to-arcgis-online.R`)
  - `.Renviron` + `auth_user()` portal auth
  - Browse user/groups
  - `search_items()` to find the layer just published in Demo 1
    (continuity beat)
  - Spatial filter against the "Arborist Zones" boundary layer

- **Demo 3 — Attachments aside** (`03-attachments.R`)
  - Explicit "different capability, different dataset" callout — this
    workshop's Survey123 form has no attachments by design
  - Canned/old attachment dataset: `query_layer_attachments`,
    `download_attachments`
  - Quick, honest aside — not forced into the live-data story

- **Demo 4 — Add features from citizen reports** (`04-add-features.R`)
  - Pull the audience's live Survey123 tree reports
  - Stamp `modified_at`, align schema to the trees layer
  - `add_features()` the reports into the layer published in Demo 1
  - Payoff: "the arborist inventory grows live from citizen reports"

- **Demo 5 — Reverse geocode** (`05-reverse-geocode.R`)
  - Reverse-geocode the trees layer's points to get addresses
  - Duplicates from re-running are fine — live demo, not production data

- **Demo 6 — Routing finale** (`06-routing-finale.R`)
  - Cap/sample citizen-reported stops (fallback to a pre-seeded set if
    too few submissions — the solve is never allowed to break on stage)
  - `find_service_areas()` — isochrones from the crew depot
  - `route_vehicles()` — VRP, optimized multi-stop crew route
  - `publish_layer()` the resulting route back to AGOL

- **Back to the app + survey** — audience requests now served, shown in
  the app

- **Resources & wrap**

## Open items

- `04-add-features.R`: real field mapping between the Survey123 report
  schema and the trees layer schema (currently a TODO/placeholder)
- `06-routing-finale.R`: real DC Urban Forestry depot coordinates, and a
  pre-seeded fallback stop set for the low-submission guardrail
- Confirm `publish_layer()`'s return shape so later demos can grab the
  item id directly instead of via `search_items()`

## Reference demos

- `/Users/josiahparry/github/r-bridge/2026-dev-summit/full-stack-spatial/*.R`
- `/Users/josiahparry/github/r-bridge/2026-dev-summit/r-powered-arcgis-apps/*.R`
- `/Users/josiahparry/github/r-bridge/2025-dev-summit/04-survey123-attachments.R`
- `/Users/josiahparry/github/r-bridge/2025-user-conference/attachments.R`
- `/Users/josiahparry/github/r-bridge/2025-user-conference/happy-place.R`
