library(arcgis)
library(sf)
library(arcgisrouting)

set_arc_token(auth_user())

available_travel_modes <- get_travel_modes()
available_travel_modes

# calculate centroid of all provided trees
tree_centroid <- st_centroid(st_combine(locs$geometry))

# define the Geoprocessing Job
isochrone_job <- find_service_areas_job(
  tree_centroid,
  break_values = c(5, 10, 15, 30),
  break_units = "minutes",
  travel_mode = "Walking Time"
)

# start the job
# notice the job has a status and an id now
isochrone_job$start()

# we can chec the status
isochrone_job$status

# get the results
# isochrone_job$results

# if we wanted to just wait until it is complete
# and fetch results at one time
results <- isochrone_job$await()


mapgl::maplibre_view(results$service_areas, column = "FromBreak") |>
  mapgl::add_circle_layer(
    "centroid",
    tree_centroid,
    circle_color = "#fefefe"
  ) |>
  mapgl::add_circle_layer("tree-locs", locs)
