//
//  ViewController.swift
//  MachineLearningtoImage
//
//  Created by Furkan Deniz Albaylar on 10.09.2023.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    var chosenImage = CIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func changeButtonClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageLabel.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true,completion: nil)
        
        if let ciImage = CIImage(image: imageLabel.image!) {
            chosenImage = ciImage
        }
        recogImage(image: chosenImage)
    }
    func recogImage(image: CIImage){
        //Request
        //Handler
        
        resultLabel.text = "Finding..."
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            let request = VNCoreMLRequest(model: model) { vnrequest, error in
                
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    if results.count > 0 {
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            let rounded = Int(confidenceLevel*100) / 100
                            self.resultLabel.text = "\(confidenceLevel)% It's \(topResult!.identifier)"
                        }
                    }
                    
                }
                
            }
            let handler = VNImageRequestHandler(ciImage:chosenImage )
            DispatchQueue.global(qos: .userInteractive).async {
                do{
                    try handler .perform([request])
                } catch {
                    print("Error")
                    
                }
            }
            
        }
        
        
    }
    
    
}

