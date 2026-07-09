# Putting the R in ArcGIS — Esri UC 2026 demo
# Read-only ArcGIS Online content browser, built entirely in R with the
# R-ArcGIS Bridge + Calcite. See PLAN-APP.md for the full scope.
#
# This file is the PAGE SKELETON only: action-bar navigation between three
# panels (Content / Geocode / About), all empty. No item listing / data yet.
#
# Docs:
# https://r.esri.com/arcgisutils/llms.txt
# https://r.esri.com/arcgislayers/llms.txt
# https://r.esri.com/arcgisgeocode/llms.txt
# https://r.esri.com/calcite/llms.txt

library(dplyr)
library(purrr)
library(shiny)
library(arcgis)
library(arcgisgeocode)
library(calcite)
library(mapgl)

# --- Startup auth (runs once) -------------------------------------------------
# Runs as the curated `r-bridge-docs` account. No live login in the app.
set_arc_token(auth_user(expiration = 120))

user <- arc_user_self()

# Fields from arc_user_self() worth surfacing, as a two-column data.frame.
user_df <- data.frame(
  property = c(
    "Full name",
    "Username",
    "User ID",
    "Email",
    "Role",
    "User type",
    "Level",
    "Organization",
    "Credits",
    "Storage used",
    "Last login",
    "Member since"
  ),
  value = c(
    user$fullName,
    user$username,
    user$id,
    user$email,
    user$role,
    user$userType,
    user$level,
    user$orgId,
    format(user$availableCredits, big.mark = ",", scientific = FALSE),
    paste0(round(user$storageUsage / 1e9, 1), " GB"),
    format(user$lastLogin, "%Y-%m-%d %H:%M"),
    format(user$created, "%Y-%m-%d")
  ),
  stringsAsFactors = FALSE
)


# --- User content (fetched once at startup) -----------------------------------
all_items <- arc_user_content(user)

# Preferred display order for item types; anything else follows, in the order
# it appears in the data.
type_order <- c(
  "Feature Service",
  "File Geodatabase",
  "CSV",
  "Feature Collection",
  "Application"
)
present_types <- unique(all_items$type)
item_types <- c(
  intersect(type_order, present_types),
  setdiff(present_types, type_order)
)

# Each item is a calcite_tile with a stable id. The tile fires `input$<id>` on
# every click (event priority), so the server can observe each one directly.
tile_input_id <- function(item_id) sprintf("tile_%s", item_id)

# One accordion section per type, holding a tile group of that type's items.
content_browser <- calcite_accordion(
  id = "my_accordion",
  !!!map(item_types, function(this_type) {
    items <- all_items[all_items$type == this_type, ]
    tiles <- map(seq_len(nrow(items)), function(i) {
      calcite_tile(
        id = tile_input_id(items$id[[i]]),
        heading = items$title[[i]],
        description = items$type[[i]],
        icon = "layer"
      )
    })
    calcite_accordion_item(
      id = sprintf("accordion_%s", heck::to_snek_case(this_type)),
      heading = this_type,
      description = paste(nrow(items), "items"),
      calcite_tile_group(!!!tiles)
    )
  })
)

