# Putting the R in ArcGIS 

Presenters: 
- Josiah Parry
- Martha Bass


## What is the R-ArcGIS Bridge

- Collection of R packages
- Integrates the R language with the ArcGIS ecosystem
- Modular design
  - Your architecture and workflows guide which package(s) you need
All packages are freely available; ArcGIS Pro license required to use {arcgisbinding}

## Capabilities 

- arcgisutils: authentication and portal integration
- arcgislayers: read and write feature services, attachments 
- arcgisgeocode: fast bulk and reverse geocoding
- arcgisrouting: fleet routing, directions, and travel times
- calcite: shiny app development
- arcgisplaces: access point of interest data
- arcpbf: low-level data reading

## Demo Shiny App

This is a demo of app.R

It will showcase the capabilities of arcgislayers, arcgisgeocode, and calcite.
This will be a quick demo to show the capabilities

## Read a Feature Service with R

this will demo 01-read-data.R which is taken from a recently published learn lesson at. The tutorial has the abstract: 

> In this tutorial, you'll use an R IDE to read data from an ArcGIS feature service of trees prepared by the District Department of Transportation (DDOT) Urban Forestry Division in Washington, D.C. You'll connect to the city's public street tree inventory, inspect its layers and fields, and pull the rows and columns of data you need into R as an sf data frame. From there, you can visualize the data and use it in downstream workflows, like preparing a dataset of oak locations for pruning inspection by staff arborists.

----

Reference demos: 

/Users/josiahparry/github/r-bridge/2026-dev-summit/full-stack-spatial/*.R
/Users/josiahparry/github/r-bridge/2026-dev-summit/r-powered-arcgis-apps/*.R

/Users/josiahparry/github/r-bridge/2025-dev-summit/04-survey123-attachments.R
/Users/josiahparry/github/r-bridge/2025-uc/putting-r-in-arcgis/layer-attachments.R
/Users/josiahparry/github/r-bridge/2025-user-conference
