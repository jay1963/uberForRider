//
//  SignInVC.swift
//  Uber App For Rider
//
//  Created by jimmy.gao on 6/27/17.
//  Copyright © 2017 eservicegroup. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInVC: UIViewController {
    
    private let RIDER_SEGUE = "RiderVC";
  
    @IBOutlet weak var emailTextField: UITextField!
  
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    @IBAction func login(_ sender: AnyObject) {
        if(emailTextField.text != "" && passwordTextField.text != ""){
            AuthProvider.Instance.login(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                if message != nil{
                    self.alertTheUser(title: "Problem With Authentication", message: message!);
                }else{
                    
                    UberHandler.Instance.rider = self.emailTextField.text!;
                    self.emailTextField.text = "";
                    self.passwordTextField.text = "";
                    self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil);
                }
            })
        }else{
            alertTheUser(title: "Email And Password Required", message: "Please Enter Email And Password In The TextField");
        }
    }
  
    @IBAction func signUp(_ sender: AnyObject) {
        if(emailTextField.text != "" && passwordTextField.text != ""){
            AuthProvider.Instance.signUp(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                if message != nil {
                    self.alertTheUser(title: "Problem With Creating A New User", message: message!);
                }else{
                    self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil);
                }
            })
        }else{
            alertTheUser(title: "Email And Password Required", message: "Please Enter Email And Password In The TextField");
        }
        
    }
    
    private func alertTheUser(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
        
    }
    
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
