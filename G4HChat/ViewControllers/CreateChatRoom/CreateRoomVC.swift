//
//  CreateRoomVC.swift
//  G4HChat
//
//  Created by 陳建佑 on 05/03/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
class CreateRoomVC: UIViewController {

    @IBOutlet private var indicatorLeft: NSLayoutConstraint!
    @IBOutlet var titleLabels: [UILabel]!


    class func instance() -> CreateRoomVC {
        let board = UIStoryboard(name: "Chat", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "CreateRoomVC") as! CreateRoomVC
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    deinit {
        let socket = WebSocketManager.shard
        socket.leaveTopic("fnd")
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CreateRoomVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = UIScreen.main.bounds.size.width
        let offset = scrollView.contentOffset.x
        let page = offset / width

        self.indicatorLeft.constant = offset / 3
        if page.truncatingRemainder(dividingBy: 1.0) == 0 {
            self.showPage(page: Int(page))
        }
    }
}

// MARK: Func
extension CreateRoomVC {
    private func showPage(page: Int) {
        for (idx, lab) in self.titleLabels.enumerated() {
            let hex = (idx == page) ? Configure.myBlue: "000000"
            lab.textColor = UIColor(hex: hex)
        }
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        let vcs = self.childViewControllers
        if page == 0 {
            let vc = vcs.first(where: {$0 is CreateSingleVC}) as! CreateSingleVC
            vc.thePageShow()
        } else if page == 1 {
            IQKeyboardManager.sharedManager().enable = true
            let vc = vcs.first(where: {$0 is CreateGroupVC}) as! CreateGroupVC
            vc.thePageShow()
        } else {
            let vc = vcs.first(where: {$0 is SubByIDVC}) as! SubByIDVC
            vc.thePageShow()
        }
    }
}
