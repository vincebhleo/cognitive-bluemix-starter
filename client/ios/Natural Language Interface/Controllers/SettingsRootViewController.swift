//
//  SettingsRootViewController.swift
//  Natural Language Interface
//
//  Created by Minakshi Ghanekar on 25/01/17.
//  Copyright © 2017 Persistent. All rights reserved.
//

import UIKit

class SettingsRootViewController: UIViewController , settingsDelegate{
    
    var settingsViewController: SettingsViewController?
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var saveView: UIView!    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setThemeColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIButton) {
        settingsViewController?.delegate = self
        settingsViewController?.save()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue" {
            settingsViewController = segue.destination as? SettingsViewController
            
        }
    }
    
    // MARK : settingsDelegate methods
    func didFinishSaving()
    {
        self.setThemeColor()
    }
    
    func setThemeColor()
    {
        // set theme color
        ThemeManager.sharedInstance.readThemeSettings()
        let color:UIColor = UIColor(hexString: ThemeManager.sharedInstance.colorCode)
        self.headerView.backgroundColor = color
        self.closeView.backgroundColor = color
        self.titleView.backgroundColor = color
        self.titleLabel.backgroundColor = color
        self.saveView.backgroundColor = color
    }
    

}
