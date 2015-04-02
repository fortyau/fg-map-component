'use strict'

angular.module('fgMapComponentApp').controller 'MainCtrl', ($scope, $rootScope, Restangular, facility_types, utils) ->

  utils.log "Main controller loaded", "success"


  ###*
  * Map Settings
  *###
  $scope.mapLoaded = false
  $scope.mapIntance = {}
  $scope.facility_types = facility_types
  $scope.dataForMap = {
    dataSource: "facility" # We use this when creating new markers, The database wants this information
    edit: false
    newMarkers: true
    newPolygons: false
    overlays: []
    markers: []
    addresses: []
    ready: false
  }


  ###*
  * Show the map on the page
  *###
  $scope.showMap = ()->
    $('#gmaps-container .box').animate({
      opacity: 1
    }, 500)


  ###*
  * This is the function that finally gets and process the data
  *###
  $scope.retrieveData = ()->
    console.log "Retrieving data from API"

#    Restangular.all('waypoint').customGET('categories').then (data)->
#      $scope.markerCategories = Restangular.stripRestangular data

    facilities = Restangular.one 'facilities', $rootScope.facGuid

    # Load our Data
    facilities.get().then (response)->
      $scope.facility = response

      # Make a address object for the map to center on
      address = {
        parent_title: $scope.facility.name
        parent_id: $scope.facility.id
        street_address_1: $scope.facility.street_address_1 || ""
        locality: $scope.facility.locality || ""
        region: $scope.facility.region || ""
        postal_code: $scope.facility.postal_code || "" }
      $scope.dataForMap.centerAddress = address


      # If the facility has waypoints, share them with map controller
      if $scope.facility.waypoints
        _($scope.facility.waypoints).forEach (waypoint)->
          $scope.dataForMap.markers.push waypoint


      # If the facility has properties share all of their information
      if $scope.facility.properties
        for property in $scope.facility.properties

          if property.waypoints
            _(property.waypoints).forEach (waypoint)->
              $scope.dataForMap.markers.push waypoint

          if property.gis_map_data
            for overlay in angular.fromJson(property.gis_map_data)
              overlay.property = property # we attach a copy of the property for information display purposes
              $scope.dataForMap.overlays.push overlay
          else
            if property.street_address_1
              address = {
                parent_title: property.property_name
                parent_id: property.id
                street_address_1: property.street_address_1
                locality: property.locality || ""
                region: property.region || ""
                postal_code: property.postal_code || "" }
              $scope.dataForMap.addresses.push address

        $scope.dataForMap.ready = true
        $scope.showMap()


  ###*
  * Wait for authentication, There is no point in jumping the gun
  * TODO this should be more angular-y rootscope broadcast?
  *###
  checkForAuthenticationBeforeProceeding = ()->
    if $rootScope.api_authenticated == true
      $scope.retrieveData()
    else
      setTimeout(->
        checkForAuthenticationBeforeProceeding()
      , 100)
  checkForAuthenticationBeforeProceeding()


.service 'facility_types', () ->
  # TODO get this to pull form the API It should be able to drop right in
  return [{ "id":"1", "name":"Hospital Acute Care"},{"id":"2", "name":"Hospital Non Acute Care"},{"id":"3", "name":"Hospital FSED"},{"id":"4", "name":"Hospital Rehab Care"},{"id":"5", "name":"Hospital Psychiatric Care"},{"id":"7", "name":"Corporate - Offices"},{"id":"8", "name":"Corporate - Data Centers"},{"id":"9", "name":"Cancer Center"},{"id":"10", "name":"Surgery Center"},{"id":"11", "name":"Imaging Center"},{"id":"12", "name":"Parallon Offices"},{"id":"13", "name":"Physician Services"},{"id":"14", "name":"Ambulatory Care"},{"id":"15", "name":"Psychiatric NonAcute Care"},{"id":"16", "name":"Non Acute Care"}]
