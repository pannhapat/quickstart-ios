// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import Firebase


// MARK: - Extending a `AuthProvider` to conform to `DataSourceProvidable`

extension AuthProvider: DataSourceProvidable {
    
    private static var providers: [AuthProvider] {
        [.Google, .Apple, .Twitter, .Microsoft, .GitHub, .Yahoo, .Facebook]
    }
    
    static var providerSection: Section {
        let providers = self.providers.map { Item(title: $0.rawValue) }
        let header = "Identity Providers"
        let footer = "Choose a login flow from one of the identity providers above."
        return Section(headerDescription: header, footerDescription: footer, items: providers)
    }
    
    static var emailPasswordSection: Section {
        let image = UIImage(named: "firebaseIcon")
        let item = Item(title: self.EmailPassword.rawValue, hasNestedContent: true, image: image)
        let footer = "A example login flow with password authentication."
        return Section(footerDescription: footer, items: [item])
    }
    
    static var otherSection: Section {
        let lockSymbol = UIImage.systemImage("lock.slash.fill", tintColor: .systemOrange)
        let phoneSymbol = UIImage.systemImage("phone.fill", tintColor: .systemOrange)
        let anonSymbol = UIImage.systemImage("questionmark.circle.fill", tintColor: .systemOrange)
        let shieldSymbol = UIImage.systemImage("lock.shield.fill", tintColor: .systemOrange)
        
        let otherOptions = [
            Item(title: self.Passwordless.rawValue, image: lockSymbol),
            Item(title: self.PhoneNumber.rawValue, image: phoneSymbol),
            Item(title: self.Anonymous.rawValue, image: anonSymbol),
            Item(title: self.Custom.rawValue, image: shieldSymbol)
        ]
        return Section(footerDescription: "Other authentication methods.", items: otherOptions)
    }
    
    static var sections: [Section] {
        [providerSection, emailPasswordSection, otherSection]
    }
    
    var sections: [Section] { AuthProvider.sections }

}


// MARK: - Extending a `Firebase User` to conform to `DataSourceProvidable`

extension User: DataSourceProvidable {

    private var infoSection: Section {
        let items = [Item(title: self.providerID, detailTitle: "Provider ID"),
                        Item(title: self.uid, detailTitle: "UUID"),
                        Item(title: self.displayName ?? "––", detailTitle: "Display Name", isEditable: true),
                        Item(title: self.photoURL?.absoluteString ?? "––", detailTitle: "Photo URL", isEditable: true),
                        Item(title: self.email ?? "––", detailTitle: "Email", isEditable: true),
                        Item(title: self.phoneNumber ?? "––", detailTitle: "Phone Number")]
        return Section(headerDescription: "Info", items: items)
    }

    private var metaDataSection: Section {
        let metadataRows = [Item(title: self.metadata.lastSignInDate?.description, detailTitle: "Last Sign-in Date"),
                            Item(title: self.metadata.creationDate?.description, detailTitle: "Creation Date")]
        return Section(headerDescription: "Firebase Metadata", items: metadataRows)
    }

    private var otherSection: Section {
        let otherRows = [Item(title: self.isAnonymous ? "Yes" : "No", detailTitle: "Is User Anonymous?"),
                         Item(title: self.isEmailVerified ? "Yes" : "No", detailTitle: "Is Email Verified?")]
        return Section(headerDescription: "Other", items: otherRows)
    }

    private var actionSection: Section {
        let actionsRows = [
            Item(title: UserAction.refreshUserInfo.rawValue, textColor: .systemBlue),
            Item(title: UserAction.signOut.rawValue, textColor: .systemBlue),
            Item(title: UserAction.link.rawValue, textColor: .systemBlue, hasNestedContent: true),
            Item(title: UserAction.requestVerifyEmail.rawValue, textColor: .systemBlue),
            Item(title: UserAction.tokenRefresh.rawValue, textColor: .systemBlue),
            Item(title: UserAction.delete.rawValue, textColor: .systemRed)
        ]
        return Section(headerDescription: "Actions", items: actionsRows)
    }

