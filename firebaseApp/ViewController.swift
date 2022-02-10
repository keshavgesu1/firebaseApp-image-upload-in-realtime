//
//  ViewController.swift
//  firebase
//
//  Created by Keshav Raj Kashyap on 17/01/22.
//

import UIKit
import Firebase
import FirebaseStorage
import MGPhotoPicker
class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var reference = DatabaseReference.init()//A FIRDatabaseReference       represents a particular location in your Firebase Database and can be used for reading or writing data to that Firebase Database location.
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        reference = Database.database().reference()
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(openGallery))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
        }
    
    @IBAction func btnSave(_ sender: UIButton) {
        //saveFireBaseData()
      saveImages()
    }
    
    //image open gallery
    @objc func openGallery(tapGesture:UITapGestureRecognizer){
        self.setUpImagePicker()
    }
  
    //save firebase data
    func saveFireBaseData(){
        let storageReference = Storage.storage().reference().child("myImage.png")
        let imageData = imageView.image?.pngData()
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        storageReference.putData(imageData!, metadata: nil) { (metadata, errors) in
            if errors == nil && metadata != nil{
                print(metadata!)
            }
        }
  
    }
    
    
    //MARK: UPLOAD IMAGE FROM GALLERY
    func saveImages(){
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
        
        if let uploadData = self.imageView.image!.pngData() {
            storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
                
                if let error = err {
                    print(error)
                    return
                }
                
                storageRef.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    guard let url = url else { return }
                    let values = ["name": "keshav", "email": "email", "profileImageUrl": url.absoluteString]
                    self.registerUserIntoDatabaseWithUID(values:values as [String:AnyObject])
                })
                
            })
        }
    }
        
 func registerUserIntoDatabaseWithUID(values: [String: AnyObject]) {
    let ref = Database.database().reference()
    let usersReference = ref.child("users").child("hello")
    
    usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
        
        if let err = err {
            print(err)
            return
        }
        
        self.dismiss(animated: true, completion: nil)
    })
}
}

//MARK: UPLOAD IMAGE FROM GALLERY
extension ViewController: UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    func setUpImagePicker(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.delegate = self
            imagePicker.isEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage]as? UIImage
        imageView.image = image
        self.dismiss(animated: true, completion: nil )
    }
}












struct StorageService {
    // provide method for uploading images
    static func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        // 1
        guard let imageData = image.jpegData(compressionQuality: 0.1) else {
            return completion(nil)
        }

        // 2
        reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
            // 3
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }

            // 4
            reference.downloadURL(completion: { (url, error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    return completion(nil)
                }
                           completion(url)
                       })
                   })
               }
}


//
struct PostService {
    static func create(for image: UIImage) {
        let imageRef = Storage.storage().reference().child("test_image.jpg")
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }

            let urlString = downloadURL.absoluteString
            print("image url: \(urlString)")
        }
    }
}

