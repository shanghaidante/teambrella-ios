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

class TheirTextCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var avatarView: RoundImageView!
    @IBOutlet var nameLabel: ChatNameLabel!
    @IBOutlet var voteLabel: InfoHelpLabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var timeLabel: InfoHelpLabel!
    
    @IBOutlet var bubbleHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bubbleWidthConstraint: NSLayoutConstraint!
    
    func prepare(with model: ChatCellModel, cloudWidth: CGFloat, cloudHeight: CGFloat) {
        if let model = model as? ChatTextCellModel/*, model.id != id */{
            //            id = model.id
            bubbleWidthConstraint.constant = cloudWidth
            bubbleHeightConstraint.constant = cloudHeight
            if model.userAvatar != nil {
                avatarView.isHidden = false
                avatarView.show(model.userAvatar)
            } else {
                avatarView.isHidden = true
            }
        }
        //avatarView.isHidden = isPrivateChat
        //nameLabel.isHidden = isPrivateChat
        //voteLabel.isHidden = isPrivateChat || vote == nil
    }
}
