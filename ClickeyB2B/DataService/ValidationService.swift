//
//  Regex.swift
//  Clickey
//
//  Created by Sem Shafiq on 13/08/15.
//  Copyright © 2015 Clickey. All rights reserved.
//

import Foundation

enum ValidationTypes: Int {
    case UserName
    case Email
    case Password
}

enum ValidationError:String{
    case userMinChars = "Gebruikersnaam moet meer dan 3 tekens lang zijn"
    case userTaken = "Deze gebruikersnaam is al gebruikt"
    case invalidEmail = "Vul alstublieft een geldig e-mail adres in"
    case emailTaken = "Dit e-mail adres is al bezet"
    case invalidPassword = "Dit wachtwoord is niet ok"
}

public class ValidationService: ClickeyServiceConsumer {
    
    internal var inputField: SmartTextField
    internal var type: ValidationTypes
    public var approvedInput: String = ""
    public var isValid: Bool = false
    
    init(textField:SmartTextField, validationType:ValidationTypes){
        inputField = textField
        type = validationType
    }
    
    //MARK:-
    public func textFieldEditingChanged(){
        onInputEdit()
    }
    
    public func textFieldEditingDidEnd(completion:()->Void){
            onInputEnd(completion)
    }
    
    //MARK:-
    func showValidationError(message:String, title:String="Error Occured"){
        NSNotificationCenter.defaultCenter().postNotificationName("showValidationError", object: self, userInfo: ["title": title, "message": message])
        inputField.errorTitle = title
        inputField.errorMessage = message
    }
    func showMessage(message:String, title:String="Error Occured"){
        NSNotificationCenter.defaultCenter().postNotificationName("showMessage", object: self, userInfo: ["title": title, "message": message])
    }
    
    static func isValidEmail(email:String) -> Bool{
        let predicate = NSPredicate(format: "SELF MATCHES %@", "[^\\s@]+@[^\\s@]+\\.[^\\s@]+")
        return predicate.evaluateWithObject(email)
    }
    
    private func onInputEnd(completion:()->Void){
        let isValid = type == ValidationTypes.Email ? ValidationService.isValidEmail(inputField.text!) : true
        if inputField.text!.characters.count > 3 && isValid || (type == .Password && inputField.text!.characters.count > 3) {
            
            if inputField.text != approvedInput{
                inputField.showWaiting()
                switch type{
                case .UserName:
                    service.verifyUserName(inputField.text!){result in
                        self.handelServerResponse(result, completion: completion)
                    }
                case .Email:
                    service.verifyEmail(inputField.text!){result in
                        self.handelServerResponse(result, completion: completion)
                    }
                case .Password:
                    service.verifyPassword(inputField.text!){result in
                        self.handelServerResponse(result, completion: completion)
                    }
                }
            }
            
        }else if inputField.text!.characters.count < 4 && type == .UserName{
            self.showValidationError(ValidationError.userMinChars.rawValue, title: "Invalid User Name")
            inputField.showError()
        }else if type == .Email{
            self.showValidationError(ValidationError.invalidEmail.rawValue, title: "Invalid Email")
            inputField.showError()
        }else if type == .Password{
            self.showValidationError(ValidationError.invalidPassword.rawValue, title: "Invalid Password")
            inputField.showError()
        }
    }
    
    private func onInputEdit(){
        switch type{
        case .Email:
            if inputField.text?.characters.count > 0{
                if ValidationService.isValidEmail(inputField.text!) {
                    inputField.removeSign()
                }else{
                    inputField.showError()
                    inputField.isValid = false
                }
            }
        default:
            inputField.removeSign()
        }
    }
    
    internal func handelServerResponse(result:HTTPResult<Bool>, completion:()->Void){
        dispatch_async(dispatch_get_main_queue()){
            switch result {
            case let .Error(error):
                let message = "\(error)"
                self.showMessage(message)
            case let .Success(valid):
                print(valid)
                if valid {
                    self.isValid = true
                    self.inputField.showSuccess()
                    self.showValidationError("", title:"")
                    self.approvedInput = self.inputField.text!
                    self.inputField.isValid = true
                    completion()
                } else {
                    self.showServerErrorMessage()
                    self.inputField.showError()
                    self.inputField.isValid = false
                }
            }
            self.inputField.enabled = true
        }
    }
    
    internal func showServerErrorMessage(){
        switch type{
        case .UserName:
            showValidationError("\(ValidationError.userTaken.rawValue)", title: "Error")
        case .Email:
            showValidationError("\(ValidationError.emailTaken.rawValue)", title: "Error")
        case .Password:
            showValidationError("\(ValidationError.invalidPassword.rawValue)", title: "Error")
        }
    }
}
