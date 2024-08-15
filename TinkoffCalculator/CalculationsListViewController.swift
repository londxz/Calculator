//
//  CalculationsListViewController.swift
//  TinkoffCalculator
//
//  Created by Родион Холодов on 15.08.2024.
//

import UIKit

class CalculationsListViewController: UIViewController {
    
    var result: String?
    
    
    @IBOutlet weak var calculationLabel: UILabel!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        modalPresentationStyle = .overFullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //calculationLabel.textColor = .white
        
        calculationLabel.text = result
        //calculationLabel.backgroundColor = .white
    }
}