# --- UI -----------------------------------------------------------------------
ui <- page_actionbar(
  title = "Putting the R in ArcGIS",

  # Main content area: preview of the selected item.
  calcite_panel(
    id = "preview_panel",
    heading = "Preview",
    calcite_block(
      id = "preview_controls",
      heading = "Layer",
      expanded = TRUE,
      collapsible = FALSE,
      uiOutput("layer_select")
    ),
    calcite_block(
      id = "preview_table_block",
      heading = "Preview",
      expanded = TRUE,
      collapsible = FALSE,
      uiOutput("preview_table")
    )
  ),

  # Main content area: geocoding results map (hidden until the Geocode tab).
  calcite_panel(
    id = "map_panel",
    heading = "Geocoded results",
    hidden = TRUE,
    htmltools::div(
      style = "position: relative; height: 100%;",
      maplibreOutput("map", height = "100%")
    )
  ),

  # Left rail: our three "tabs", plus the authenticated user pinned to the bottom.
  actions = calcite_action_bar(
    id = "nav_bar",
    calcite_action_group(
      calcite_action(
        text = "Content",
        icon = "data",
        text_enabled = TRUE,
        active = TRUE
      ),
      calcite_action(
        text = "Geocode",
        icon = "pin",
        text_enabled = TRUE
      ),
      calcite_action(
        text = "About",
        icon = "information",
        text_enabled = TRUE
      )
    ),
    calcite_action_group(
      slot = "bottom-actions",
      calcite_action(
        text = user$fullName,
        icon = "user",
        text_enabled = TRUE
      )
    )
  ),

  # One panel per tab; only "Content" visible to start.
  panel_content = list(
    calcite_panel(
      id = "content_panel",
      heading = "Content",
      content_browser
    ),
    calcite_panel(
      id = "geocode_panel",
      heading = "Geocode",
      hidden = TRUE,
      calcite_block(
        heading = "Address field",
        expanded = TRUE,
        collapsible = FALSE,
        uiOutput("geocode_field_select")
      ),
      calcite_block(
        heading = "Run",
        expanded = TRUE,
        collapsible = FALSE,
        calcite_button(
          "Geocode addresses",
          id = "geocode_btn",
          icon_start = "pin",
          width = "full",
          appearance = "solid",
          kind = "brand"
        )
      )
    ),
    calcite_panel(
      id = "about_panel",
      heading = "About",
      hidden = TRUE,
      "About the R-ArcGIS Bridge pipeline coming soon."
    ),
    calcite_panel(
      id = "user_panel",
      heading = "User",
      hidden = TRUE,
      calcite_block(
        heading = "Profile",
        expanded = TRUE,
        collapsible = FALSE,
        calcite_table(id = "user_info_tbl", data = user_df, caption = "User")
      )
    )
  )
)


# --- Server -------------------------------------------------------------------
# Every action-bar item maps to the panel it reveals. The bottom user action
# uses the full name as its text, so key it off user$fullName.
panel_for <- c(
  "Content" = "content_panel",
  "Geocode" = "geocode_panel",
  "About" = "about_panel"
)
panel_for[[user$fullName]] <- "user_panel"