    var sections: [Section] {
        [infoSection, metaDataSection, otherSection, actionSection]
    }

}

// MARK: - UIKit Extensions

extension UITableView {
    open override var showsVerticalScrollIndicator: Bool {
        get{ false }
        set{}
    }
}

extension UIViewController {
    
    public  func displayError(_ error: Error?, from function: StaticString = #function) {
        guard let error = error else { return }
        print("🚨 Error in \(function): \(error.localizedDescription)")
        let message = "\(error.localizedDescription)\n\n Ocurred in \(function)"
        let errorAlertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        errorAlertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(errorAlertController, animated: true, completion: nil)
    }
    
}

extension UINavigationController {
    
    func configureTabBar(title: String, systemImageName: String) {
        let tabBarItemImage = UIImage(systemName: systemImageName)
        tabBarItem = UITabBarItem(title: title,
                                  image: tabBarItemImage?.withRenderingMode(.alwaysTemplate),
                                  selectedImage: tabBarItemImage)
    }
    
    enum titleType: CaseIterable {
        case regular, large
    }
    
    func setTitleColor(_ color: UIColor, _ types: [titleType] = titleType.allCases) {
        if types.contains(.regular) {
            self.navigationBar.titleTextAttributes = [.foregroundColor : color]
        }
        if types.contains(.large) {
            self.navigationBar.largeTitleTextAttributes = [.foregroundColor : color]
        }
    }
    
}

extension UITextField {
    func setImage(_ image: UIImage?) {
        guard let image = image else { return }
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        imageView.contentMode = .scaleAspectFit
        
        let containerView = UIView()
        containerView.frame = CGRect(x: 20, y: 0, width: 40, height: 40)
        containerView.addSubview(imageView)
        leftView = containerView
        leftViewMode = .always
    }
}

extension UIImageView {
    convenience init(systemImageName: String, tintColor: UIColor? = nil) {
        var systemImage = UIImage(systemName: systemImageName)
        if let tintColor = tintColor {
            systemImage = systemImage?.withTintColor(tintColor, renderingMode: .alwaysOriginal)
        }
        self.init(image: systemImage)
    }
    
    func setImage(from url: URL?) {
        guard let url = url else { return }
        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: url) else { return }
            
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self.image = image
                self.contentMode = .scaleAspectFit
            }
        }
    }
}

extension UIImage {
    
    static func systemImage(_ systemName: String, tintColor: UIColor) -> UIImage? {
        let systemImage = UIImage(systemName: systemName)
        return systemImage?.withTintColor(tintColor, renderingMode: .alwaysOriginal)
    }

}

extension UIColor {
    static let highlightedLabel = UIColor.label.withAlphaComponent(0.8)
    
    var highlighted: UIColor { self.withAlphaComponent(0.8) }
    
    var image: UIImage {
        let pixel = CGSize(width: 1, height: 1)
        return UIGraphicsImageRenderer(size: pixel).image { (context) in
            self.setFill()
            context.fill(CGRect(origin: .zero, size: pixel))
        }
    }
}

// MARK: UINavigationBar + UserDisplayable Protocol

protocol UserDisplayable {
    func addProfilePic(_ imageView: UIImageView)
}

extension UINavigationBar: UserDisplayable {
    func addProfilePic(_ imageView: UIImageView) {
        let length = self.frame.height * 0.46
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = length/2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            imageView.heightAnchor.constraint(equalToConstant: length),
            imageView.widthAnchor.constraint(equalToConstant: length)
        ])
    }
}

// MARK: Extending UITabBarController to work with custom transition animator

extension UITabBarController: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let fromIndex = tabBarController.viewControllers!.firstIndex(of: fromVC)!
        let toIndex = tabBarController.viewControllers!.firstIndex(of: toVC)!
        
        let direction : Animator.TransitionDirection =  fromIndex < toIndex ? .right : .left
        return Animator(direction)
    }
    
    func transitionToViewController(atIndex index: Int) {
        self.selectedIndex = index
    }
}

// MARK: - Foundation Extensions

extension Date {
    var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }
}
