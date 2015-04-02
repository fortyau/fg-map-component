'use strict'

# map widget -- REMOVE 'config' dependency
mapz = angular.module('mapModule', ['google-maps'])


mapz.service 'markerTypes', (Restangular) ->
  {
  "Buildings":[
    {
      "id":1,
      "group":"Buildings",
      "name":"Building",
      "icon":null
    },{
      "id":2,
      "group":"Buildings",
      "name":"Main Entrance",
      "icon":null
    },{
      "id":3,
      "group":"Buildings",
      "name":"Employee Entrance",
      "icon":null
    },{
      "id":4,
      "group":"Buildings",
      "name":"ER Entrance",
      "icon":null
    },{
      "id":5,
      "group":"Buildings",
      "name":"Ambulance Entrance",
      "icon":null
    },{
      "id":6,
      "group":"Buildings",
      "name":"Helipad",
      "icon":null
    },{
      "id":7,
      "group":"Buildings",
      "name":"Department",
      "icon":null
    }
  ],
  "Parking":[
    {
      "id":8,
      "group":"Parking",
      "name":"Parking Lot",
      "icon":null
    },{
      "id":9,
      "group":"Parking",
      "name":"Parking Garage",
      "icon":null
    },{
      "id":10,
      "group":"Parking",
      "name":"Physician Parking",
      "icon":null
    },{
      "id":11,
      "group":"Parking",
      "name":"Employee Parking",
      "icon":null
    },{
      "id":12,
      "group":"Parking",
      "name":"Visitor Parking",
      "icon":null
    }
  ],
  "Utilities":[
    {
      "id":13,
      "group":"Utilities",
      "name":"Electrical Service",
      "icon":null
    },{
      "id":14,
      "group":"Utilities",
      "name":"Natural Gas Service",
      "icon":null
    },{
      "id":15,
      "group":"Utilities",
      "name":"Water Service",
      "icon":null
    }
  ],
  "Infrastructure":[
    {
      "id":16,
      "group":"Infrastructure",
      "name":"Generator",
      "icon":null
    },{
      "id":17,
      "group":"Infrastructure",
      "name":"Storage Area",
      "icon":null
    },{
      "id":18,
      "group":"Infrastructure",
      "name":"Loading Dock",
      "icon":null
    },{
      "id":19,
      "group":"Infrastructure",
      "name":"Med/Gas farm",
      "icon":null
    },{
      "id":20,
      "group":"Infrastructure",
      "name":"Emergency Oxygen",
      "icon":null
    },{
      "id":21,
      "group":"Infrastructure",
      "name":"Cooling Tower",
      "icon":null
    },{
      "id":22,
      "group":"Infrastructure",
      "name":"Central Energy",
      "icon":null
    }
  ]
#  These categories exist inside of the database, however users should not be able to make new pins with these categories
#  "Real Estate":[
#    {
#      "id":23,
#      "group":"Real Estate",
#      "name":"Ground lease",
#      "icon":null
#    },{
#      "id":24,
#      "group":"Real Estate",
#      "name":"Owned building",
#      "icon":null
#    },{
#      "id":25,
#      "group":"Real Estate",
#      "name":"Owned lot",
#      "icon":null
#    },{
#      "id":26,
#      "group":"Real Estate",
#      "name":"Condo",
#      "icon":null
#    },{
#      "id":27,
#      "group":"Real Estate",
#      "name":"Apartments",
#      "icon":null
#    },{
#      "id":28,
#      "group":"Real Estate",
#      "name":"Administrative building",
#      "icon":null
#    },{
#      "id":29,
#      "group":"Real Estate",
#      "name":"HCAPS",
#      "icon":null
#    }
#  ]
  }

