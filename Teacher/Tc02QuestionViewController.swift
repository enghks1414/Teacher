//
//  Tc02QuestionViewController.swift
//  Teacher
//
//  Created by doohwan Lee on 2017. 2. 6..
//  Copyright © 2017년 doohwan Lee. All rights reserved.
//

import UIKit
import TouchDraw
import Firebase
import ActionSheetPicker_3_0
import SwiftMessages

class Tc02QuestionViewController: UIViewController, TouchDrawViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, CustomPalettViewDelegate {
    
    @IBOutlet weak var navi: UINavigationItem!
    
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var photoButton: UIBarButtonItem!
    @IBOutlet weak var mergeView: UIView!
    @IBOutlet weak var ImageContainView: UIView!
    @IBOutlet weak var drawView: TouchDrawView!
    let cateDic = ["고1 수학" : "tc_h1_m", "고2 수학" : "tc_h2_m", "고3 수학" : "tc_h3_m", "수능영어" :"tc_h_e"]
    let success = MessageView.viewFromNib(layout: .CardView)
    var successConfig = SwiftMessages.defaultConfig

    var cate : String?
    var cateName : String?
    var cateIdx : Int?
    var placeholderLabel : UILabel!
    var dialog : UIAlertController!
    var penWidth : CGFloat = 2.0
    var question_txt : String = ""
    var palett : CustomPalettView?
    var imageFlag = false
    var drawFlag = false
    var indicator : IndicatorHelper?

    @IBAction func cancleAction(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
    }
  

    @IBAction func undoAction(_ sender: Any) {
        drawView.undo()
    }
    
    @IBAction func clearAction(_ sender: Any) {
        drawView.clearDrawing()
    }
    @IBAction func categoryAction(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "카테고리 선택", rows:
            Array(cateDic.keys)
            , initialSelection: 0 , doneBlock: {
                picker, indexes, values in
                self.cateName = values as? String
                self.navi.title = self.cateName
                self.cate = self.cateDic[self.cateName!]
                return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
        
    }

    @IBAction func imagePickAction(_ sender: Any) {
        let dialog = UIAlertController(title: "이미지 선택", message: nil, preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let cameraAction = UIAlertAction(title: "사진촬영", style: .default) { (action) in
            imagePicker.sourceType = .camera //사진촬영으로 이미지 가져옴
            self.present(imagePicker, animated: true)
        }
        dialog.addAction(cameraAction)
        
        
        let albumAction = UIAlertAction(title: "앨범", style: .default) { (action) in
            imagePicker.sourceType = .photoLibrary //앨범에서 이미지 가져옴
            self.present(imagePicker, animated: true)
            
            
        }
        dialog.addAction(albumAction)
        
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (action) in
        }
        if let popvc = dialog.popoverPresentationController{
            
            popvc.sourceView = self.view
        }
        dialog.addAction(cancelAction)
        
        self.present(dialog, animated: true, completion: nil)
    }
    

    
    func setColor(color: UIColor) {
        drawView.setColor(color)
        self.dismiss(animated: true, completion: nil)
    }
    func setPenWidth(width: Float) {
        penWidth = CGFloat(width)
        drawView.setWidth(penWidth)
    }
        @IBAction func drawAction(_ sender: Any) {
        dialog = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
            let margin:CGFloat = 4.0
            let rect = CGRect(x: margin, y: margin, width: dialog.view.frame.size.width-(margin*6), height: 150.0)
            palett = CustomPalettView(frame: rect)

            palett?.delegate = self
            palett?.slider.value = Float(penWidth)
            dialog.view.addSubview(palett!)
            
        
        
        
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            
        }
        dialog.addAction(okAction)
        
        
        if let popvc = dialog.popoverPresentationController{
            popvc.sourceView = self.view
        }
        
        self.present(dialog, animated: true, completion: nil)
    }
    @IBAction func uploadAction(_ sender: Any) {
        if FIRAuth.auth()?.currentUser == nil {
            let vc = self.storyboard?.instantiateViewController(withIdentifier:"auth_vc") as! TcAuthViewController
            vc.modalFlag = true
            self.present(vc, animated: true)
            return
        }
        
        
        if textView.text.isEmpty {
            let dialog = UIAlertController(title: "업로드 확인", message: "본문이 없습니다.\n본문을 입력해주세요", preferredStyle: .alert)
            
            
            let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                
            }
            
            dialog.addAction(okAction)
            
            self.present(dialog, animated: true, completion: nil)
            return
        }
        
