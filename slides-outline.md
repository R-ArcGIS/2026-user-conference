# Putting the R in ArcGIS (1 min) 

Presenters: 
- Josiah Parry
- Martha Bass

## Survey123 Link (1 min) :03

## What is the R-ArcGIS Bridge (1 min) :04

- Collection of R packages
- Integrates the R language with the ArcGIS ecosystem
- Modular design
  - Your architecture and workflows guide which package(s) you need
All packages are freely available; ArcGIS Pro license required to use {arcgisbinding}

## Capabilities (2 min) 0:06

- arcgisutils: authentication and portal integration
- arcgislayers: read and write feature services, attachments 
- arcgisgeocode: fast bulk and reverse geocoding
- arcgisrouting: fleet routing, directions, and travel times
- calcite: shiny app development
- arcgisplaces: access point of interest data
- arcpbf: low-level data reading

## Demo Shiny App (3 min) 0:09

This is a demo of app.R

It will showcase the capabilities of arcgislayers, arcgisgeocode, and calcite.
This will be a quick demo to show the capabilities

## {arcgislayers} (3m): 0:12

- The flagship package in the R-ArcGIS Bridge
- This is the package we use to connect to any data service
- this is what powered the data previews in the last application
  - agol, enterprise, location platform, survey123 you name it
- we use it to publish R objects directly to our portal
- use it to modify data—add / delete / update 
- supports your truncate and append worklflows etc
- even enables you to work with attachments in your feature services 

## Data Retrieval Workflow (3m) 0:15

- data is hosted either in AGOL or enterprise
- use the identifier of an item and read it with arcgislayers
- arc_select() will return the data as an sf object
- or, if you're working with imagery arc_raster() will return a terra object

## Authentication 3m 0:18

- One of the challenges is identifying who you are 
- AGOL and enterprise don't know who you are when you are writing R code
- we have to provide our credentials through authentication
- {arcgisutils} provides a number of ways to do this
  - auth_key(), auth_code(), auth_client(), auth_user()
- auth_user() is the simplest but least safe
- note, use .Renviron to store your credentials

## Demo 3m 0:21

- This next demo will illustrate reading in a public feature service and publishing to a private portal


## Portal Interactivity 3m 0:24

Most workflows require that you know the item ID or service URL
that may be perfect for your use case
sometimes it is important to be a bit more programmatic though, this is where 
the portal functionality of {arcgisutils} can help

- we use {arcgisutils} for working with your portal
- enables us to programmatically search for content items
- different ways to search:
  - normal search
    - search_itmes()
  - enumerate items owned by groups or individual user 
    - arc_user_content() / arc_group_content() 

## Demo 0:27

This next demo uses the portal integration to identify our content items
and read them in. we will use one of the polygon layers to further modify
our searches

TODO(Martha): vamp on this conceptually

## Geocoding from R

- now we're going to revisit the survey you all entered shortly
- you each entered the location of a tree in DC
- we have the locations but we will want to be able to identify each of these trees for service
- we need their addresses and then, we will need to visit each of them and need to get travel times
- in the next part we will leveraged the R-ArcGIS Bridge to reverse geocode these addreses
- {arcgisgeocode} 

## Routing Services

as the next part of this, we want to think about how can we take the locations from our survey123 and get directions for it





## using with LLMs

- robots 
- llms.txt links