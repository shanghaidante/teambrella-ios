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

class ChatBubbleCell: UICollectionViewCell, ChatUserDataCell, XIBInitableCell {
    
    @IBOutlet var avatarView: RoundImageView!
    @IBOutlet var bubble: UIImageView!
    @IBOutlet var nameLabel: ChatNameLabel!
    @IBOutlet var voteLabel: InfoHelpLabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var timeLabel: InfoHelpLabel!
    
    @IBOutlet var bubbleHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bubbleWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet var nameLabelLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var textViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var timeLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var voteLabelTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet var stackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var stackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var avatarHeightConstraint: NSLayoutConstraint!
    
    var isMy: Bool = false {
        didSet {
            avatarView.isHidden = isMy
            bubble.image = isMy ? #imageLiteral(resourceName: "myTextBubble") : #imageLiteral(resourceName: "theirTextBubble")
            setupTrailingConstraints(isMy: isMy)
            stackViewLeadingConstraint.isActive = !isMy
            stackViewTrailingConstraint.isActive = isMy
        }
    }
    
    var id: String = ""
    
    lazy var avatarTap: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        return gesture
    }()
    
    var onTapImage: ((ChatBubbleCell, GalleryView) -> Void)?
    
    func setupTrailingConstraints(isMy: Bool) {
        textViewTrailingConstraint.constant = isMy ? -18 : -8
        timeLabelTrailingConstraint.constant = isMy ? -18 : -8
        voteLabelTrailingConstraint.constant = isMy ? -18 : -8
        nameLabelLeadingConstraint.constant = isMy ? 8 : 18
    }
    
    func setupTextView() {
        textView.textColor = .charcoalGray
        textView.font = UIFont.teambrella(size: 14)
        textView.isEditable = false
        textView.dataDetectorTypes = .all
        textView.isScrollEnabled = false
    }
    
    func prepare(with model: ChatCellModel, cloudWidth: CGFloat, cloudHeight: CGFloat) {
        if let model = model as? ChatTextCellModel, model.id != id {
            id = model.id
            isMy = model.isMy
            bubbleWidthConstraint.constant = cloudWidth + 30
            bubbleHeightConstraint.constant = cloudHeight
            
            setupTextView()
            nameLabel.text = model.userName.entire
            setupVoteLabel(rateText: model.rateText)
            setupTimeLabel(date: model.date)
            setupAvatar(avatar: model.userAvatar, cloudHeight: cloudHeight)
            setupFragments(fragments: model.fragments, sizes: model.fragmentSizes)
        }
    }
    
    private func setupAvatar(avatar: Avatar?, cloudHeight: CGFloat) {
        avatarHeightConstraint.constant = 15 * UIScreen.main.nativeScale
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(self.avatarTap)
        
        guard isMy == false, let avatar = avatar else {
            avatarView.isHidden = true
            return
        }
        
        avatarView.isHidden = false
        avatarView.show(avatar)
    }
    
    private func setupVoteLabel(rateText: String?) {
        if let rate = rateText {
            voteLabel.isHidden = false
            voteLabel.text = rate
            voteLabel.sizeToFit()
        } else {
            voteLabel.isHidden = true
        }
    }
    
    private func setupTimeLabel(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.timeStyle = .short
        timeLabel.text = dateFormatter.string(from: date)
        timeLabel.sizeToFit()
    }
    
    private func setupFragments(fragments: [ChatFragment], sizes: [CGSize]) {
        for (idx, fragment) in fragments.enumerated() {
            switch fragment {
            case let .text(text):
                textView.text = text
            default:
                break
            }
        }
    }
    
    private func onTap(galleryView: GalleryView) {
        onTapImage?(self, galleryView)
    }
}
