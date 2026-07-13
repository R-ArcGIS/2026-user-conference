library(dplyr)
library(arcgis)


dc_items <- search_items("DC Tree Pruning Requests", owner = "mbass_ANGP")

# preview items
dc_items |>
  select(title, type, id)


# get item id
item_id <- dc_items |>
  filter(
    type == "Feature Service",
    stringr::str_detect(title, "result")
  ) |>
  pull(id)

item <- arc_item(item_id)

# how many views?
item$numViews

# read all responses
to_geocode <- arc_open(item_id) |>
  get_layer(0) |>
  arc_select()


locs <- reverse_geocode(to_geocode$geometry)

map <- mapgl::mapboxgl_view(locs)
