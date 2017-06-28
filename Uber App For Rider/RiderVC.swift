//
//  RiderVC.swift
//  Uber App For Rider
//
//  Created by jimmy.gao on 6/27/17.
//  Copyright © 2017 eservicegroup. All rights reserved.
//

import UIKit
import MapKit

class RiderVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberController {

    @IBOutlet weak var myMap: MKMapView!
    
    @IBOutlet weak var callUberBtn: UIButton!
    
    
    private var locationManager = CLLocationManager();
    private var userLocation:CLLocationCoordinate2D?;
    private var driverLocation:CLLocationCoordinate2D?;
    
    var timer = Timer();
    
    private var canCallUber = true;
    private var riderCancelReuqest = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        UberHandler.Instance.oberseveMessageForRider();
        UberHandler.Instance.delegate = self;
        
        // Do any additional setup after loading the view.
    }
    
    private func initializeLocationManager(){
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locationManager.location?.coordinate{
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude);
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
            myMap.setRegion(region, animated: true);
            myMap.removeAnnotations(myMap.annotations);
            if driverLocation != nil {
                if !canCallUber {
                    let driverAnnotation = MKPointAnnotation();
                    driverAnnotation.coordinate = driverLocation!;
                    driverAnnotation.title = "Driver Location";
                    myMap.addAnnotation(driverAnnotation);
                    
                }
            }
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!;
            annotation.title = "Rider Location";
            myMap.addAnnotation(annotation);
        }
        
    }
    
    func updateRidersLocation(){
        UberHandler.Instance.updateRidersLocation(lat: Double(userLocation!.latitude), long: Double(userLocation!.longitude));
    }
    
    func canCallUber(delegateCalled: Bool) {
        if delegateCalled {
            callUberBtn.setTitle("Cancel Uber", for: UIControlState.normal);
            canCallUber = false;
        }else{
            callUberBtn.setTitle("Call Uber", for: UIControlState.normal);
            canCallUber = true;
        }
    }
    
    func driverAcceptedRequest(requestAcceted: Bool, driverName: String) {
        if !riderCancelReuqest{
            if requestAcceted {
                alertTheUser(title: "Uber Accepted", message: "\(driverName) Accepted Your Uber Request");
            }else{
                UberHandler.Instance.cancleUber();
                timer.invalidate();
                alertTheUser(title: "Uber Canceled", message: "\(driverName) Canceled Your Uber Request");
            }
        }
        
    }
    
    func updateDriversLocation(lat: Double, long: Double) {
        driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long);
        
    }
    
    @IBAction func callUber(_ sender: AnyObject) {
        if userLocation != nil {
            if canCallUber {
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(RiderVC.updateRidersLocation), userInfo: nil, repeats: true);
                UberHandler.Instance.requestUber(latitude:Double((userLocation?.latitude)!), longitude:Double((userLocation?.longitude)!));
                canCallUber = false;
            }else{
                riderCancelReuqest =  true;
                UberHandler.Instance.cancleUber();
                timer.invalidate();
            }
        }
    }
    
    
    @IBAction func logout(_ sender: AnyObject) {
        if AuthProvider.Instance.logOut() {
            if !canCallUber {
                UberHandler.Instance.cancleUber();
                timer.invalidate();
            }
            dismiss(animated: true, completion: nil);
        }else {
            alertTheUser(title: "Could Not Logout", message: "We could not logout at the moment, please try again later");
        }
        
    }
    
    private func alertTheUser(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
        
    }

}
