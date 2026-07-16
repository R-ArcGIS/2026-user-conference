library(sf)
library(dplyr)
library(arcgis)
library(ggplot2)

set_arc_token(auth_user())

# confirm your user
me <- arc_user_self()

# access your user properties
me$fullName
me$groups[c("id", "title", "access")]

# find a group by id
rgroup <- arc_group("620d3c1422d540c2a255f26e341e4c9f")
rgroup

# list the group's content
group_items <- arc_group_content(rgroup$id)

# items owned by the group
group_items |>
  select(title, type)

# retrieve the Oaks layer from the group's content
oaks_layer <- group_items |>
  filter(title == "DC Oaks - Ward 2") |>
  pull(id) |>
  arc_open() |>
  get_layer(id = 0)

# find your Arborist Zones boundary item
my_items <- search_items(
  query = "Arborist Zones",
  owner = me$username,
  type = "Feature Service"
)

# check that one private item was returned
my_items[c("title", "access", "id")]

# retrieve the Arborist Zone feature from your content
zone_feature <- my_items |>
  slice(1) |>
  pull(id) |>
  arc_open() |>
  get_layer(id = 0) |>
  arc_select()

# Section 3: read only the public trees data that intersect the private boundary feature
filtered_oaks <- arc_select(
  oaks_layer,
  filter_geom = st_geometry(zone_feature)
)

ggplot() +
  geom_sf(data = zone_feature, fill = NA, color = "black", lwd = 0.5) +
  geom_sf(aes(color = COMMON_NAME), filtered_oaks, size = 2, alpha = 0.5) +
  theme_void() +
  labs(color = "Common Name")
