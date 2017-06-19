//
//  AddEventController.swift
//  PersonCalendar
//
//  Created by Rau Muong on 6/7/17.
//  Copyright © 2017 Macbook. All rights reserved.
//
import Foundation
import UIKit

class AddEventController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tfEventName: UITextField!
    @IBOutlet weak var tfNote: UITextView!
    @IBOutlet weak var tfStartDate: UITextField!
    @IBOutlet weak var tfEndDate: UITextField!
    @IBOutlet weak var tfStartTime: UITextField!
    @IBOutlet weak var tfEndTime: UITextField!
    @IBOutlet weak var switchAllDay: UISwitch!
    @IBOutlet weak var imgView: UIImageView!
    
    let picker = UIImagePickerController()
    let utils = UIUtils()
    
    private let userDefaults = UserDefaults.standard
    private let keyUserDefaults: String = "event_list_key"
    private(set) var eventList:[EventObject] {
        
        get {
            if let eventistData = userDefaults.object(forKey: keyUserDefaults) {
                if let eventlist = NSKeyedUnarchiver.unarchiveObject(with: eventistData as! Data) {
                    return eventlist as! [EventObject]
                }
            }
            return []
        }
        
        set(eventlist) {
            let eventistData = NSKeyedArchiver.archivedData(withRootObject: eventlist)
            userDefaults.set(eventistData, forKey: keyUserDefaults)
            userDefaults.synchronize()
        }
    }
    
    var eventEdit = EventObject()
    
    func documentsPath(forFileName name: String) -> String {
        let paths: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsPath: String? = (paths[0] as? String)
        return URL(fileURLWithPath: documentsPath!).appendingPathComponent(name).path
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        //btn save
        let rightBtn = utils.buildButton(image: UIImage(), title: "Save", colorText: UIColor.colorFromRGB(0x3498db))
        rightBtn.addTarget(self, action: #selector(AddEventController.onClickBtnSave), for: .touchUpInside)
        let rightBtnBar = UIBarButtonItem()
        rightBtnBar.customView = rightBtn
        self.navigationItem.rightBarButtonItem = rightBtnBar
        // title view
        self.navigationItem.title = "Add New Event"
        // btn back
        self.navigationItem.backBarButtonItem?.title = "Back"
        tfNote.layer.borderWidth = 1
        tfNote.layer.borderColor = UIColor.lightGray.cgColor
        tfNote.layer.cornerRadius = 5
        
        // config tap imageView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddEventController.tapImageView(tapGestureRecognizer:)))
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(tapGestureRecognizer)
        
        //config tap textfield
        tfStartDate.addTarget(self, action: #selector(AddEventController.openPopupSelectDate(textField:)), for: .touchDown)
        tfEndDate.addTarget(self, action: #selector(AddEventController.openPopupSelectDate(textField:)), for: .touchDown)
        
        if eventEdit.eventId != 0 {
            self.navigationItem.title = "Edit Event"
            loadDataToForm()
        }else{
            tfStartDate.text = utils.dateFormatter.string(from: Date())
            tfEndDate.text = utils.dateFormatter.string(from: Date())            
        }
        
        // reload page
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AddEventController.reloadPage(_:)),
                                               name: NSNotification.Name(rawValue: "selectDate"),
                                               object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // load page
    func reloadPage(_ notification: Notification){
        if (notification.name.rawValue == "selectDate") {
            if notification.userInfo != nil{
                let userInfo:Dictionary<String,String> =
                    notification.userInfo as! Dictionary<String,String>
                let selectDate = userInfo["selectDate"]!
                let dateOf = userInfo["dateOf"]!
                switch dateOf {
                case "start":
                    tfStartDate.text = selectDate
                case "end":
                    tfEndDate.text = selectDate
                default:
                    tfStartDate.text = selectDate
                    tfEndDate.text = selectDate
                }
            }
        }
        
    }
    
    func onClickBtnSave() {
        if validateForm() {
            let eventId = eventEdit.eventId == 0 ? self.createEventId() : eventEdit.eventId
            let imageData = UIImageJPEGRepresentation(self.imgView.image!, 1)
            let imagePath: String = documentsPath(forFileName: "image_\(eventId).jpg")
            do{
                try imageData?.write(to: URL.init(fileURLWithPath: imagePath), options: .withoutOverwriting)
            }
            catch{
                print("test")
            }
            let eventItem = EventObject.init(eventId: eventId, eventName: tfEventName.text!, startDate: utils.dateFormatter.date(from: tfStartDate.text!)!, endDate: utils.dateFormatter.date(from: tfEndDate.text!)!, startTime: tfStartTime.text!, endTime: tfEndTime.text!, note: tfNote.text!, allDay: switchAllDay.isOn, avatar: imagePath)
            saveEvent(event: eventItem, isTypeAction: eventEdit.eventId == 0 ? actionTypeOfEvent.save : actionTypeOfEvent.edit)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addEventOK"), object: nil, userInfo: nil)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func loadDataToForm(){
        tfEventName.text = eventEdit.eventName
        tfNote.text = eventEdit.note
        tfStartDate.text = utils.dateFormatter.string(from: eventEdit.startDate)
        tfEndDate.text = utils.dateFormatter.string(from: eventEdit.endDate)
        tfStartTime.text = eventEdit.startTime
        tfEndTime.text = eventEdit.endTime
        switchAllDay.isOn = eventEdit.allDay
        let imagePath = eventEdit.avatar
        print("path: \(eventEdit.avatar)")
        if imagePath != "" {
            do{
                try imgView.image = UIImage(data: Data.init(contentsOf: URL.init(fileURLWithPath: imagePath)))
            }catch{
                print("cc")
            }
        }
    }
    
    func createEventId() -> Int {
        if self.eventList.count > 0 {
            let idMax = self.eventList.map{ $0.eventId }.max()
            return (idMax! + 1)
        }
        return 1
    }
    
    func tapImageView(tapGestureRecognizer: UITapGestureRecognizer){
        let alert = UIAlertController(title: "New Avatar", message: "Choose one image to make avatar for event", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let openCamera = UIAlertAction(title: "Open Camera", style: UIAlertActionStyle.default) { _ in
            self.openCamera()
        }
        let openFolder = UIAlertAction(title: "Open Library Image", style: UIAlertActionStyle.default) { _ in
            self.openLibPhoto()
        }
        let dismiss = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        // relate actions to controllers
        alert.addAction(openCamera)
        alert.addAction(openFolder)
        alert.addAction(dismiss)
        
        present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(self.picker,animated: true,completion: nil)
        }
    }
    
    func openLibPhoto(){
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.modalPresentationStyle = .pageSheet
        present(picker, animated: true, completion: nil)
    }
    
    func openPopupSelectDate(textField: UITextField){
        var selectDate = Date()
        var dateOf = ""
        switch textField {
        case tfStartDate:
            selectDate = utils.dateFormatter.date(from: tfStartDate.text!)!
            dateOf = "start"
        case tfEndDate:
            selectDate = utils.dateFormatter.date(from: tfEndDate.text!)!
            dateOf = "end"
        default:
            selectDate = Date()
        }
        
        
        let popup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopupSelectDate") as! PopupSelectDate
        popup.selectDate = selectDate
        popup.dateOf = dateOf
        self.addChildViewController(popup)
        popup.view.frame = self.view.frame
        self.view.addSubview(popup.view)
        popup.didMove(toParentViewController: self)
    }
    
    //MARK: - Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var chosenImage = UIImage()
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imgView.contentMode = .scaleAspectFit
        imgView.image = chosenImage
//        avatarData = UIImagePNGRepresentation(chosenImage)!
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func validateForm() -> Bool {
        if tfEventName.text == "" {
            showAlert(msg: "Event name is required")
            return false
        }
        if utils.dateFormatter.date(from: tfStartDate.text!)?.compare(utils.dateFormatter.date(from: tfEndDate.text!)!) == .orderedDescending {
            showAlert(msg: "Date time is wrong")
            return false
        }
        return true
    }
    
    func showAlert(msg: String){
        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    open func saveEvent(event: EventObject, isTypeAction: actionTypeOfEvent){
        var eventList = self.eventList
        switch isTypeAction {
        case .save:
            eventList.append(event)
        case .edit:
            if let index = eventList.index(where: {$0.eventId == event.eventId} ){
                eventList.remove(at: index)
                eventList.insert(event, at: index)
            }
        case .delete:
            if let index = eventList.index(where: {$0.eventId == event.eventId} ){
                eventList.remove(at: index)
            }
        }
        self.eventList = eventList
    }
}

enum actionTypeOfEvent: Int{
    case save
    case edit
    case delete
}
