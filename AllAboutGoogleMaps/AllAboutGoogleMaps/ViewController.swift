//
//  ViewController.swift
//  AllAboutGoogleMaps
//
//  Created by testio2k16 on 9/20/16.
//  Copyright © 2016 testio2k16. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import MapKit

class ViewController: UIViewController {
    // Outlets
    @IBOutlet var mapView: GMSMapView! // view to support GMSMapView
    
    // Properties
    var markerPin: GMSMarker?
    var markerPinView: UIImageView?
    let locationManager = CLLocationManager()
    var daddrName = "" // selected parking spot address
    var saddrName = "" // current / searched location address
    //Serach Bar Properties
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    // Actions
    @IBAction func locateBtnOnClick(sender: AnyObject) {
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        //to get current location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //to implement auto complete search bar
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        self.navigationItem.titleView = searchController?.searchBar
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.delegate = self
        searchController?.searchBar.placeholder = "Search for places here"
    }
    
    
    
    private func errorAlertLocation(){
        if NSUserDefaults.standardUserDefaults().objectForKey("AppLoadsFirstTime") != nil && NSUserDefaults.standardUserDefaults().objectForKey("AppLoadsFirstTime") as! Bool == false {
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "Please open this app's settings and enable location access.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }else{
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "AppLoadsFirstTime")
        }
    }
    
    
    
    /* to set circle view in maps based on distance between two locations
     
     private func translateCoordinate(coordinate: CLLocationCoordinate2D, metersLat: Double,metersLong: Double) -> (CLLocationCoordinate2D) {
     var tempCoord = coordinate
     
     let tempRegion = MKCoordinateRegionMakeWithDistance(coordinate, metersLat, metersLong)
     let tempSpan = tempRegion.span
     
     tempCoord.latitude = coordinate.latitude + tempSpan.latitudeDelta
     tempCoord.longitude = coordinate.longitude + tempSpan.longitudeDelta
     
     return tempCoord
     }
     
     private func setRadius(radius: Double,withCity city: CLLocationCoordinate2D,InMapView mapView: GMSMapView) {
     
     let range = translateCoordinate(city, metersLat: radius * 2, metersLong: radius * 2)
     
     let bounds = GMSCoordinateBounds(coordinate: city, coordinate: range)
     
     let update = GMSCameraUpdate.fitBounds(bounds, withPadding: 5.0)    // padding set to 5.0
     
     mapView.moveCamera(update)
     
     /*// location
     let marker = GMSMarker(position: city)
     marker.title = "title"
     marker.snippet = "snippet"
     marker.flat = true
     marker.map = mapView*/
     
     // draw circle
     let circle = GMSCircle(position: city, radius: radius)
     circle.map = mapView
     circle.strokeWidth = 0
     //circle.fillColor = UIColor(red:0.09, green:0.6, blue:0.41, alpha:0.5)
     
     mapView.animateToLocation(city) // animate to center
     //mapView.animateToViewingAngle(45)
     //mapView.animateToBearing(50)
     
     
     }
     //starts here
     private func setZoom(radius: Double,withCity city: CLLocationCoordinate2D,InMapView mapView: GMSMapView){
     var r = radius
     if r < 200 {
     r = 200
     }
     
     setRadius(r, withCity: city, InMapView: mapView)
     
     }
     */
    
    
}

//1
extension ViewController:CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // mapView.showsUserLocation = (status == .AuthorizedAlways)
        switch status {
        case .NotDetermined:
            //locationManager.requestAlwaysAuthorization()
            print("curr place NotDetermined")
            break
        case .AuthorizedWhenInUse:
            // locationManager.startUpdatingLocation()
            print("curr place AuthorizedWhenInUse")
            locationManager.startUpdatingLocation()
            break
        case .AuthorizedAlways:
            // locationManager.startUpdatingLocation()
            print("curr place AuthorizedAlways")
            break
        case .Restricted:
            print("curr place Restricted")
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .Denied:
            print("curr place Denied")
            // user denied your app access to Location Services, but can grant access from Settings.app
            errorAlertLocation()
            break
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if UIApplication.sharedApplication().applicationState == .Active {
            if let location = locations.first {
                searchController?.searchBar.text = ""
                
                let geoCoder = CLGeocoder()
                geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                    // Place details
                    var placeMark: CLPlacemark!
                    placeMark = placemarks?[0]
                    if placeMark != nil {
                        // Location name
                        if let locationName = placeMark.addressDictionary!["Name"]  {
                            print(locationName)
                            let markerPin = GMSMarker(position: location.coordinate)
                            markerPin.title = locationName as? String
                            markerPin.icon = UIImage(named: "CurLoc")
                            markerPin.userData = false
                            markerPin.map = self.mapView
                            self.mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                        }
                        
                        let strArr = placeMark.addressDictionary?["FormattedAddressLines"] as! [String]
                        self.saddrName = ""
                        for strItem in strArr {
                            self.saddrName = self.saddrName + strItem + ","
                        }
                    }
                    
                    
                })
            }
            
            locationManager.stopUpdatingLocation()
            
        }
    }
}

