//
//  MapVC.swift
//  Pixel-Map
//
//  Created by Amr on 5/30/19.
//  Copyright © 2019 Amr. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var PullUpViewHeight: NSLayoutConstraint!
    @IBOutlet weak var TheHiddenView: UIView!
    
    //@IBOutlet weak var MapViewToDown: NSLayoutConstraint!
    var LocationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadies:Double = 1000
    
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    var ScreenSize = UIScreen.main.bounds
    
   // var flowLayout = UICollectionViewFlowLayout()
   //var collectionView: UICollectionView?
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    var titleArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView.delegate = self
        LocationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
       // collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
       // collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
       // collectionView?.delegate = self
       // collectionView?.dataSource = self
       // collectionView?.backgroundColor =  #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
       // TheHiddenView.addSubview(collectionView!)
        photosCollectionView?.delegate = self
        photosCollectionView?.dataSource = self
    }
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        MapView.addGestureRecognizer(doubleTap)
    }

    func addswipe(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(AnimateViewUppp))
        swipe.direction = .up
        TheHiddenView.addGestureRecognizer(swipe)
    }

   func animateViewDown(){
        PullUpViewHeight.constant = 350
        //MapViewToDown.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func AnimateViewUppp(){
        removeSpinner()
        removeProgressLabel()
        cancelAllSessions()
        PullUpViewHeight.constant = 1
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        
    }
    
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (ScreenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        spinner?.startAnimating()
        TheHiddenView.addSubview(spinner!)
        //collectionView?.addSubview(spinner!)
    }
    func removeSpinner(){
        if spinner != nil{
            spinner?.removeFromSuperview()
        }
    }
    func addProgressLabel(){
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (ScreenSize.width / 2) - 120, y: 175, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 14)
        progressLbl?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        progressLbl?.textAlignment = .center
        //progressLbl?.text = "12/40 PHOTOS LOADED"
       TheHiddenView.addSubview(progressLbl!)
        //collectionView?.addSubview(progressLbl!)
    }
    func removeProgressLabel(){
        if progressLbl != nil{
            progressLbl?.removeFromSuperview()
        }
    }
 
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        //animateViewUp()
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
        
    }
    
    
   
}

    extension MapVC: MKMapViewDelegate {
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation{
                return nil
            }
         let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            pinAnnotation.pinTintColor = #colorLiteral(red: 1, green: 0.7142460737, blue: 0.08423896924, alpha: 1)
            pinAnnotation.animatesDrop = true
            return pinAnnotation
        }
        func centerMapOnUserLocation(){
            guard let coordinate = LocationManager.location?.coordinate else {return}
            let coordinateRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: regionRadies * 2.0,longitudinalMeters: regionRadies * 2.0 )
            //regionRadies is a var =1000 in the begin of that class
            MapView.setRegion(coordinateRegion, animated: true)
        }
        
        @objc func dropPin(sender: UITapGestureRecognizer){
            removePin()
            removeSpinner()
            removeProgressLabel()
            cancelAllSessions()
            
            imageArray = []
            imageUrlArray = []
            photosCollectionView.reloadData()
            
            animateViewDown()
            addswipe()
            addSpinner()
            addProgressLabel()
            
            let touchpoint = sender.location(in: MapView)
            let touchCoordinate = MapView.convert(touchpoint, toCoordinateFrom: MapView)
            // add Annotation (pin)
            let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
            MapView.addAnnotation(annotation)
            //print(FlickrUrl(forApiKey: ApiKey, withAnnotation: annotation, andNumberOfPhotos: 3))
            // foucs on the pin 1000 meter * 1000 meter
            let coordinateRegion = MKCoordinateRegion.init(center: touchCoordinate, latitudinalMeters: regionRadies * 2.0, longitudinalMeters: regionRadies * 2.0 )
            //regionRadies is a var =1000 in the start of that class
            MapView.setRegion(coordinateRegion, animated: true)
            retrievUrls(forAnnotation: annotation) { (finished) in
                if finished == true{
                    self.retrievImages(handler: { (finished) in
                       if finished == true{
                     // hide spinner, hide progressLabe, reload collectionView
                     self.removeSpinner()
                     self.removeProgressLabel()
                     self.photosCollectionView?.reloadData()
                        }
            })
                } }
        }
        func removePin(){
            for annotation in MapView.annotations{
                MapView.removeAnnotation(annotation)
            }
        }
        
        func retrievUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
           // imageUrlArray = []
            Alamofire.request(FlickrUrl(forApiKey: ApiKey, withAnnotation: annotation, andNumberOfPhotos: 47)).responseJSON { (response) in
 
                 guard let json = response.result.value as? Dictionary<String, AnyObject> else {return}
                  let photosDic = json["photos"] as! Dictionary<String, AnyObject>
                  let photosDicArray = photosDic["photo"] as! [Dictionary<String, AnyObject>]
                for photo in photosDicArray{
                    
                      let postUrl="https://live.staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!).jpg"
                    let title = "\(photo["title"]!)"
                      self.imageUrlArray.append(postUrl)
                      self.titleArray.append(title)
                     }
               // print(self.imageUrlArray)
                handler(true)
                
            }
}
        func retrievImages(handler: @escaping (_ status: Bool) -> ()){
          //  imageArray = []
          //  print(self.imageUrlArray)   dee sh5alaa -->  now we have a problem in download the images NOT in getting the urls of images
            for url in imageUrlArray{
                Alamofire.request(url).responseImage(completionHandler:{ (response) in
                    guard let imagey = response.result.value else { return }
                    self.imageArray.append(imagey)
                    print(self.imageArray.count)
                    self.progressLbl?.text = "\(self.imageArray.count)/47   PHOTOS  DOWNLOADED"
                    
                    if self.imageArray.count == self.imageUrlArray.count {
                       handler(true)
                    }
           })
            }
        }
        
        func cancelAllSessions(){
            Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
                sessionDataTask.forEach({ $0.cancel() })
                downloadData.forEach({ $0.cancel() })
            }
        }
        
        
}

    extension MapVC: CLLocationManagerDelegate{
        func configureLocationServices(){
            if authorizationStatus == .notDetermined{
                LocationManager.requestAlwaysAuthorization()
                //LocationManager.requestWhenInUseAuthorization()
            }else { return }
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           centerMapOnUserLocation()
        }
    }

extension MapVC: UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myImageCell", for: indexPath) as? imagexxxCell else { return UICollectionViewCell() }
        let myIndex = imageArray[indexPath.row]
        let MOimageView = UIImageView(image: myIndex)
        cell.addSubview(MOimageView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let mypopVc = storyboard?.instantiateViewController(withIdentifier: "PopVc") as? PopVc else { return }
      //  titleArray[indexPath.row]
        mypopVc.initData(forImage: imageArray[indexPath.row], forTitle: titleArray[indexPath.row])
        present(mypopVc, animated: true, completion: nil)
        
 }

    



}


