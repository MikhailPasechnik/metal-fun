//
//  GameViewController.swift
//  scene-kit-test
//
//  Created by Mikhail Pasechnik on 11.02.2022.
//

import UIKit
import QuartzCore
import SceneKit
import GLTFSceneKit


class GameViewController: UIViewController {

    func makeSphere(scene: SCNScene, rangeX: Int, rangeZ: Int, mul: Double = 0.1, radius: Double = 0.03) {
        let program = SCNProgram()
        program.vertexFunctionName = "textureSamplerVertex"
        program.fragmentFunctionName = "textureSamplerFragment"
        guard let landscapeImage  = UIImage(named: "landscape") else {
          return
        }
        let materialProperty = SCNMaterialProperty(contents: landscapeImage)

        let sphere = SCNSphere(radius: radius)
        sphere.firstMaterial?.program = program
        sphere.firstMaterial?.setValue(materialProperty, forKey: "customTexture")
        
        for i in 0...rangeX {
            for j in 0...rangeZ {
                let sphereNode = SCNNode(geometry: sphere)
                
                sphereNode.position = SCNVector3(Double(i) * mul, 0, Double(j) * mul)

                
                // Parent sphere node into the rootNode of SCENE
                scene.rootNode.addChildNode(sphereNode)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // animate the 3d object
        // ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let node = SCNNode(geometry: box)
        node.position = SCNVector3(0,0,0)
        scene.rootNode.addChildNode(node)
        makeSphere(scene: scene, rangeX: 10, rangeZ: 10, mul: 1, radius: 0.5)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
            
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                result.node.scale = SCNVector3(1, 1, 1)
                let box = SCNBox()
                box.firstMaterial?.program = result.node.geometry?.firstMaterial?.program;
                box.firstMaterial?.setValue(result.node.geometry?.firstMaterial?.value(forKey: "customTexture"), forKey: "customTexture")
                result.node.geometry = box
                SCNTransaction.commit()
            }
            
            result.node.scale = SCNVector3(0.1, 0.1, 0.1)
            SCNTransaction.commit()
            
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