//2
extension ViewController:GMSMapViewDelegate{
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool{
        return false
    }
    
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView?{
        guard let status = marker.userData where status as! Bool else {
            
            return nil
        }
        //initializing
        let infoWindowView = NSBundle.mainBundle().loadNibNamed("InfoWindow", owner: self, options: nil).first as! CustomInfoWindow
        infoWindowView.placeName.text = marker.title
        infoWindowView.view1.cardStyle(infoWindowView.view1)
        //let callOutXOrigin = marker.accessibilityFrame.origin.x
        // infoWindowView.frame = CGRectMake(callOutXOrigin, -10, 100, 48)
        return infoWindowView
    }
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker){
        let destString = self.daddrName.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let sourceString1 = self.saddrName.stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Select Routing App", preferredStyle: .ActionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Apple Map", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            if destString.characters.count > 0 && sourceString1.characters.count > 0 {
                UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?saddr=\(sourceString1)&daddr=\(destString)")!)
            }else{
                let alert = UIAlertController(title: "Directions Not Available", message: "Route information is not available at this moment.", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated:true, completion: nil)
            }
            
            
            
            
        })
        let saveAction = UIAlertAction(title: "Google Map", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Google Map")
            
            let customURL = "comgooglemaps://"
            
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: customURL)!) {
                if destString.characters.count > 0 && sourceString1.characters.count > 0 {
                    UIApplication.sharedApplication().openURL(NSURL(string: "comgooglemaps://?saddr=\(sourceString1)&daddr=\(destString)&directionsmode=driving")!)
                }else{
                    let alert = UIAlertController(title: "Directions Not Available", message: "Route information is not available at this moment.", preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                    alert.addAction(ok)
                    self.presentViewController(alert, animated:true, completion: nil)
                }
                
            }
            else {
                let alert = UIAlertController(title: "Error", message: "Google maps not installed", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated:true, completion: nil)
            }
            
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
}

//3
extension ViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWithPlace place: GMSPlace) {
        searchController?.active = false
        // Do something with the selected place.
        let markerPin = GMSMarker(position: place.coordinate)
        markerPin.title = place.name
        markerPin.icon = UIImage(named: "DestLoc")
        markerPin.userData = true
        markerPin.map = self.mapView
        self.mapView.camera = GMSCameraPosition(target: place.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        daddrName = place.formattedAddress!
        searchController?.searchBar.text = place.name
        
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: NSError){
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}

//4
extension ViewController: UISearchControllerDelegate {
    func willPresentSearchController(searchController: UISearchController){
        print("willPresentSearchController")
    }
    func didPresentSearchController(searchController: UISearchController){
        print("didPresentSearchController")
    }
    
    func presentSearchController(searchController: UISearchController){
        print("presentSearchController")
    }
    
    func willDismissSearchController(searchController: UISearchController){
        print("willDismissSearchController")
    }
    
    func didDismissSearchController(searchController: UISearchController){
        print("didDismissSearchController")
    }
}
//5
extension ViewController: CustomRoutingDelegate{
    func startRouting(){
        let destString = self.daddrName.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let sourceString1 = self.saddrName.stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Select Routing App", preferredStyle: .ActionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Apple Map", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            if destString.characters.count > 0 && sourceString1.characters.count > 0 {
                UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?saddr=\(sourceString1)&daddr=\(destString)")!)
            }else{
                let alert = UIAlertController(title: "Directions Not Available", message: "Route information is not available at this moment.", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated:true, completion: nil)
            }
            
            
            
            
        })
        let saveAction = UIAlertAction(title: "Google Map", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Google Map")
            
            let customURL = "comgooglemaps://"
            
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: customURL)!) {
                if destString.characters.count > 0 && sourceString1.characters.count > 0 {
                    UIApplication.sharedApplication().openURL(NSURL(string: "comgooglemaps://?saddr=\(sourceString1)&daddr=\(destString)&directionsmode=driving")!)
                }else{
                    let alert = UIAlertController(title: "Directions Not Available", message: "Route information is not available at this moment.", preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                    alert.addAction(ok)
                    self.presentViewController(alert, animated:true, completion: nil)
                }
                
                
                
            }
            else {
                let alert = UIAlertController(title: "Error", message: "Google maps not installed", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated:true, completion: nil)
            }
            
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
}



