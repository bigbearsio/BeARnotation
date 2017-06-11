//
//  ViewController.swift
//  bearnotation
//
//  Created by Mahasak Pijittum on 6/10/2560 BE.
//  Copyright © 2560 Mahasak Pijittum. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreGraphics

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var nodeCount : Int = 0
    @IBOutlet weak var messagePanel: UIView!
    let tap = UITapGestureRecognizer()
    var debug : DebugView! = nil
    
    let planeSize: Float = 1
    let planeSizeCGFloat: CGFloat = 1
    let planeCenter = SCNVector3(x: 0, y: -1.5, z: -2)
    
    func setupDebug() {
        // Set appearance of debug output panel
        messagePanel.layer.cornerRadius = 3.0
        messagePanel.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        debug = DebugView(frame: CGRect.zero)
        self.view.addSubview(debug)
        
        
        //let light = SCNLight()
        //light.type = SCNLight.LightType.omni
        //let lightNode = SCNNode()
        //lightNode.light = light
        //lightNode.position = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
        
        //sceneView.scene.rootNode.addChildNode(lightNode)
        
        /// Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        
        //This is the marker
        let planeGeometry = SCNPlane(width: planeSizeCGFloat, height: planeSizeCGFloat)
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.eulerAngles = SCNVector3(x: GLKMathDegreesToRadians(-90), y: 0, z: 0)
        planeNode.position = planeCenter
        
        let greenMaterial = SCNMaterial()
        greenMaterial.diffuse.contents = UIColor.green
        greenMaterial.transparency = 0.5
        planeGeometry.materials = [greenMaterial]
        
        sceneView.scene.rootNode.addChildNode(planeNode)
        
        tap.numberOfTapsRequired = 2
        tap.addTarget(self, action: #selector(self.removeObj))
        debugPrint("loaded")
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        debugPrint("add guesture")
    }
    
    @objc func removeObj() {
        groupNode?.removeFromParentNode()
        groupNode = nil
    }
    
    func addObj() {
        groupNode = SCNNode()
        
        groupNode!.addChildNode(loadNode(file: "art.scnassets/Lowpoly_tree_sample.dae",
                                         loc: SCNVector3(x: 0, y:-1.4, z:-4),
                                         scale: SCNVector3(x: 0.07, y:0.07, z:0.07)))
        sceneView.scene.rootNode.addChildNode(groupNode!)
    }
    
    func loadNode(file: String, loc:SCNVector3, scale: SCNVector3) -> SCNNode {
        let loadingObjNode = SCNNode()
        
        let loadingScene = SCNScene(named: file)!
        let nodeArray = loadingScene.rootNode.childNodes
        groupNode!.position = loc
        groupNode!.scale = scale
        
        for childNode in nodeArray {
            groupNode!.addChildNode(childNode as SCNNode)
        }
        
        return loadingObjNode
    }
    
    var groupNode: SCNNode? = nil
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let timeInterval = NSDate().timeIntervalSince1970
        let unixTimestamp = NSDate(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Specify your format that you want
        let strDate = dateFormatter.string(from: unixTimestamp as Date)
        
        
        let position = sceneView.session.currentFrame?.camera.transform.columns.3;
        
        if(position != nil) {
            let x = position!.x
            let z = position!.z
            
            if (x > (planeCenter.x - planeSize/2) && x < (planeCenter.x + planeSize/2) &&
                z > (planeCenter.z - planeSize/2) && z < (planeCenter.z + planeSize/2)) {
                
                if(groupNode == nil) {
                    debugPrint(x,z,planeCenter)
                    addObj()
                }
            }
        }
        
        //debugPrint("rendered at" + strDate)
    }
    
    @objc func addScene() {
        debugPrint("add scene tap")
        let sceneView = SCNView(frame: self.view.frame)
        sceneView.allowsCameraControl = true
        
        self.view.addSubview(sceneView)
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: -3.0, y: 3.0, z: 3.0)
        
        
        let light = SCNLight()
        light.type = SCNLight.LightType.omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
        
        //This is the marker
        let planeGeometry = SCNPlane(width: 2.0, height: 2.0)
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.eulerAngles = SCNVector3(x: GLKMathDegreesToRadians(-90), y: 0, z: 0)
        planeNode.position = SCNVector3(x: 0, y: 0.1, z: 0)
        
        let greenMaterial = SCNMaterial()
        greenMaterial.diffuse.contents = UIColor.green
        greenMaterial.transparency = 0.3
        planeGeometry.materials = [greenMaterial]
        
        //This is the floor
        let floorGeometry = SCNPlane(width: 50.0, height: 50.0)
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.eulerAngles = SCNVector3(x: GLKMathDegreesToRadians(-90), y: 0, z: 0)
        floorNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor.brown
        floorGeometry.materials = [floorMaterial]
        
        let constraint = SCNLookAtConstraint(target: planeNode)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(planeNode)
        scene.rootNode.addChildNode(floorNode)
        
        
        let groupNode = SCNNode()
        let loadingScene = SCNScene(named: "art.scnassets/ship.scn")!
        let nodeArray = loadingScene.rootNode.childNodes
        groupNode.scale = SCNVector3(x: 0.1, y:0.1, z:0.1)
        
        for childNode in nodeArray {
            groupNode.addChildNode(childNode as SCNNode)
        }
        scene.rootNode.addChildNode(groupNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        switch camera.trackingState {
        case .notAvailable:
            debugPrint("not available")
        case .limited:
            debugPrint("limited")
        case .normal:
            debugPrint("normal")
            
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        //session.currentFrame!.camera
        debugPrint("xxxxx")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

