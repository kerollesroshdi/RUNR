//
//  RunLogCell.swift
//  RUNR
//
//  Created by Kerolles Roshdi on 11/25/18.
//  Copyright © 2018 Kerolles Roshdi. All rights reserved.
//

import UIKit

class RunLogCell: UITableViewCell {

    @IBOutlet weak var runDurationLbl: UILabel!
    @IBOutlet weak var totalDistanceLbl: UILabel!
    @IBOutlet weak var avgPaceLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func congigure(run: Run) {
        runDurationLbl.text = run.duration.formatTimeDurationToString()
        totalDistanceLbl.text = "\(run.distance.meterToMiles(places: 2)) mi"
        avgPaceLbl.text = run.pace.formatTimeDurationToString()
        dateLbl.text = run.date.getDateString()
    }

}