# map widget -- REMOVE '$stateParams' AND 'ENV' DEPENDENCY
mapz.controller 'googleMapsController', ($filter, $scope, $rootScope, utils, markerTypes) ->

  ###*
  *
  *  this is what the data for the map needs to look like
  *
  *  $scope.dataForMap = {
  *    dataSource: "facility" # We use this when creating new markers, The database wants this information
  *    edit: true
  *    newMarkers: boolean # displays the button for adding a new object
  *    newPolygons: boolean # displays the button for adding a new object
  *    overlays: [
  *      type: polygon - For now the only supported type
  *      path: [] Array of mapz LatLongPairs
  *      property: {} A copy of the object that the polygon belongs to.
  *    ]
  *    markers: []
  *    addresses: []
  *    centerAddress: {} Address object to center the map on
  *    ready: boolean, flag to inform if the dataForMap object is as ready as it will ever be
  *  }
  *
  *###

  # map widget -- CHANGE '$stateParams.id' TO 'window.facGuid.id'
  RECORD_ID = $rootScope.facGuid

  $scope.markerCategories = markerTypes

  $scope.map = {
    instance: {}
    loaded: false
    center:
      latitude: 39.5
      longitude: -98.35
    zoom: 4
    fullscreen: false
    draggable: true
    refresh: true
    pan: true
    editable: $scope.dataForMap.edit
    overlays:
      polygons: []
      markers: []
    window: {}
    events:
      tilesloaded: (map) ->
        $scope.loadMap(map)
  }


  ### PROPERTY FUNCTIONS ### ###########################################################################################

  ###*
  * This returns a string representing the property status. for the hoo-muns.
  * TODO this should be for sure a factory or a service, but for the life of me I cannot wrap my head around it
  *###
  $scope.getPropertyStatus = (integer) ->

    switch integer
      when 1 then 'Master lease'
      when 2 then 'Owned'
      when 3 then 'SPL'
      when 4 then 'HCAPS'
      when 5 then 'COM'
      when 6 then 'JV'
      when 7 then 'Timeshare'
      when 8 then 'JV-Owned'


  ###  MAP FUNCTIONS  ### ##############################################################################################

  ###*
  * This event is triggered whenever the map loads a tile, i.e. on initial load and then on subsequent
  * pans and zooms of the map that require GM to load more map tiles
  *###
  $scope.loadMap = (map) ->
    unless $scope.map.loaded
      utils.log 'Google map tiles loaded/initial creation', 'success'

      # Set map Instance so that we can use google functions
      $scope.map.instance = map

      # Disable 45 degree views if the maps is editable
      if $scope.map.editable == true
        map.setTilt(0);

      # Default the map to the hybrid view
      map.setMapTypeId google.maps.MapTypeId.HYBRID

      $scope.map.loaded = true

      # Center the map
      if $scope.dataForMap.centerAddress
        utils.log "Centering Map"
        $scope.centerMapOnAddress($scope.dataForMap.centerAddress)

      # if refreshing data will be available near instantly
      # if loading it will take a few ms, either way we will get it
      if $scope.dataForMap.ready == true
        $scope.populateMap()
      else
        utils.log "Standby for Data", "warning"
        $scope.$watch 'dataForMap.ready', ()->
          if $scope.dataForMap.ready == true
            $scope.populateMap()
        , true

  ###*
  * This function loops through all the information in the dataForMap object and places it inside of the map.instance Object
  *###
  $scope.populateMap = ()->
    unless $scope.map_populated

      # Populate the google map instance
      utils.log 'Placing ' + $scope.dataForMap.markers.length + ' markers'
      if $scope.dataForMap.markers.length > 0
        mapHasOverlays = true
        _.each $scope.dataForMap.markers, (marker)->
          $scope.placeMarker marker

      utils.log 'Plotting ' + $scope.dataForMap.overlays.length + ' shapes'
      if $scope.dataForMap.overlays.length > 0
        mapHasOverlays = true
        _.each $scope.dataForMap.overlays, (overlay)->
          $scope.placeExistingOverlay overlay

      utils.log 'Geocoding ' + $scope.dataForMap.addresses.length + ' addresses'
      if $scope.dataForMap.addresses.length > 0
        mapHasOverlays = true
        $scope.slowlyPlaceApproximateMarkers ($scope.dataForMap.addresses)

      if mapHasOverlays
        $scope.fitMapBoundsToAllOverlays()

      $scope.map_populated = true


  ###*
  *
  *###
  $scope.fitMapBoundsToAllOverlays = ()->
    latlngbounds = new google.maps.LatLngBounds()

    $scope.map.overlays.polygons.forEach (overlay)->
      for path in overlay.path
        latlngbounds.extend new google.maps.LatLng(path.latitude, path.longitude)

    $scope.map.overlays.markers.forEach (marker)->
      latlngbounds.extend new google.maps.LatLng(marker.coords.latitude, marker.coords.longitude)

    $scope.map.instance.fitBounds(latlngbounds)


  ###*
  *
  *###
  $scope.maximizeMap = ()->

    $('div.box.box-gmaps').toggleClass 'box-maximized'
    $scope.map.fullscreen = !$scope.map.fullscreen
    setTimeout (->
      google.maps.event.trigger($scope.map.instance, "resize")
      $scope.fitMapBoundsToAllOverlays
    ), 100


  ###*
  * The listener for the requestOverlaysToSave event, set off by the record controller.
  *###
  $scope.$on 'requestOverlaysToSave', (e)->
    $rootScope.overlaysToSave = $scope.gatherPolygons()
    $rootScope.markersToSave = $scope.gatherMarkers()


  ###*
  * The Gather Markers Function Loops through all of the markers and only sends back the ones that have a parent ID
  * That matches the current record ID
  *###
  $scope.gatherMarkers = ()->
    markersThatBelongToRecord = []

    $scope.map.overlays.markers.forEach (marker)->
      if marker.parent_id == RECORD_ID
        markersThatBelongToRecord.push marker

    markersThatBelongToRecordAndAreNotGenerated = _.filter markersThatBelongToRecord, (marker)->
      marker.generated is false

    return markersThatBelongToRecordAndAreNotGenerated


  ###*
  * The Gather polygons Function Loops through all of the markers and only sends back the ones that have a parent ID
  * That matches the current record ID
  *###
  $scope.gatherPolygons = ()->
    polygonsThatBelongToRecord = []

    $scope.map.overlays.polygons.forEach (polygon)->
      if polygon.property.id.toString() == RECORD_ID.toString()
        strippedObject = {
          type: polygon.type
          path: polygon.path
        }
        polygonsThatBelongToRecord.push strippedObject

    return polygonsThatBelongToRecord


  ###*
  *
  *###
  $scope.showLoadingSpinner = () ->
