# Connect to tree inventory ----------------------------------------------

# Install the required package if necessary
# Uncomment the below line and run it independently.
# install.packages(c("arcgis", "sf", "dplyr", "mapgl"))

# load the required R packages
library(sf)
library(dplyr)
library(arcgislayers)

# Run the below to clear an expired authentication token
# or run into authentication permissions
unset_arc_token()

# store the item ID of the tree's layer
trees_id <- "08bda06465a74cd59a6d4231d882588d"

# Use the arc_open function from arcgislayers to access the item's information
trees_layer <- arc_open(trees_id)
trees_layer

# Get the REST endpoint
trees_layer$url
# [1] "https://maps2.dcgis.dc.gov/dcgis/rest/services/DCGIS_DATA/Urban_Tree_Canopy/MapServer/11"

# we move up the URL one level get the parent service url
mapserver_url <- httr2::url_modify_relative(trees_layer$url, ".")

# open the mapserver to see all layers available
arc_open(mapserver_url)


# Query and explore the trees --------------------------------------------

# list fields from the trees_layer
list_fields(trees_layer) |>
  # pass `n = Inf` to print all rows
  print(n = Inf)

# create a vector of fields of interest that we can subset to
relevant_fields <- c(
  "TREE_ID",
  "COMMON_NAME",
  "SCIENTIFIC_NAME",
  "GENUS_NAME",
  "WARD"
)

# `fields` takes a vector of field names we want to select
# `where` is an optional SQL where clause that lets us subset rows
# `geometry = FALSE` ensures that geometry is returned
# this is useful for exploring the attributes before querying geometries
# Note: this may take 10-45 seconds
# oaks <- arc_select(
#   trees_layer,
#   fields = relevant_fields,
#   where = "GENUS_NAME = 'Quercus'",
#   geometry = FALSE
# )
# nrow(oaks)

# we will subset to only ward 2 for a much more managable dataset
# each request needs to send all of the rows over the internet
# only request the data you will use to make your analysis faster!
oaks <- arc_select(
  trees_layer,
  fields = relevant_fields,
  where = "GENUS_NAME = 'Quercus' AND WARD = '2'"
)

# we now get ~14k features
# nrow(oaks)

# make a quick plot to check your data
mapgl::maplibre_view(oaks, column = "COMMON_NAME")


# Publish the Ward 2 oaks as a new hosted layer --------------------------

# authenticate so we can publish content to our portal
set_arc_token(auth_user(expiration = 120))

# give the published layer a unique name so it doesn't collide with
# everyone else's copy at the workshop
layer_name <- sprintf("trees-%s", ulid::ulid())


published <- publish_layer(
  # track when the data was modified
  mutate(oaks, modified_at = Sys.time(), .before = geometry),
  title = layer_name
)

published
