//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Bill Clark on 7/7/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    var dataController:DataController!
    
    var pins: [Pin] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Load current pins from coreData if any exist
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            pins = result
            
            for pin in pins{
                //add pin to map
                self.loadPinsFromStore(inLat: pin.lat, inLon: pin.lon)
            }
        }

        //Capture long pressed gestures which will set a new pin
        
        let longPressed = UILongPressGestureRecognizer(target: self, action: #selector(lpSetPin))
        longPressed.minimumPressDuration = 1.0
        self.view.addGestureRecognizer(longPressed)
    }
    
    @objc func lpSetPin(inGesture: UILongPressGestureRecognizer){
        
        if(inGesture.state == UIGestureRecognizer.State.began){
            
            let location = inGesture.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            
            // Add annotation:
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
            
            //save to coreData
            let pin = Pin(context: dataController.viewContext)
            pin.lat = coordinate.latitude
            pin.lon = coordinate.longitude
    
            try? dataController.viewContext.save()
        }
    }
    
    func loadPinsFromStore(inLat: Double, inLon: Double){
        
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: inLat, longitude: inLon)
        
        print(coordinate)
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
    func deletePinFromStore(inLat: Double, inLon: Double){
        
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        let latPredicate = NSPredicate(format: "lat == %@", String(inLat))
        let lonPredicate = NSPredicate(format: "lon == %@", String(inLon))
        request.predicate = latPredicate
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [latPredicate, lonPredicate])
        request.predicate = compoundPredicate

        if let result = try? dataController.viewContext.fetch(request) {
            for object in result {
                dataController.viewContext.delete(object)
                try? dataController.viewContext.save()
            }
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
            pinView?.animatesDrop = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if(editButton.title == "Done"){
            
            deletePinFromStore(inLat: (view.annotation?.coordinate.latitude)!, inLon: (view.annotation?.coordinate.longitude)!)
            
            //User is in edit mode to remove pin
            self.mapView.removeAnnotation(view.annotation!)
            
        }else{
            
            //User not in edit mode.  Get photo details for selected pin.
            let pdVC = self.storyboard!.instantiateViewController(withIdentifier: "Pin Details") as! PinDetailsViewController
            
            pdVC.inLat = (view.annotation?.coordinate.latitude)!
            pdVC.inLon = (view.annotation?.coordinate.longitude)!
            pdVC.dataController = dataController

            self.navigationController!.pushViewController(pdVC, animated: true)
            
            //Deselect pin after pushing new view.  This way I can click it again when I come back
            self.mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }
    
    @IBAction func editBtnClicked(_ sender: Any) {
        
        if editButton.title == "Edit"{
            self.editButton.title = "Done"
            
            //move map view up 80 pixels to show edit view
            UIView.animate(withDuration: 0.5){
                self.editView.frame.origin.y -= 114
                self.mapView.frame.origin.y -= 80
            }
            
        }else{
            self.editButton.title = "Edit"
            
            //move map view up -80 pixels to hide edit view
            UIView.animate(withDuration: 0.5){
                self.mapView.frame.origin.y += 80
                self.editView.frame.origin.y += 114
                
            }
        }
    }
}