        if cate == nil {
                let dialog = UIAlertController(title: "업로드 확인", message: "카테고리를 선택해주세요", preferredStyle: .alert)
            
                let okAction = UIAlertAction(title: "확인", style: .default, handler: { (UIAlertAction) in
                   
                })
                
                dialog.addAction(okAction)
                
                self.present(dialog, animated: true, completion: nil)
                return
        }
        let stringArr = textView.text.replacingOccurrences(of: "\n", with: " ").components(separatedBy: " ")
        let hashArr = stringArr.filter { $0.hasPrefix("#")}
        print(hashArr)
        
        let uid = (FIRAuth.auth()?.currentUser?.uid)! as String
        let name = (FIRAuth.auth()?.currentUser?.displayName)! as String
        let timestamp = Int(NSDate().timeIntervalSince1970)
        if !drawFlag, !imageFlag {
            let dialog = UIAlertController(title: "업로드 확인", message: "구분 : \(self.cateName!)\n텍스트만 질문하시겠습니까?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
                
            })
            let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                self.indicator?.start()
                let ref = FIRDatabase.database().reference()
                let userReference = ref.child("Question").childByAutoId()
                var value : Dictionary = ["questionText" : self.textView.text , "writerUid": uid, "questionPic" : "null", "writerName" : name, "writeTime": timestamp, "category" : self.cate!] as [String : Any]
                if !hashArr.isEmpty {
                    value["tag"] = hashArr
                }
                userReference.updateChildValues(value)
                self.indicator?.stop()
                self.dismiss(animated: true, completion: { 
                    SwiftMessages.show(config: self.successConfig, view: self.success)
                })
            }
            dialog.addAction(cancelAction)
            dialog.addAction(okAction)
            
            self.present(dialog, animated: true, completion: nil)
        }else{
            let dialog = UIAlertController(title: "업로드 확인", message: "구분 : \(self.cateName!)\n입력하신 내용으로 질문하시겠습니까?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
                
            })
            let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                self.indicator?.start()
                UIGraphicsBeginImageContext(self.mergeView.frame.size) // 이미지 context 생성

                self.mergeView.drawHierarchy(in: self.mergeView.frame, afterScreenUpdates: true) //Snapshot 촬영후 현재 context에 저장
                let mergeImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()! //현재 image context -> UIImage로 저장

                UIGraphicsEndImageContext()

                let filename = (FIRAuth.auth()?.currentUser?.uid)! + String(timestamp) + ".png"

                let storage = FIRStorage.storage().reference().child("Question").child(filename)

                if let uploadImage = UIImagePNGRepresentation(mergeImage){
                    storage.put(uploadImage, metadata: nil, completion: { (metadata, error) in
                        
                        if error != nil {
                            print(error as Any)
                            return
                        }else{
                            if let downUrl = metadata?.downloadURL()?.absoluteString{
                                let ref = FIRDatabase.database().reference(fromURL: "https://teacher-d9168.firebaseio.com/")
                                let userReference = ref.child("Question").childByAutoId()
                                var value : Dictionary = ["questionText" : self.textView.text , "writerUid": uid, "questionPic" : downUrl, "writerName" : name, "writeTime": timestamp, "category" : self.cate!] as [String : Any]
                                if !hashArr.isEmpty {
                                    value["tag"] = hashArr
                                }
                                userReference.updateChildValues(value)
                                self.indicator?.stop()
                                self.dismiss(animated: true, completion: {
                                    SwiftMessages.show(config: self.successConfig, view: self.success)
                                })
                            }
                            
                        }
                    })
                }
                
            }
            dialog.addAction(cancelAction)
            dialog.addAction(okAction)
            
            self.present(dialog, animated: true, completion: nil)
            
        }
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{ //수정되지 않은 이미지 선택
            if picker.sourceType == .camera { //if camera
                let newimage = imageWithImage(sourceImage: image, scaledToWidth: self.ImageContainView.frame.width )
                let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: ImageContainView.frame.width, height: newimage.size.height))
                imageview.image = newimage
                
                ImageContainView.addSubview(imageview)
                imageFlag = true
                dismiss(animated: true, completion: nil)
            }else{
                let newimage = imageWithImage(sourceImage: image, scaledToWidth: self.ImageContainView.frame.width )
                let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: ImageContainView.frame.width, height: newimage.size.height))
                imageview.image = newimage
                
                ImageContainView.addSubview(imageview)
                imageFlag = true
                dismiss(animated: true, completion: nil)
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawView.delegate = self
        drawView.setWidth(2.0)
        drawView.backgroundColor = UIColor(white: 1, alpha: 0.0)
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width , height: 1)
        topBorder.backgroundColor = UIColor.gray.cgColor
        borderView.layer.addSublayer(topBorder)
        makeCloseButton()
        undoButton.isEnabled = false
        clearButton.isEnabled = false
        indicator = IndicatorHelper(view: self.view)
        
        messageBarSet()
        
    }
    func messageBarSet(){
        success.configureTheme(.success)
        success.configureDropShadow()
        success.configureContent(title: "업로드 성공", body: "질문이 정상적으로 업로드 되었습니다.")
        success.button?.isHidden = true
        successConfig.presentationStyle = .top
        successConfig.presentationContext = .window(windowLevel: UIWindowLevelNormal)
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    override var shouldAutorotate: Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }

    func keyboardWillShow(_ noti : Notification){
        
        if let rectObj = noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue, textView.isFirstResponder
        {
            // 키보드 높이 가져옴
            let keyboardRect = rectObj.cgRectValue
            // 키보드 높이 만큼 화면 밀기
            self.view.frame.origin.y = 0 - keyboardRect.height
        }
    }
    func keyboardWillHide(_ noti : Notification){
        self.view.frame.origin.y = 0
    }

    func makeCloseButton(){
        let buttonView: UIView = UIView()
        let viewWidth: CGFloat = self.view.bounds.size.width
        let viewHeight: CGFloat = 44
        let viewRect: CGRect = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        buttonView.frame = viewRect
        buttonView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        let closeButton: UIButton = UIButton(type: UIButtonType.system)
        let buttonWidth: CGFloat = 60
        let buttonHeight: CGFloat = 30
        let buttonRect: CGRect = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
        closeButton.bounds = buttonRect
        let buttonMargin: CGFloat = 10
        let buttonCenterX = self.view.bounds.size.width - buttonMargin - buttonWidth / 2
        let buttonCenterY = buttonView.bounds.size.height / 2
        let buttonCenter = CGPoint(x: buttonCenterX, y: buttonCenterY)
        closeButton.center = buttonCenter
        closeButton.setTitle("Close", for: UIControlState())
        
        closeButton.addTarget(self, action: #selector(Tc02QuestionViewController.closeKeyboard), for: UIControlEvents.touchUpInside)
        
        buttonView.addSubview(closeButton)
        
        self.textView.inputAccessoryView = buttonView
    }
    
    func closeKeyboard(){
        self.textView.resignFirstResponder()
    }
    func undoEnabled() {
    undoButton.isEnabled = true
    }
    
    func undoDisabled() {
    undoButton.isEnabled = false
    }
    
    func redoEnabled() {
    }
    
    func redoDisabled() {
    }
    
    func clearEnabled() {
        clearButton.isEnabled = true
        drawFlag = true
    }
    
    func clearDisabled() {
        clearButton.isEnabled = false
        drawFlag = false
    }
    
}
