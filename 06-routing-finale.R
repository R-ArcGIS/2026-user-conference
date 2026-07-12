# Routing finale: isochrones -> VRP -> publish crew route -----------------
#
# Route DC arborist crews to the citizen-reported trees from Module 4/5.
# Two beats:
#   (a) service areas (isochrones) from the crew depot, to see drive-time
#       bands covering the reports
#   (b) vehicle routing problem (VRP) to build an optimized multi-stop
#       crew route, which we publish back to AGOL

library(arcgisrouting)
library(arcgislayers)
library(sf)
library(dplyr)

set_arc_token(auth_user())

# TODO: set the real crew depot location for DC Urban Forestry
depot <- st_sf(
  name = "DC Urban Forestry Depot",
  geometry = st_sfc(st_point(c(-77.0369, 38.9072)), crs = 4326)
)

# reports_with_addresses comes from 05-reverse-geocode.R
# cap/sample the stops so the VRP solve stays fast and reliable on stage,
# and fall back to a pre-seeded set if too few of the audience submitted
MAX_STOPS <- 10

stops <- reports_with_addresses |>
  slice_head(n = MAX_STOPS)

if (nrow(stops) < 3) {
  # TODO: point at a pre-seeded fallback dataset of DC tree reports
  # so the finale never breaks on stage for lack of live submissions
  stop("TODO: load pre-seeded fallback stops")
}


# (a) Isochrones from the depot -------------------------------------------

service_areas <- find_service_areas(
  facilities = st_geometry(depot),
  default_breaks = c(5, 10, 15),
  impedance = "travel_time"
)

service_areas


# (b) Vehicle routing problem: one crew truck, multi-stop route -----------

orders <- st_sf(
  name = stops$match_addr,
  geometry = st_geometry(stops)
)

depots <- depot

routes <- data.frame(
  name = "Crew Truck 1",
  start_depot_name = depot$name,
  end_depot_name = depot$name,
  capacities = "1"
)

vrp_result <- route_vehicles(
  orders = orders,
  depots = depots,
  routes = routes,
  populate_directions = TRUE
)

vrp_result$solve_succeeded
vrp_result$stops
vrp_result$routes


# Publish the optimized route back to AGOL ---------------------------------

route_layer_name <- sprintf("crew-route-%s", ulid::ulid())

published_route <- publish_layer(
  vrp_result$routes,
  title = route_layer_name
)

published_route
