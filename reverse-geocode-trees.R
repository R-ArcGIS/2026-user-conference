library(arcgis)

all_pts <- arc_open(
  "https://analysis-1.maps.arcgis.com/home/item.html?id=df3a3fcddf4e48dba9bd5bf38cf7babb"
) |>
  get_layer(0) |>
  arc_select()


locs <- reverse_geocode(all_pts$geometry)
