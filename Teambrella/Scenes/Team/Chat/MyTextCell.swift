//
/* Copyright(C) 2016-2018 Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import UIKit

class MyTextCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var nameLabel: ChatNameLabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var timeLabel: InfoHelpLabel!
    @IBOutlet var voteLabel: InfoHelpLabel!
    
    @IBOutlet var bubbleWidthConstraint: NSLayoutConstraint!
    @IBOutlet var bubbleHeightConstraint: NSLayoutConstraint!
    
    func prepare() {
        //nameLabel.isHidden = isPrivateChat
        //voteLabel.isHidden = isPrivateChat || vote == nil
    }
}
