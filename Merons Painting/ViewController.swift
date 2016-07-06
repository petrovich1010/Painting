//
//  ViewController.swift
//  Merons Painting
//
//  Created by Nikolai on 26/03/16.
//  Copyright © 2016 Nikolai. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, ACEDrawingViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, ColorPickerDelegate {

    
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var drawView: ACEDrawingView!
    
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var penwidthSlider: UISlider!

    @IBOutlet weak var btnColor: UIButton!
    @IBOutlet weak var buttonsView: UIView!
    
    
    var isOpenImage : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sliderView.alpha = 0.0
        
        
        drawImage()
        if !isOpenImage {
            openData()
        }
    }
    
    
    func openData() {
        isOpenImage = true
        print("test-opened")
    }

    private func drawImage() {
        drawView.drawTool = ACEDrawingToolTypePen
        drawView.lineWidth = 3.0
        drawView.delegate = self
        
    }
    
/********************************************* Button Events *************************************************/
    @IBAction func btnPenWidth_Clicked(sender: AnyObject) {
        UIView.animateWithDuration(0.2, animations: {
            self.sliderView.alpha = 1.0
        })
    }
    
    @IBAction func btnPenColour_Clicked(sender: AnyObject) {
        self.showColorPicker()
    }
    
    @IBAction func btnAddImage_Clicked(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary){
            let picker = UIImagePickerController()
            picker.sourceType = .PhotoLibrary
            // picker.allowsEditing = true
            picker.delegate = self
            
            presentViewController(picker, animated:true, completion: nil)
        }
    }
    
    @IBAction func btnSave_Clicked(sender: AnyObject) {
        UIGraphicsBeginImageContextWithOptions(canvasView.frame.size, false, 0)
        canvasView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let exportImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(exportImage, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    // callback
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        if error != nil {
            print(error.code)
        }
        else {
            showSaveAlert()
        }
    }
    
    func showSaveAlert() {
        let alert = UIAlertController(title: "SUCCESS", message: "Saved image to Library!", preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action -> Void in })
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func btnClear_Clicked(sender: AnyObject) {
        let alertController = UIAlertController(title: "Wait", message: "Do you want erase the drawing？", preferredStyle: .Alert)
        let deleteAction = UIAlertAction(title: "OK", style: .Default) {
            action in self.drawView.clear()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func btnwidthDone_Clicked(sender: AnyObject) {
        UIView.animateWithDuration(0.3, animations: {
            self.sliderView.alpha = 0.0
        })
    }

   
    
/********************************************* SliderPicker Value Change *************************************************/
    
    @IBAction func slidervalueChanged(sender: UISlider) {
        let currentValue = CGFloat(sender.value)
        drawView.lineWidth = currentValue
    }

    
     
/********************************************* ImagePickerController Delegate *************************************************/
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        viewTransition(image)
        picker.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func viewTransition(image:UIImage? = nil){
        
//        backgroundImageView.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleWidth
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFit
        backgroundImageView.image = image
    }
    
    
    // MARK: Popover delegate functions
    
    // Override iPhone behavior that presents a popover as fullscreen.
    // i.e. now it shows same popover box within on iPhone & iPad
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        
        // show popover box for iPhone and iPad both
        return UIModalPresentationStyle.None
    }
    
    
    
    
    
/********************************************* Color Picker Delegate *************************************************/
    
    var selectedColor: UIColor = UIColor.blueColor()
    var selectedColorHex: String = "0000FF"
    
    
    // called by color picker after color selected.
    func colorPickerDidColorSelected(selectedUIColor selectedUIColor: UIColor, selectedHexColor: String) {
        
        // update color value within class variable
        self.selectedColor = selectedUIColor
        self.selectedColorHex = selectedHexColor
        
        // set preview background to selected color
        self.drawView.lineColor = selectedUIColor
    }
    
    
    
    // MARK: - Utility functions
    
    // show color picker from UIButton
    private func showColorPicker(){
        
        // initialise color picker view controller
        let colorPickerVc = storyboard?.instantiateViewControllerWithIdentifier("sbColorPicker") as! ColorPickerViewController
        
        // set modal presentation style
        colorPickerVc.modalPresentationStyle = .Popover
        
        // set max. size
        colorPickerVc.preferredContentSize = CGSizeMake(265, 400)
        
        // set color picker deleagate to current view controller
        // must write delegate method to handle selected color
        colorPickerVc.colorPickerDelegate = self
        
        // show popover
        if let popoverController = colorPickerVc.popoverPresentationController {
            
            // set source view
            popoverController.sourceView = self.buttonsView
            
            // show popover form button
            popoverController.sourceRect = self.btnColor.frame
            
            // show popover arrow at feasible direction
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.Any
            
            // set popover delegate self
            popoverController.delegate = self
        }
        
        //show color popover
        presentViewController(colorPickerVc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

