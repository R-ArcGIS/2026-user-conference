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
