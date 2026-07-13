
## LLM Text


Locked in. Here's the revised outline reflecting your four calls — the biggest change is dropping the {arcgisbinding} live demo (now a slide mention only), which actually tightens the session: everything now stays in the R console + web app + ArcGIS Online, with no context-switch out to ArcGIS Pro.
Putting the R in ArcGIS — Final Outline (v2)
Scenario: DC Department of Urban Forestry. Residents report problem trees; the audience files those requests live via Survey123 at the top, and in the finale we reverse-geocode and route crews to their exact points.
Time budget (~42 min + 3 min live-demo buffer = 45; ~15 left for Q&A)
#	Section	Owner	Min
1	Survey123 kickoff — audience drops a DC tree request	Both	3
2	
What is the R-ArcGIS Bridge? + What's new (routing) — {arcgisbinding}/GP-service shown here as a capability
	Josiah	5
3	App reveal — the Calcite/Shiny "mini AGOL in R" (motivate)	Josiah	3
4	Demo B — {arcgislayers}: read/write feature services (filter + SQL, edit, publish)	Martha	6
5	Demo C — {arcgisutils} + attachments: portal search → download the audience's Survey123 records & photos	Josiah	6
6	Demo D — {arcgisgeocode}: reverse-geocode the audience points	Martha	4
7	Demo E — {arcgisrouting} FINALE: isochrones → VRP → publish route layer	Josiah	9
8	Back to the app + survey — audience requests now served	Both	3
9	Resources & wrap	Both	3
What changed from v1

Routing finale = two beats: (a) travel-time isochrones from the crew depot to assign requests to drive-time bands, then (b) Vehicle Routing Problem to build the optimized multi-stop crew route and publish it back to AGOL.
Live-with-guardrails is baked into the kickoff + finale (details below).
Guardrails for the live audience data
Survey123 form is extent-locked to DC; points stream to a hosted layer, viridis by request type.
Collected at the very start so there's ~35 min of runway before the finale needs them.
Finale caps/samples to N stops, snaps/clips to the DC extent, and falls back to a pre-seeded request set if too few submit — the solve is never allowed to break on stage.
Speaker split (proposed, easily adjustable)
Josiah: app reveal → portal + attachments → routing finale (one continuous arc).
Martha: {arcgislayers} read/write + reverse-geocode.
Shared: kickoff, framing, wrap. (Happy to shift more stage time to you if you'd like.)
Deck actions
Add {arcgisrouting} to the capability grids (slides 9/24) and build real finale slides from the placeholder demo layouts (45–48).
Keep: capability grids, package one-pagers (10–11, 35–39), what's-new (25), what's-coming (26), summary/resources (16, 18).
Re-thread demo slides (12–15) onto the single DC tree-request story; park the unused template block (40–69).
This gives us a clean, flashy spine end-to-end. I'd suggest we build the Shiny app + R demo scripts next, since the slide demo sections should wrap around whatever the code actually shows on screen — then the slides come together fast. Say the word and I'll start on the demo code, or if you'd rather shape up the slides first, I can go there instead.


## Outline

- Survey123 post (put the qr code in the slides)
- What is the R-ArcGIS Bridge (exisiting slides)
- mini AGOL shiny app
  - I want to mativate this sesssion by first starting with an demo of a full stack shiny application that is made with the R-ArcGIS Bridge
  - This application demonstrates only _some_ of the breadth of the R-ArcGIS Bridge. Notably it demonstrates the following packages (read from the about page)