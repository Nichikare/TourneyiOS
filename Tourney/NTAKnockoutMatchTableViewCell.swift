//
//  NTAKnockoutMatchTableViewCell.swift
//  Tourney
//
//  Created by Joe Fender on 16/01/2015.
//  Copyright (c) 2015 Nichikare Corporation. All rights reserved.
//

import UIKit

class NTAKnockoutMatchTableViewCell: UITableViewCell {

    @IBOutlet weak var nameALabel: UILabel!
    @IBOutlet weak var nameBLabel: UILabel!
    @IBOutlet weak var winnerAButton: UIButton!
    @IBOutlet weak var winnerBButton: UIButton!
    @IBOutlet weak var scoreALabel: UILabel!
    @IBOutlet weak var scoreBLabel: UILabel!
    @IBOutlet weak var wonAImage: UIImageView!
    @IBOutlet weak var wonBImage: UIImageView!
    
    // For associating a match with this cell.
    var mid = 0
    
    // Delgate for dealing with winner buttons
    var delegate: NTAKnockoutTableViewControllerDelegate?
    
    @IBAction func setWinnerA(sender: AnyObject) {
        delegate?.setWinner(self.mid, index: 0)
    }
    
    @IBAction func setWinnerB(sender: AnyObject) {
        delegate?.setWinner(self.mid, index: 1)
    }
}
