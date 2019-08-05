//
//  PinDetailsViewController.swift
//  Virtual Tourist
//
//  Created by Bill Clark on 7/11/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PinDetailsViewController: UICollectionViewController, MKMapViewDelegate{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cvImages: UICollectionView!
    @IBOutlet weak var cvFlowLayout: UICollectionViewFlowLayout!
    
    
    @IBOutlet weak var btnNewCollection: UIButton!
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    var inLat = Double()
    var inLon = Double()
    var startPage = Int()
    var dataController:DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set current pin to load photos
        let pin = Pin(context: dataController.viewContext)
        
        
        //when the page loads for each pin, rest the pages to page 1
        startPage = 1
        
        getFlickrPhotosForPin(inLat: inLat, inLon: inLon) { (result) in
            if(result){
                DispatchQueue.main.async {
                    if(pinImages.count == 0){
                        //No images returned.  Hide CV
                        self.cvImages.isHidden = true
                        self.btnNewCollection.isEnabled = false
                    }else if(self.mainDelegate.maxPages == 1){
                        self.cvImages.isHidden = false
                        self.btnNewCollection.isEnabled = false
                    }else{
                        self.cvImages.isHidden = false
                        self.btnNewCollection.isEnabled = true
                    }
                    //Not sure if this is correct.  Is it really storing the images in coredata to the correct pin?
                    
//                    let photos = Photo(context: self.dataController.viewContext)
//                    for photo in pinImages{
//                        photos.photo = photo.pinImage.jpegData(compressionQuality: 1.0)
//                    }
//
//                    photos.pin = pin
//                    try? self.dataController.viewContext.save()

                    self.cvImages.reloadData()
                }
            }
            else{
                self.cvImages.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: self.inLat, longitude: self.inLon)
        
        // Here we create the annotation and set its coordiate properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        //Zoom into location
        let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //clear the pin images array for new images for next pin
        pinImages = []
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pinImages.remove(at: indexPath.row)
        cvImages.deleteItems(at: [indexPath])
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var cellCount = 21
        
        if pinImages.count > 0 {
            cellCount = pinImages.count
        }
        
        return cellCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
        //Setup activity indicator for each cell
        let activity = UIActivityIndicatorView(style: .whiteLarge)
        activity.hidesWhenStopped = true
        activity.center = CGPoint(x: cell.frame.size.width/2, y: cell.frame.size.height/2)
        
        
        cell.cellPhoto?.image = UIImage(named: "VirtualTourist_512")
        cell.addSubview(activity)
        activity.startAnimating()
    
        if pinImages.count > 0 {
            
            cell.cellPhoto?.image = pinImages[indexPath.row].pinImage
            activity.stopAnimating()
            
        }
        
        return cell
    }
    
    @IBAction func getNextPage(_ sender: Any) {
        startPage = startPage + 1
        mainDelegate.page = startPage
        btnNewCollection.isEnabled = false
        
        //Clear our datasource for the CV in order to load new imaages
        pinImages = []
        cvImages.reloadData()
        
        if(startPage <= mainDelegate.maxPages){
            getFlickrPhotosForPin(inLat: inLat, inLon: inLon) { (result) in
                if(result){
                    DispatchQueue.main.async {
                        self.cvImages.reloadData()
                        
                        //check to see if we are on the last page.  If so, disable the new collection button.
                        if(self.startPage == self.mainDelegate.maxPages){
                            self.btnNewCollection.isEnabled = false
                        }else{
                            self.btnNewCollection.isEnabled = true
                        }
                        
                    }
                }
            }
        }
    }
}
