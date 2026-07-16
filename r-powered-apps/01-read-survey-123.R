library(arcgis)

item_id <- "df3a3fcddf4e48dba9bd5bf38cf7babb"

# see the layers in the feature server
srvr <- arc_open(item_id)
srvr

# get a layer based on ID
survey <- get_layer(srvr, 0)
survey

# read the resuls into R directly
res <- arc_select(survey)

# extract the date
to_plot <- res |>
  mutate(date = as.character(lubridate::floor_date(CreationDate, "days")))

# visualize
mapgl::maplibre_view(to_plot, column = "date")
