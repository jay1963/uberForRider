//
//  UberHandler.swift
//  Uber App For Rider
//
//  Created by jimmy.gao on 6/27/17.
//  Copyright © 2017 eservicegroup. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol UberController:class {
    
    func canCallUber(delegateCalled:Bool);
    func driverAcceptedRequest(requestAcceted:Bool, driverName:String);
    func updateDriversLocation(lat:Double, long:Double);
}

class UberHandler {
    
    private static let _instance = UberHandler();
    
    weak var delegate:UberController?;
    
    var rider = "";
    var driver = "";
    var rider_id = "";

    
    static var Instance:UberHandler {
        return _instance;
    }
    
    func oberseveMessageForRider(){
        //RIDER REQUEST UBER
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot:DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    self.rider_id = snapshot.key;
                    self.delegate?.canCallUber(delegateCalled: true);
                }
            }
        }
        
        //RIDER CANCEL UBER
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) { (snapshot:DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    self.rider_id = snapshot.key;
                    self.delegate?.canCallUber(delegateCalled: false);
                }
            }
        }
        
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot:DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String{
                    if self.driver == "" {
                        self.driver = name;
                        self.delegate?.driverAcceptedRequest(requestAcceted: true, driverName: self.driver);
                    }
                }
            }
        }
        
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot:DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver{
                        self.driver = "";
                        self.delegate?.driverAcceptedRequest(requestAcceted: false, driverName: name);
                    }
                }
            }
        }
        
        //Driver Updating Location
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if let lat = data[Constants.LATITUDE] as? Double {
                        if let long = data[Constants.LONGITUDE] as? Double {
                            self.delegate?.updateDriversLocation(lat: lat, long: long);
                        }
                    }
                }
            }
        }
    }
    
    func requestUber(latitude:Double, longitude: Double){
        let data:Dictionary<String, Any> = [Constants.NAME:rider, Constants.LATITUDE:latitude, Constants.LONGITUDE:longitude];
        DBProvider.Instance.requestRef.childByAutoId().setValue(data);
    }
    
    func cancleUber(){
        DBProvider.Instance.requestRef.child(rider_id).removeValue();
    }
    
    func updateRidersLocation(lat:Double, long:Double){
        DBProvider.Instance.requestRef.child(rider_id).updateChildValues([Constants.LATITUDE:lat,Constants.LONGITUDE:long]);
    }
    
}
