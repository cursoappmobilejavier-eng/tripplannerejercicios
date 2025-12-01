//
//  SignUpViewController.swift
//  TripPlanner
//
//  Created by Mananas on 20/11/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordRepeatTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Calcula la fecha máxima permitida (hoy - 18 años)
        let calendar = Calendar.current
        let today = Date()
        if let maxDate = calendar.date(byAdding: .year, value: -18, to: today) {
            birthDatePicker.maximumDate = maxDate
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        if (!validateData()) {
            return
        }
        
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let gender = genderSegmentedControl.selectedSegmentIndex
        let birthDate = birthDatePicker.date
        let email = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        Auth.auth().createUser(withEmail: email, password: password) { [unowned self] authResult, error in
            if let error = error {
                print(error.localizedDescription)
                self.showMessage(message: error.localizedDescription)
                return
            }
            
            let userId = authResult!.user.uid
            
            let user = User(id: userId, firstName: firstName, lastName: lastName, email: email, gender: gender, birthDate: birthDate.millisecondsSince1970)
            
            do {
                let db = Firestore.firestore()
                try db.collection("Users").document(userId).setData(from: user)
            } catch let error {
                print("Error writing user to Firestore: \(error)")
                self.showMessage(message: error.localizedDescription)
                return
            }
            
            print("User created account successfully")
            self.showMessage(title: "Create account", message: "Account created successfully")
        }
    }

    func validateData() -> Bool {
        if firstNameTextField.text?.isEmpty ?? true {
            showMessage(message: "You must enter a first name")
            return false
        }
        if lastNameTextField.text?.isEmpty ?? true {
            showMessage(message: "You must enter a last name")
            return false
        }
        if passwordTextField.text != passwordRepeatTextField.text {
            showMessage(message: "Password do not match repeat password")
            return false
        }
        return true
    }
}