server <- function(input, output, session) {
  observeEvent(
    input$nav_bar,
    {
      clicked <- input$nav_bar
      logger::log_info("nav_bar clicked: {clicked}")
      target <- panel_for[[clicked]]
      if (is.null(target)) {
        logger::log_debug("no panel mapped to '{clicked}', ignoring")
        return()
      }
      logger::log_info("showing panel: {target}")
      for (panel in panel_for) {
        update_calcite(panel, hidden = panel != target)
      }

      # Main content area: show the map on Geocode, the preview otherwise.
      update_calcite("map_panel", hidden = clicked != "Geocode")
      update_calcite("preview_panel", hidden = clicked == "Geocode")

      # Render the profile table only when the user action is clicked.
      if (target == "user_panel") {
        logger::log_info("rendering user_info table ({nrow(user_df)} rows)")
        output$user_info <- renderUI({
          calcite_table(data = user_df)
        })
      }
    },
    ignoreInit = TRUE
  )

  # The currently selected item id (NULL until something is clicked).
  selected_item <- reactiveVal(NULL)

  logger::log_shiny_input_changes(input)

  # One observer per tile. Each tile fires `input$tile_<id>` on click.
  walk(all_items$id, function(item_id) {
    observeEvent(input[[tile_input_id(item_id)]], {
      logger::log_info("item selected: {item_id}")
      selected_item(item_id)
    })
  })

  # The selected item's metadata row from all_items.
  selected_row <- reactive({
    req(selected_item())
    all_items[all_items$id == selected_item(), ]
  })

  # Open the selected Feature Service and pull its layers + tables (once per
  # selection). Non-feature-service items yield NULL.
  service_layers <- reactive({
    row <- selected_row()
    if (row$type != "Feature Service" || is.na(row$url)) {
      return(NULL)
    }
    logger::log_info("opening service: {row$title}")
    server_obj <- arc_open(URLencode(row$url))
    get_all_layers(server_obj)
  })

  # Read the selected CSV item into a data frame. Non-CSV items yield NULL.
  csv_data <- reactive({
    row <- selected_row()
    if (row$type != "CSV") {
      return(NULL)
    }
    logger::log_info("reading CSV: {row$title}")
    raw_txt <- rawToChar(arc_item_data(row$id))
    readr::read_csv(I(raw_txt), show_col_types = FALSE)
  })

  # A flat named list of selectable layers/tables: name -> opened object.
  layer_choices <- reactive({
    all_layers <- service_layers()
    if (is.null(all_layers)) {
      return(NULL)
    }
    flat <- c(all_layers$layers, all_layers$tables)
    set_names(flat, map_chr(flat, ~ .x$name))
  })

  # Layer picker: only for feature services with >0 layers/tables.
  output$layer_select <- renderUI({
    choices <- layer_choices()
    if (is.null(choices) || length(choices) == 0) {
      return(calcite_notice(
        open = TRUE,
        kind = "info",
        width = "full",
        message = "Select a Feature Service to preview its layers, or a CSV to preview its rows."
      ))
    }
    nms <- names(choices)
    calcite_select(
      id = "layer_choice",
      label = "Layer",
      values = nms,
      labels = nms,
      value = nms[[1]]
    )
  })

  # Preview: a CSV's rows, or the chosen layer's first 20 rows.
  output$preview_table <- renderUI({
    row <- selected_row()

    # CSV items: preview the parsed rows directly.
    if (row$type == "CSV") {
      df <- csv_data()
      req(df)
      return(calcite_table(
        id = "data_preview",
        data = utils::head(df, 20),
        caption = row$title
      ))
    }

    # Feature Services: preview the chosen layer/table.
    choices <- layer_choices()
    req(choices)
    chosen_name <- input$layer_choice$value %||% names(choices)[[1]]
    lyr <- choices[[chosen_name]]
    req(lyr)
    logger::log_info("previewing layer: {chosen_name}")
    preview <- arc_select(lyr, n_max = 20)
    # Tables have no geometry; only drop it when present.
    if (inherits(preview, "sf")) {
      preview <- sf::st_drop_geometry(preview)
    }
    calcite_table(id = "data_preview", data = preview, caption = chosen_name)
  })

  # --- Geocoding ---------------------------------------------------------------
  # Field picker: the columns of the selected CSV (character columns first).
  output$geocode_field_select <- renderUI({
    df <- csv_data()
    if (is.null(df)) {
      return(calcite_notice(
        open = TRUE,
        kind = "info",
        width = "full",
        message = "Select a CSV in the Content tab to geocode one of its fields."
      ))
    }
    cols <- names(df)
    calcite_select(
      id = "geocode_field",
      label = "Address field",
      values = cols,
      labels = cols,
      value = cols[[1]]
    )
  })

  # Geocode the chosen field on button click (1 candidate each, no credits).
  geocoded <- reactiveVal(NULL)

  observeEvent(input$geocode_btn$clicks, {
    req(input$geocode_btn$clicks > 0)
    df <- csv_data()
    req(df, input$geocode_field$value)

    field <- input$geocode_field$value
    logger::log_info("geocoding {nrow(df)} rows on field '{field}'")

    result <- find_address_candidates(
      address = as.character(df[[field]]),
      max_locations = 1L
    )
    logger::log_info("geocoded {nrow(result)} candidates")
    # Keep only simple columns mapgl can serialize to GeoJSON.
    result <- result[, c("match_addr", "score")] |>
      dplyr::filter(!sf::st_is_empty(result))
    geocoded(result)
  })

  # Render the geocoded points on a map.
  output$map <- renderMaplibre({
    pts <- geocoded()
    m <- maplibre(
      esri_style("streets", token = arc_token()),
      attributionControl = FALSE
    )
    if (is.null(pts) || nrow(pts) == 0) {
      return(m)
    }
    m |>
      add_circle_layer(
        id = "geocoded",
        source = pts,
        circle_color = "#007ac2",
        circle_stroke_color = "#00465c",
        circle_stroke_width = 0.5,
        circle_radius = 6,
        circle_opacity = 0.85
      ) |>
      fit_bounds(pts, animate = FALSE)
  })

  # These outputs live in panels that start hidden; render them anyway.
  outputOptions(output, "geocode_field_select", suspendWhenHidden = FALSE)
  outputOptions(output, "map", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
