//
//  ViewController.swift
//  Comfort checker
//
//  Created by Libin Zhou on 7/1/19.
//  Copyright © 2019 Libin Zhou. All rights reserved.
//

import UIKit
import CoreMotion
import MapKit
import CoreLocation
import Charts


class ViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var waveButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var enter: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var output: UITextView!
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var backGround: UIImageView!
    
    //get our bundle path
    let filePath = Bundle.main.resourcePath
    let endImage = UIImage(named: "end2") as UIImage?
    let startImage = UIImage(named: "start2") as UIImage?
    let startMap = UIImage(named: "map1") as UIImage?
    let closeMap = UIImage(named: "closeMap") as UIImage?
    let startWave = UIImage(named: "realTimeWave") as UIImage?
    let closeWave = UIImage(named: "closeRealTimeWave") as UIImage?
    let manager = CMMotionManager()
    var flagStart = 1
    var flagWave = 1
    var flagMap = 1
    var lineChartEntryX = [ChartDataEntry]()
    var lineChartEntryY = [ChartDataEntry]()
    var lineChartEntryZ = [ChartDataEntry]()
    var sec = 0.0
    var newInterval = 0.0
    var sensorFlag = 0
    
    let calendar = Calendar.current
    let defaults = UserDefaults.standard
    
    
    @IBOutlet weak var background: UIImageView!
    
    
    @IBAction func openMap(_ sender: UIButton) {
        if(flagMap == 1){
            flagMap = 0
            mapButton.setImage(closeMap, for: .normal)
            MapView.isHidden = false
        }
        else{
            flagMap = 1
            mapButton.setImage(startMap, for: .normal)
            MapView.isHidden = true
        }
    }
    
    func openLineChart(data: CMDeviceMotion, interval : Double){
        /*
        let roll = data.attitude.roll
        let pitch = data.attitude.pitch
        let yaw = data.attitude.pitch
        let rolVal = ChartDataEntry(x: Double(sec), y: roll)
        let pitVal = ChartDataEntry(x: Double(sec), y: pitch)
        let yawVal = ChartDataEntry(x: Double(sec), y: yaw)
        lineChartEntryRoll.append(rolVal)
        lineChartEntryPitch.append(pitVal)
        lineChartEntryYaw.append(yawVal)
        let lineRoll = LineChartDataSet(entries: lineChartEntryRoll, label: "Roll")
        let linePitch = LineChartDataSet(entries: lineChartEntryPitch, label: "Pitch")
        let lineYaw = LineChartDataSet(entries: lineChartEntryYaw, label: "Yaw")
        lineRoll.colors = [NSUIColor.blue]
        linePitch.colors = [NSUIColor.red]
        lineYaw.colors = [NSUIColor.yellow]
        let data = LineChartData()
        data.addDataSet(lineRoll)
        data.addDataSet(linePitch)
        data.addDataSet(lineYaw)
 */
        let accelerationX = data.userAcceleration.x
        let accelerationY = data.userAcceleration.y
        let accelerationZ = data.userAcceleration.z
        let xVal = ChartDataEntry(x: Double(sec), y: accelerationX)
        let yVal = ChartDataEntry(x: Double(sec), y: accelerationY)
        let zVal = ChartDataEntry(x: Double(sec), y: accelerationZ)
        lineChartEntryX.append(xVal)
        lineChartEntryY.append(yVal)
        lineChartEntryZ.append(zVal)
        let lineX = LineChartDataSet(entries: lineChartEntryX, label: "X Acceleration")
        let lineY = LineChartDataSet(entries: lineChartEntryY, label: "Y Acceleration")
        let lineZ = LineChartDataSet(entries: lineChartEntryZ, label: "Z Acceleration")
        lineX.colors = [NSUIColor.blue]
        lineY.colors = [NSUIColor.red]
        lineZ.colors = [NSUIColor.yellow]
        let data = LineChartData()
        data.addDataSet(lineX)
        data.addDataSet(lineY)
        data.addDataSet(lineZ)
        lineChart.data = data
        sec += interval
    }
    
    
    
    @IBAction func start(_ sender: UIButton) {
        //execute all sensors and start recording
        //change logo
        //print(filePath)
        //get current time as key
        //for test
        /*
        var date = Date()
        var hour = self.calendar.component(.hour, from: date)
        var minutes = self.calendar.component(.minute, from: date)
        var seconds = self.calendar.component(.second, from: date)
        var key = String(hour)+"."+String(minutes)+"."+String(seconds)
        print(date)
        print(key)
        */
        
       
        if(flagStart == 1){
            flagStart = 0
            textField.isHidden = false
            enter.isHidden = false
            backGround.isHidden = true
            startButton.setImage(endImage, for: .normal)
            
            
            
            /*
            manager.accelerometerUpdateInterval = 1
            //print("running")
            */
            /*
            manager.startAccelerometerUpdates(to: OperationQueue.main){ (data, error)
                in var date = Date()
                var hour = self.calendar.component(.hour, from: date)
                var minutes = self.calendar.component(.minute, from: date)
                var seconds = self.calendar.component(.second, from: date)
                var key = String(hour)+"."+String(minutes)+"."+String(seconds)
                self.defaults.set(data,forKey: key)
                
            }
            */
            
            manager.startAccelerometerUpdates()
            defaults.set(manager.accelerometerData, forKey: "key")
 
            
        }
        else{
            textField.isHidden = true
            enter.isHidden = true
            backGround.isHidden = false
            startButton.setImage(startImage, for: .normal)
            manager.stopDeviceMotionUpdates()
            manager.stopGyroUpdates()
            manager.stopMagnetometerUpdates()
            manager.stopAccelerometerUpdates()
            flagStart = 1
        }
       
       
    }
    
    
    @IBAction func returnResult(_ sender: UIButton) {
        
        if(flagStart == 0){
            newInterval = NumberFormatter().number(from: textField.text ?? "0.5")!.doubleValue
            sensorFlag = 1
            
            if(manager.isDeviceMotionAvailable && sensorFlag == 1){
                var count = 0
                manager.showsDeviceMovementDisplay = true
                manager.deviceMotionUpdateInterval = 1
                manager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical,
                                                 to:OperationQueue.main, withHandler: { (data, error) in
                                                    if let validData = data {
                                                        let roll = validData.attitude.roll
                                                        let pitch = validData.attitude.pitch
                                                        let yaw = validData.attitude.yaw
                                                        let rateX = validData.rotationRate.x
                                                        let rateY = validData.rotationRate.y
                                                        let rateZ = validData.rotationRate.z
                                                        let accelerationX = validData.userAcceleration.x
                                                        let accelerationY = validData.userAcceleration.y
                                                        let accelerationZ = validData.userAcceleration.z
                                                        count += 1
                                                        let strRoll = String(roll)
                                                        let strPitch = String(pitch)
                                                        let strYaw = String(yaw)
                                                        let strCount = String (count)
                                                        let strRateX = String(rateX)
                                                        let strRateY = String(rateY)
                                                        let strRateZ = String(rateZ)
                                                        let strAcceX = String(accelerationX)
                                                        let strAcceY = String(accelerationY)
                                                        let strAcceZ = String(accelerationZ)
                                                        let result = "Count: " + strCount + " Roll: " + strRoll + " Pitch: " + strPitch + " Yaw: " + strYaw + " rateX: " + strRateX + " rateY: " + strRateY + " rateZ: " + strRateZ + " accelerationX: " + strAcceX + " accelerationY: " + strAcceY + " accelerationZ: "+strAcceZ
                                                        self.defaults.set(result,forKey: strCount)
                                                        self.openLineChart(data: validData, interval: self.newInterval)
                                                    }
                })
                
            }
            
        }
        else{
        var key = String(textField.text ?? "")
        
        if let result = defaults.string(forKey: key){
        //output.text = defaults.data(forKey: key)
        output.text = result
        output.isHidden = false
        //print(defaults.data(forKey: key))
        }
        }
        textField.isHidden = true
        enter.isHidden = true
    }
    
    
    @IBAction func realTimeWave(_ sender: UIButton) {
        if(flagWave == 1){
            waveButton.setImage(closeWave, for: .normal)
            textField.isHidden = false
            enter.isHidden = false
            flagWave = 0
            
        }
        else{
            flagWave = 1
            textField.isHidden = true
            enter.isHidden = true
            output.isHidden = true
            waveButton.setImage(startWave, for: .normal)
        }
        //print(manager.isAccelerometerAvailable)
        //print(manager.isDeviceMotionActive)
        
    }
    
   
    func saveToFile (key : String){
        let file = key + ".txt" //this is the file. we will write to and read from it
        
        let text = "some text" //just a text
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(file)
            
            //writing
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {/* error handling here */}
            
            //reading
            do {
                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
            }
            catch {/* error handling here */}
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView.isHidden = true
        textField.isHidden = true
        enter.isHidden = true
        output.isHidden = true
        
        // Do any additional setup after loading the view.
    }


}

