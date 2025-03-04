//
//  addNickNameViewController.swift
//  GardenGuruXcode
//
//  Created by Nikhil Gupta on 05/02/25.
//

import UIKit

class addNickNameViewController: UIViewController {

    let alertView = UIView()
    let textField = UITextField()
    let cancelButton = UIButton(type: .system)
    let addButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#EBF4EB")

        print("hello from")
        setupView()
        setupAlertBox()
        setupButtons()
   
    }
    
    func setupView() {
        view.backgroundColor = UIColor(hex: "#EBF4EB")
        setupNavigationBar()
        alertView.backgroundColor = UIColor.systemGray5
        alertView.layer.cornerRadius = 16
        alertView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alertView)
        
        NSLayoutConstraint.activate([
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.widthAnchor.constraint(equalToConstant: 300),
            alertView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    private func setupNavigationBar() {
        // Set the title
        title = "Set NickName"
        
                
        // Configure the navigation bar appearance
        //navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.systemGreen
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        // Add a custom "Cancel" button to the right side
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(didTapCancel)
        )
        navigationItem.rightBarButtonItem = cancelButton
        
        // Optionally, you can customize the back button if you want to show a custom icon or text
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(didTapCancel)
        )
    }
    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupAlertBox() {
        let titleLabel = UILabel()
        titleLabel.text = "Let's Give Nickname First"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        alertView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: alertView.centerXAnchor)
        ])
        
        textField.placeholder = "Enter nickname"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        alertView.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setupButtons() {
        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, addButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 8
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        alertView.addSubview(buttonStack)
        
        
        
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            buttonStack.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 40)
            
                        
        
        ])
        
        cancelButton.setTitle("Cancel", for: .normal)
         cancelButton.setTitleColor(.red, for: .normal)
          cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
           addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(.systemBlue, for: .normal)
         addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }
    
    @objc func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc func addTapped() {
        guard let nickname = textField.text, !nickname.isEmpty else { return }
        print("Nickname saved: \(nickname)")
        

        let newController = SetReminderViewController()
        newController.locationLabel.text = nickname
        if let navController = navigationController {
               navController.pushViewController(newController, animated: true)
           } else {
               present(newController, animated: true)
           }
        // navigationController?.present(newController, animated: true)

    }
   

}



   
