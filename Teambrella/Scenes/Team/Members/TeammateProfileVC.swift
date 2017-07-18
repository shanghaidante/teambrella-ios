//
//  TeammateProfileVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Kingfisher
import PKHUD
import UIKit

class TeammateProfileVC: UIViewController, Routable {
    struct Constant {
        static let socialCellHeight: CGFloat = 68
    }
    
    static var storyboardName: String = "Team"
    
    var isMe: Bool = false
    var teammate: TeammateLike {
        get { return self.dataSource.teammate }
        set { if self.dataSource == nil {
            self.dataSource = TeammateProfileDataSource(teammate: newValue, isMe: self.isMe)
            }
        }
    }
    
    var dataSource: TeammateProfileDataSource!
    var riskController: VotingRiskVC?
    var linearFunction: PiecewiseFunction?
    var chosenRisk: Double?
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGradientNavBar()
        registerCells()
        HUD.show(.progress, onView: view)
        dataSource.loadEntireTeammate { [weak self] in
            HUD.hide()
            self?.prepareLinearFunction()
            self?.title = self?.teammate.extended?.basic.name
            self?.collectionView.reloadData()
        }
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.sectionHeadersPinToVisibleBounds = true
        }
    }
    
    func prepareLinearFunction() {
        guard let risk = teammate.extended?.riskScale else { return }
        
        let function = PiecewiseFunction((0.2, risk.coversIfMin), (1, risk.coversIf1), (5, risk.coversIfMax))
        linearFunction = function
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showClaims(sender: UIButton) {
        if let claimCount = teammate.extended?.object.claimCount,
            claimCount == 1,
            let claimID = teammate.extended?.object.singleClaimID {
            TeamRouter().presentClaim(claimID: claimID)
        } else {
            MembersRouter().presentClaims(teammate: teammate)
        }
    }
    
    func registerCells() {
        collectionView.register(DiscussionCell.nib, forCellWithReuseIdentifier: TeammateProfileCellType.dialog.rawValue)
        collectionView.register(MeCell.nib, forCellWithReuseIdentifier: TeammateProfileCellType.me.rawValue)
        collectionView.register(CompactUserInfoHeader.nib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: CompactUserInfoHeader.cellID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToVotingRisk",
            let vc = segue.destination as? VotingRiskVC {
            riskController = vc
        }
    }
    
    func updateAmounts(with risk: Double) {
        chosenRisk = risk
        let kind = UICollectionElementKindSectionHeader
        guard let view = collectionView.visibleSupplementaryViews(ofKind: kind).first as? CompactUserInfoHeader else {
            return
        }
        guard let myRisk = teammate.extended?.riskScale?.myRisk,
            let theirRisk = teammate.extended?.basic.risk else { return }
        
        if let theirAmount = linearFunction?.value(at: risk / theirRisk * myRisk) {
            view.leftNumberView.amountLabel.text = String(format: "%.2f", theirAmount)
        }
        if let myAmount = linearFunction?.value(at: risk / myRisk * theirRisk) {
            view.rightNumberView.amountLabel.text = String(format: "%.2f", myAmount)
        }
    }
    
}

// MARK: UICollectionViewDataSource
extension TeammateProfileVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.rows(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = dataSource.type(for: indexPath).rawValue
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                               withReuseIdentifier: CompactUserInfoHeader.cellID,
                                                               for: indexPath)
    }
    
}

// MARK: UICollectionViewDelegate
extension TeammateProfileVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        TeammateCellBuilder.populate(cell: cell, with: teammate, delegate: self)
        
        // add handlers
        if let cell = cell as? TeammateObjectCell {
            cell.button.isHidden = teammate.claimsCount == 0
            cell.button.removeTarget(nil, action: nil, for: .allEvents)
            cell.button.addTarget(self, action: #selector(showClaims), for: .touchUpInside)
        } else if cell is TeammateVoteCell, let riskController = riskController {
            if let voting = teammate.extended?.voting {
                riskController.timeLabel.text = "\(voting.remainingMinutes) MIN"
            }
            riskController.teammate = teammate
            riskController.onVoteUpdate = { [weak self] risk in
                guard let me = self else { return }
                
                me.updateAmounts(with: risk)
            }
            
            riskController.onVoteConfirmed = { [weak self] risk in
                guard let me = self else { return }
                
                //HUD.show(.progress)
                me.riskController?.yourRiskValue.alpha = 0.5
                me.dataSource.sendRisk(teammateID: me.teammate.id, risk: risk, completion: { json in
                    // HUD.hide()
                    print("risk sent: received json: \(json)")
                    me.riskController?.yourRiskValue.alpha = 1
                })
            }
        }
        // self.updateAmounts(with: risk)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if let view = view as? CompactUserInfoHeader {
            view.avatarView.showAvatar(string: teammate.avatar)
            
            if let left = view.leftNumberView {
                left.titleLabel.text = "Team.TeammateCell.coversMe".localized
                let amount = teammate.extended?.basic.coversMeAmount
                left.amountLabel.text = ValueToTextConverter.textFor(amount: amount)
                left.currencyLabel.text = "USD"
            }
            
            if let right = view.rightNumberView {
                right.titleLabel.text = "Team.TeammateCell.coverThem".localized
                let amount = teammate.extended?.basic.iCoverThemAmount
                right.amountLabel.text = ValueToTextConverter.textFor(amount: amount)
                right.currencyLabel.text = "USD"
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let identifier = dataSource.type(for: indexPath)
        if identifier == .dialog || identifier == .dialogCompact, let extendedTeammate = teammate.extended {
            let context = ChatContext.teammate(extendedTeammate)
            TeamRouter().presentChat(context: context)
        }
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension TeammateProfileVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let wdt = collectionView.bounds.width - 16 * 2
        switch dataSource.type(for: indexPath) {
        case .summary:
            return CGSize(width: collectionView.bounds.width, height: 210)
        case .object:
            guard teammate.claimsCount > 0 else { return CGSize(width: wdt, height: 216) }
            
            return CGSize(width: wdt, height: 296)
        case .stats:
            return CGSize(width: wdt, height: 368)
        case .contact:
            let base: CGFloat = 38
            let cellHeight: CGFloat = Constant.socialCellHeight
            return CGSize(width: wdt, height: base + CGFloat(dataSource.socialItems.count) * cellHeight)
        case .dialog:
            return CGSize(width: collectionView.bounds.width, height: 120)
        case .me:
            return CGSize(width: collectionView.bounds.width, height: 210)
        case .voting:
            return CGSize(width: wdt, height: 350)
        case .dialogCompact:
            return  CGSize(width: collectionView.bounds.width, height: 98)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return dataSource.isNewTeammate ? CGSize(width: collectionView.bounds.width, height: 60) : CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return dataSource.isNewTeammate ?  CGSize.zero : CGSize(width: collectionView.bounds.width, height: 81)
    }
}

// MARK: UITableViewDataSource
extension TeammateProfileVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.socialItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ContactCellTableCell", for: indexPath)
    }
}

// MARK: UITableViewDelegate
extension TeammateProfileVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ContactCellTableCell {
            let item = dataSource.socialItems[indexPath.row]
            cell.avatarView.image = item.icon
            cell.topLabel.text = item.name.uppercased()
            cell.bottomLabel.text = item.address
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.socialCellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