#    utils.log "Loading"

  ###*
  *
  *###
  $scope.hideLoadingSpinner = () ->
#    utils.log "Finished"

  ###*
  * Geocodes all the data at a snail pace
  *###
  $scope.slowlyPlaceApproximateMarkers = (addressArray)->
    i = 0
    msToWait = 300  # the lower this number, the faster the markers will load and the greater chance for error
    timesToLoop = addressArray.length

    theLoop = -> #  create a loop function
      setTimeout (-> #  call a setTimeout when the loop is called
        if i == 0
          $scope.showLoadingSpinner()

        $scope.placeApproximateMarker addressArray[i]
        i++ #  increment the counter

        if i < timesToLoop #  if the counter < 10, call the loop function...
          theLoop() #  ...again which will trigger another setTimeout()
        else
          $scope.hideLoadingSpinner()

        return
      ), msToWait
      return

    theLoop() #  start the loop
    return


  ###*
  * Add marker from address object
  *###
  $scope.placeApproximateMarker = (address)->

    geo = new google.maps.Geocoder()
    geo.geocode
      address: address.street_address_1 + " " + address.locality + " " + address.region + " " + address.postal_code
    , (results, status) ->

      if status is google.maps.GeocoderStatus.OK
        marker = {
          atLocation: [
            {
              description: address.parent_title
              parent_id: address.parent_id
            }
          ]
          description: address.parent_title
          latitude: results[0].geometry.location.lat()
          longitude: results[0].geometry.location.lng()
          waypoint_category_id: 1
          generated: true
        }
        $scope.placeGeneratedMarker marker
        $scope.fitMapBoundsToAllOverlays()

      else
        utils.log "Failed to Geocode:", "warning"
        utils.log address.street_address_1 + " " + address.locality + " " + address.region + " " + address.postal_code


  ###*
  *
  *###
  $scope.centerMapOnAddress = (address) ->
    geo = new google.maps.Geocoder()
    geo.geocode
      address: address.street_address_1 + " " + address.locality + " " + address.region + " " + address.postal_code
    , (results, status) ->

      if status is google.maps.GeocoderStatus.OK
        $scope.map.center = {
          latitude: results[0].geometry.location.lat()
          longitude: results[0].geometry.location.lng()
        }
        $scope.map.zoom = 13

      else
        utils.log "Cannot Center Map", "warning"
        utils.log address.street_address_1 + " " + address.locality + " " + address.region + " " + address.postal_code


  ###*
  * TODO Figure out why this function will not return a geoLocation, then utilize it in centerMapOnAddress and placeApproximateMarker functions
  *###
  $scope.geocodeAddress = (address)->

    geo = new google.maps.Geocoder()
    geo.geocode
      address: address.street_address_1 + " " + address.locality + " " + address.region + " " + address.postal_code
    , (results, status) ->

      if status is google.maps.GeocoderStatus.OK
        geoLocation = results[0]
        return geoLocation
      else
        utils.log "Failed to geocode address:", "warning"
        utils.log address.street_address_1 + " " + address.locality + " " + address.region + " " + address.postal_code


  ###  WINDOW  ### #####################################################################################################


  ###*
  * This is the one and only window for the polygons, It is constantly updated and moves around
  * TODO find a better way to handle this window. Maybe have one for each polygon?
  *###
  $scope.map.window = {
    property: {}
    showWindow: false
    coords: $scope.map.center
  }


  ###  OVERLAY  ### ####################################################################################################


  ###*
  * Add a overlay to the Google Map and the correct angular model collection
  * @param {object} Marker object
  ###
  $scope.placeExistingOverlay = (overlay) ->
    if overlay.type == "polygon"
      $scope.placePolygon(overlay)
    else
      utils.log "Cannot add this overlay: Unknown Type", "warning"
      utils.log overlay
      return


  ###*
  * Makes the overlay that the user clicked on active, makes all others inactive
  * If no overlay is passed, they all become inactive
  *###
  $scope.makeOverlayActive = (activeOverlay) ->

    utils.safeApply $scope, ()->

      for overlayCategory of $scope.map.overlays
        $scope.map.overlays[overlayCategory].forEach (overlay)->
          overlay.active = false

      # Hide the window, because there is only one and its not tied to an overlay
      $scope.map.window.showWindow = false

      if activeOverlay
        activeOverlay.active = true

        if activeOverlay.type == "polygon"
          $scope.map.window.showWindow = true


  ###*
  * This targets a single overlay and makes it inactive
  *###
  $scope.makeOverlayInactive = (overlay) ->
    utils.safeApply $scope, ()->
      overlay.active = false


  ###*
  * This returns a count of all the active overlays
  *###
  $scope.activeOverlayCount = () ->
    count = 0
    for overlayCategory of $scope.map.overlays
      $scope.map.overlays[overlayCategory].forEach (overlay)->
        if overlay.active
          count = count + 1
    return count


  ###*
  * If there are ANY active overlays It makes them all inactive, this includes polygons
  * If none are active it makes all MARKERS active
  *###
  $scope.toggleMarkerWindows = ()->

    if $scope.activeOverlayCount() > 0
      $scope.makeOverlayActive()
    else
      $scope.map.overlays.markers.forEach (marker)->
        marker.active = true



  ###  MARKER  ### #####################################################################################################


  ###*
  * Toggle Marker visibility on the google map
  * @param category 'string' Marker category to affect
  * @param visible 'bolean' to show or not
  ###
  $scope.showOrHideMarker = (category, visibleBoolean) ->
    $scope.map.overlays.markers.forEach (marker)->
      if category == $scope.getWaypointCategory(marker.waypoint_category_id)
        marker.options.visible = visibleBoolean


  ###*
  * Retrieve a title from a waypoint marker
  * @param {object} Marker for
  * @return {string} Name of category if marker_category_id is not null
  *###
  $scope.getWaypointTitle = (marker)->
    id = parseInt(marker.waypoint_category_id)
    return '' unless _.isNumber id or marker.waypoint_category_id is null or marker.waypoint_category_id is 0

    for key of $scope.markerCategories
      category = _.find $scope.markerCategories[key], (c)->
        c.id == id
      break unless category is undefined

    category.name


  ###*
  * Retrieve a category name from a waypoint ID
  * @param {integer} Integer representing a waypoint category ID
  * @return {string} Category name from waypoint category ID
  *###
  $scope.getWaypointCategory = (id)->
    waypointCategory = ""
    id = parseInt(id)
    return waypointCategory unless _.isNumber id

    for key of $scope.markerCategories
      category = _.find $scope.markerCategories[key], (c)->
        c.id == id
      unless category is undefined
        waypointCategory = key
        break
    waypointCategory


  ###*
  * This returns a URL to a marker image, The images on the remote server are named the same as the marker category
  *###
  $scope.getMarkerIcon = (waypoint_category_id)->

    if waypoint_category_id != 0
      icon = $scope.getWaypointCategory(waypoint_category_id)
      icon = icon.replace(" ", "_").toLowerCase()
    else
      icon = "new"

    "https://apidev.hcafi.com" + '/assets/map/marker_' + icon + '.png'


  ###*
  * This returns a string of how many properties are currently at this location
  *###
  $scope.getStackCount = (marker)->
    if marker.hasOwnProperty('atLocation')
      count = marker.atLocation.length
      if count > 1
        count + " Properties in this location"


  ###*
  * Create a New Marker Object as if it were coming from the Database
  * then send it to the placeMarker function
  * @param {object} Marker object
  ###
  $scope.spawnNewMarker = ()->
    newMarker = {
      description: "New Marker"
      parent_id: RECORD_ID
      parent_type: $scope.dataForMap.dataSource # The database wants this information
      generated: false
      active: true
      waypoint_category_id: 0
      latitude: $scope.map.center.latitude
      longitude: $scope.map.center.longitude
    }

    $scope.placeMarker newMarker


  ###*
  * Generated markers are a tad different than regular markers, They have the possibility to stack on top of each other
  * For the sake of the users, we want to make this situation not so difficult to comprehend.
  * We first look at all the other generated markers and see if there are any others in that same location.
  * If there is we extend the at_location attr to include another array Item
  * We use latitude and longitude numbers rounded off to determine if these pins are in the same place
  * The fifth decimal place is worth up to 1.1 m accuracy and good enough for us
  *###
  $scope.placeGeneratedMarker = (newMarker) ->

    locationMatch = {}

    _.each $scope.map.overlays.markers, (existingMarker) ->

      if existingMarker.generated == true
        existingLatitude  = $filter('number')(existingMarker.coords.latitude, 5)
        existingLongitude = $filter('number')(existingMarker.coords.longitude, 5)
        newLatitude       = $filter('number')(newMarker.latitude, 5)
        newLongitude      = $filter('number')(newMarker.longitude, 5)

        if existingLatitude == newLatitude && existingLongitude == newLongitude
          locationMatch = existingMarker
          return

    if locationMatch.hasOwnProperty('coords')
      locationMatch.atLocation.push newMarker.atLocation[0]
    else
      $scope.placeMarker newMarker


  ###*
  * Add a marker to the Google Map and the angular map marker model collection
  * This will Update any marker with the newest Marker data and functions
  * we extend the marker object with these settings and events
  * @param {object} Marker object
  ###
  $scope.placeMarker = (marker) ->
    defaultMarker = {
      active: false
      generated: false
      window:
        options:
          pixelOffset: new google.maps.Size(0, -40)
      options:
        visible: true
      coords:
        latitude: marker.latitude
        longitude: marker.longitude
      icon: $scope.getMarkerIcon(marker.waypoint_category_id)
      setIcon: ()->
        this.icon = $scope.getMarkerIcon(this.waypoint_category_id)
      events:
        click: (x, a, m)->
          $scope.makeOverlayActive(m.$parent.marker)
        dragstart: (x, a, m)->
          $scope.makeOverlayInactive(m.$parent.marker)
        dragend: (x, a, m)->
          m.$parent.marker.coords.latitude = x.getPosition().lat()
          m.$parent.marker.coords.longitude = x.getPosition().lng()
    }

    marker = _.extend(defaultMarker, marker)

    if $scope.map.editable == false
      marker.events = {
        mouseover: (x, a, m)->
          $scope.makeOverlayActive(m.$parent.marker)
        mouseout: (x, a, m)->
          $scope.makeOverlayInactive(m.$parent.marker)
      }

    if (($scope.map.editable == true && !marker.generated) && marker.parent_id.toString() == RECORD_ID.toString() )
      marker.options.editable = true
      marker.options.draggable = true
    else
      marker.options.editable = false
      marker.options.draggable = false

    $scope.map.overlays.markers.push marker

    if marker.active
      $scope.makeOverlayActive(marker)


  ###*
  * Remove a marker from the google map and the angular map marker collection
  * @param {object} Marker object to remove
  ###
  $scope.removeMarker = (marker) ->
    $scope.map.overlays.markers.splice($scope.map.overlays.markers.indexOf(marker), 1)
    $scope.makeOverlayActive()


  ###  POLYGON  ### ####################################################################################################


  ###*
  * This takes the shared info window and fills it with information
  * It only used by the polygon click callback
  *###
  $scope.populateWindowWithPolygonInformation = (polygon, eventName, polyMouseEvent)->
    polygon_scope_object = @polygon

    utils.safeApply $scope, ()->
      $scope.makeOverlayActive(polygon_scope_object)

      $scope.map.window = {
        property: polygon_scope_object.property
        showWindow: true
        coords:
          latitude: polyMouseEvent[0].latLng.lat()
          longitude: polyMouseEvent[0].latLng.lng()
      }

    return


  ###*
  * Returns a fill color for Polygons
  * this function refers to the attached copy of the property record and makes a color selection based off of that
  *###
  $scope.getPolygonColor = (polygon)->

    if polygon.property.status
      # if we use polygon.property.status.status we can be more granular
      # Ground Lease, Master Lease, Timeshare, Condo etc.
      # for now we will look at the parent status category
      switch polygon.property.status.category
        when 'owned' then '#ffff00' #yellow
        when 'leased' then '#0000ff' #blue
        else '#0000ff' #blue

  ###*
  * Calculates a z-index for the polygons. For the stacking and clicking
  *###
  $scope.getPolygonZindex = (polygon)->

    # make an array to hold LatLng bits
    latLngArray = []

    # convert out path object into LatLng deal
    _.each polygon.path, (latLngObj) ->
      latLngArray.push new google.maps.LatLng(latLngObj["latitude"], latLngObj["longitude"])

    # calculate the area
    area = google.maps.geometry.spherical.computeSignedArea latLngArray

    # make it negative, round it off, and divide by 100
    zIndex = -Math.abs Math.round area/100


  ###*
  * This creates a polygon Object and passes it onto the placePolygon Function
  *
  * Only Properties will support Polygons, So when we create a new polygon we can refer to the current scope property.
  * We take that information and attach a copy of it to the overlay itself
  *
  *###
  $scope.spawnNewPolygon = () ->
    centerLat = $scope.map.center.latitude
    centerLng = $scope.map.center.longitude
    northEastLat = $scope.map.instance.getBounds().getNorthEast().lat()
    northEastLng = $scope.map.instance.getBounds().getNorthEast().lng()
    southWestLat = $scope.map.instance.getBounds().getSouthWest().lat()
    southWestLng = $scope.map.instance.getBounds().getSouthWest().lng()

    newPolygon = {
      type: "polygon"
      property: $scope.property
      active: true
      path: [
        { # top
          latitude: centerLat + ((northEastLat - centerLat) / 2)
          longitude: centerLng
        },
        { # right
          latitude: centerLat - ((northEastLat - centerLat) / 2)
          longitude: centerLng + ((northEastLng - centerLng) / 2)
        },
        { # left
          latitude: centerLat + ((southWestLat - centerLat) / 2)
          longitude: centerLng + ((southWestLng - centerLng) / 2)
        }
      ]
    }

    $scope.placePolygon(newPolygon)


  ###*
  * Add a polygon to the Google Map and the angular map polygon model collection
  * This will Update any polygon with the newest data and functions
  * @param {object} Marker object
  ###
  $scope.placePolygon = (polygon) ->

    defaultPolygon = {
      active: false
      fill:
        color: $scope.getPolygonColor(polygon)
        opacity: 0.1
      stroke:
        color: $scope.getPolygonColor(polygon)
        weight: 2
        opacity: 1.0
      zindex: $scope.getPolygonZindex(polygon)
    }

    polygon = _.extend(defaultPolygon, polygon)

    if $scope.map.editable == true && polygon.property.id.toString() == RECORD_ID.toString()
      polygon.editable = true
      polygon.draggable = true
    else
      polygon.editable = false
      polygon.draggable = false

    polygon.events = {
      click: _.bind($scope.populateWindowWithPolygonInformation,
        scope: $scope
        polygon: polygon
      )
    }

    $scope.map.overlays.polygons.push polygon

    if polygon.active
      $scope.makeOverlayActive(polygon)


  ###*
  * This takes a Passed in Polygon and removes it from the Map object
  *###
  $scope.removePolygon = (polygon) ->
    $scope.map.overlays.polygons.splice($scope.map.overlays.polygons.indexOf(polygon), 1);
    $scope.makeOverlayActive()
