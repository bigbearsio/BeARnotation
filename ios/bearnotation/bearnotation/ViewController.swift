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
    
    // Fucking hackathon code
    // for planeCenter2
    // x = planeSizeCGFloat + 0.5
    let planeCenter2 = SCNVector3(x: 1.5, y: -1.5, z: -3 )
    
    func setupDebug() {
        // Set appearance of debug output panel
        messagePanel.layer.cornerRadius = 3.0
        messagePanel.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        debug = DebugView(frame: CGRect.zero)
        self.view.addSubview(debug)
        
        /// Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //This is the marker
        let planeNode = createPlane(center: planeCenter, size: planeSizeCGFloat, color: UIColor.green)
        
        let planeNode2 = createPlane(center: planeCenter2, size: planeSizeCGFloat, color: UIColor.red)
        
        sceneView.scene.rootNode.addChildNode(planeNode)
        sceneView.scene.rootNode.addChildNode(planeNode2)
        
        tap.numberOfTapsRequired = 2
        tap.addTarget(self, action: #selector(self.removeObj))
        debugPrint("loaded")
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        debugPrint("add guesture")
    }
    
    func createPlane(center: SCNVector3, size :CGFloat, color: UIColor) -> SCNNode {
        let planeGeometry = SCNPlane(width: size, height: size)
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.eulerAngles = SCNVector3(x: GLKMathDegreesToRadians(-90), y: 0, z: 0)
        planeNode.position = center
        
        let greenMaterial = SCNMaterial()
        greenMaterial.diffuse.contents = color
        greenMaterial.transparency = 0.5
        planeGeometry.materials = [greenMaterial]
        
        return planeNode
    }
    
    @objc func removeObj() {
        groupNode?.removeFromParentNode()
        groupNode = nil
    }
    
    var groupNode: SCNNode? = nil
    
    func addObj() {
        groupNode = SCNNode()
        
        groupNode!.addChildNode(loadNode(file: "art.scnassets/Lowpoly_tree_sample.dae",
                                         loc: SCNVector3(x: -1.0, y:-1.4, z:-4),
                                         scale: SCNVector3(x: 0.07, y:0.07, z:0.07)))
        groupNode!.addChildNode(loadNode(file: "art.scnassets/ship.scn",
                                         loc: SCNVector3(x: 9, y:7, z:-4),
                                         scale: SCNVector3(x: 20.0, y:20.0, z:20.0)))
        sceneView.scene.rootNode.addChildNode(groupNode!)
    }
    
    func loadNode(file: String, loc:SCNVector3, scale: SCNVector3) -> SCNNode {
        let loadingObjNode = SCNNode()
        
        let loadingScene = SCNScene(named: file)!
        let nodeArray = loadingScene.rootNode.childNodes
        loadingObjNode.position = loc
        loadingObjNode.scale = scale
        
        for childNode in nodeArray {
            loadingObjNode.addChildNode(childNode as SCNNode)
        }
        
        return loadingObjNode
    }
    
    
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
            FirstPlaneTrigger(position: position!)
        }
    }
    
    func FirstPlaneTrigger(position: simd_float4) {
        let x = position.x
        let z = position.z
        
        if (x > (planeCenter.x - planeSize/2) && x < (planeCenter.x + planeSize/2) &&
            z > (planeCenter.z - planeSize/2) && z < (planeCenter.z + planeSize/2)) {
            
            if(groupNode == nil) {
                debugPrint(x,z,planeCenter)
                addObj()
            }
        }
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

