# Attachments aside -------------------------------------------------------
#
# Our Survey123 form for this workshop does NOT collect attachments
# (no photo uploads, on purpose). This demo shows the attachment workflow
# on a different, pre-existing Survey123 dataset that does have photos.

library(arcgislayers)
library(dplyr)

# authenticate to the portal hosting this dataset
token <- auth_user(
  "jparry_ANGP",
  host = "https://arcgis.com"
)
set_arc_token(token)

# URL to a Survey123 feature service with attachments
furl <- "https://services1.arcgis.com/hLJbHVT9ZrDIzK0I/arcgis/rest/services/v8_Wide_Area_Search_Form_Feature_Layer___a2fe9c/FeatureServer/0"

# create a reference to it in R
layer <- arc_open(furl)
layer

# query the attachments of a layer using query_layer_attachments()
# by default this returns metadata about every attachment in the service
att <- query_layer_attachments(layer)
glimpse(att)

# read in the original feature data
all_records <- arc_select(layer)

# check the follow up status
count(all_records, followup_status)

# filter attachments based on feature values
query_layer_attachments(
  layer,
  "followup_status = 'needs_followup'"
)

# filter based on attachment metadata itself
query_layer_attachments(
  layer,
  attachments_definition_expression = "att_name like '%20221005%'"
)

# download the attachments to disk
res <- download_attachments(
  att,
  "dev/field_images"
)
res
