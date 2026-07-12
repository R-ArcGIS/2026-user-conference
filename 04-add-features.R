# Add citizen-reported trees into the published layer ---------------------
#
# The audience submitted DC tree problem reports via Survey123 at the top
# of the workshop. Here we pull those reports and add them as new features
# into the trees layer we published in 01-read-data.R -- the arborist
# inventory grows live from citizen reports.

library(arcgislayers)
library(dplyr)

set_arc_token(auth_user())

# open the layer we published in Module 1
# (replace with the `layer_name` printed by publish_layer() in 01-read-data.R,
# or reuse `oaks_layer` from 02-connect-to-arcgis-online.R)
trees_layer <- oaks_layer

# read the audience's live Survey123 tree reports
reports <- arc_open(
  "https://analysis-1.maps.arcgis.com/home/item.html?id=df3a3fcddf4e48dba9bd5bf38cf7babb"
) |>
  get_layer(0) |>
  arc_select()
glimpse(reports)

# TODO: align the Survey123 report schema to the trees layer schema.
# list_fields(trees_layer) to see what add_features() expects, then
# select()/rename() the report columns to match before adding them.
# e.g.:
# reports_aligned <- reports |>
#   select(
#     COMMON_NAME = <survey-field>,
#     GENUS_NAME  = <survey-field>,
#     WARD        = <survey-field>
#   )
reports_aligned <- reports

# stamp these citizen reports with a modified time, same column
# added to the original inventory in 01-read-data.R
reports_aligned$modified_at <- Sys.time()

# add the citizen reports into the published trees layer
add_res <- add_features(trees_layer, reports_aligned)
add_res
