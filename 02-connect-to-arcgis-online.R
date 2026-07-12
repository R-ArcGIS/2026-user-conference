# install these packages if not done yet
# install.packages(c("arcgis", "sf", "dplyr", "ggplot2" , "usethis"))

# load used packages
library(sf)
library(dplyr)
library(arcgis)
library(ggplot2)

# Module 2: Sign into ArcGIS Online from R -------------------------------

# Section 1: Create an .Renviron file

# Install the usethis package and
# open your .Renviron file from the console
install.packages("usethis")
usethis::edit_r_environ()

# In the .Renviron file, add these variables with your credentials
# ARCGIS_USER=your-username
# ARCGIS_PASSWORD=your-password

# restart the session and confirm that R can read the variables (run in console)
Sys.getenv("ARCGIS_USER")

# Section 2: Authenticate using {arcgisutils}

# generate a token
token <- auth_user()

# delete the arguments above to get:
token <- auth_user()

# register the token
set_arc_token(token)

# Module 3: Browse users and content -------------------------------------

# confirm your user
me <- arc_user_self()

# access another user
ruser <- arc_user("r-bridge-docs")

# access your user properties
me$fullName
me$groups[c("id", "title", "access")]

# find a group by id
rgroup <- arc_group("620d3c1422d540c2a255f26e341e4c9f")
rgroup

# list the group's content
group_items <- arc_group_content(rgroup$id)
glimpse(group_items)

# retrieve the Oaks layer we published at the end of Module 1
# (replace with the `layer_name` printed by publish_layer() in 01-read-data.R)
oaks_item <- search_items(
  query = "trees-",
  owner = me$username,
  type = "Feature Service"
)

oaks_layer <- oaks_item |>
  slice(1) |>
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
