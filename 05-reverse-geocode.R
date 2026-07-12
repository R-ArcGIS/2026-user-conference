# Reverse geocode the newly added citizen reports --------------------------

library(arcgislayers)
library(arcgisgeocode)
library(dplyr)
library(sf)

set_arc_token(auth_user())

# open the trees layer (published in 01, added to in 04)
trees_layer <- oaks_layer

# pull the trees layer; duplicates from re-running this are fine, we're
# only using it for a live demo, not a production dataset
new_reports <- arc_select(trees_layer)

# reverse-geocode the report locations to get addresses
addresses <- reverse_geocode(new_reports$geometry) |>
  st_drop_geometry() |>
  select(match_addr)

# combine the addresses back onto the report attributes
reports_with_addresses <- bind_cols(new_reports, addresses)

reports_with_addresses
