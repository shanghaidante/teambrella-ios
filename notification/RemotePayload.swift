//
/* Copyright(C) 2017 Teambrella, Inc.
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
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import Foundation

struct APS {
    let body: String?
    let title: String?
    let subtitle: String?
    let hasContent: Bool
    let sound: String?
    let threadID: String?
    let category: String?

    init(dict: [AnyHashable: Any]) {
        if let alert = dict["alert"] as? [String: String] {
            body = alert["body"] ?? ""
            title = alert["title"]
            subtitle = alert["subtitle"]
        } else {
            body = nil
            title = nil
            subtitle = nil
        }
        hasContent = dict["mutable-content"] as? Bool ?? false
        sound = dict["sound"] as? String
        threadID = dict["thread-id"] as? String
        category = dict["category"] as? String
    }
}

protocol RemoteTopicDetails {
    var topicID: String { get }
}

struct RemotePayload {
    
    struct Claim: RemoteTopicDetails {
        let topicID: String
        
        let claimID: Int
        let userName: String
        let objectName: String
        let avatar: String
        
        init?(dict: [AnyHashable: Any]) {
            var dict = dict
            self.topicID = dict["TopicId"] as? String ?? ""
            if let claimDict = dict["Claim"] as? [AnyHashable: Any] { dict = claimDict }
            guard let id = dict["ClaimId"] as? Int ?? (dict["ClaimId"] as? String).flatMap { Int($0) },
                let userName = dict["UserName"] as? String,
                let objectName = dict["ObjectName"] as? String,
                let avatar = dict["SmallPhoto"] as? String else { return nil }
            
            self.claimID = id
            self.userName = userName
            self.objectName = objectName
            self.avatar = avatar
        }
    }
    
    struct Teammate: RemoteTopicDetails {
        let topicID: String
        
        let userID: String
        let userName: String
        let avatar: String
        
        init?(dict: [AnyHashable: Any]) {
            var dict = dict
            self.topicID = dict["TopicId"] as? String ?? ""
            if let teammateDict = dict["Teammate"] as? [AnyHashable: Any] { dict = teammateDict }
            guard let id = dict["UserId"] as? String,
                let userName = dict["UserName"] as? String,
                let avatar = dict["Avatar"] as? String else { return nil }
            
            self.userID = id
            self.userName = userName
            self.avatar = avatar
        }
    }
    
    struct Discussion: RemoteTopicDetails {
        let topicID: String
        let topicName: String
        
        init?(dict: [AnyHashable: Any]) {
            guard let discussion = dict["Discussion"] as? [String: Any] else { return nil }
            guard let id = dict["TopicId"] as? String,
                let name = discussion["TopicName"] as? String else { return nil }

            self.topicID = id
            self.topicName = name
        }
    }
    
    let dict: [AnyHashable: Any]
    
    var claim: RemotePayload.Claim?
    var teammate: RemotePayload.Teammate?
    var discussion: RemotePayload.Discussion?
    
    var topicDetails: RemoteTopicDetails? { return claim ?? discussion ?? teammate }
    
    var type: RemoteCommandType { return (dict["Cmd"] as? Int).flatMap { RemoteCommandType(rawValue: $0) } ?? .unknown }
    var timestamp: Int64 { return dict["Timestamp"] as? Int64 ?? 0 }
    
    var teamID: Int? { return dict["TeamId"] as? Int }
    var teamName: String? { return dict["TeamName"] as? String }
    var newTeammatesCount: Int? { return dict["NewTeammates"] as? Int }
    
    var userID: String? { return dict["UserId"] as? String }
    var userName: String? { return dict["UserName"] as? String }
    var teammateID: Int? { return dict["TeammateId"] as? Int ?? (dict["TeammateId"] as? String).flatMap { Int($0) } }
    var message: String? { return dict["Message"] as? String }
    
    var topicID: String? { return dict["TopicId"] as? String }
    var postID: String? { return dict["PostId"] as? String }
    var topicName: String? { return dict["TopicName"] as? String }
    //var text: String? { return dict["Text"] as? String }
    var postsCount: String? { return dict["Count"] as? String }
    
    var claimID: Int? { return dict["ClaimId"] as? Int ?? (dict["ClaimId"] as? String).flatMap { Int($0) } }
    
    var amount: String? { return dict["Count"] as? String ?? dict["Amount"] as? String }
    var cryptoAmount: String? { return dict["BalanceCrypto"] as? String }
    var currencyAmount: String? { return dict["BalanceFiat"] as? String }
    
    var avatar: String? { return dict["Avatar"] as? String }
    var teamURL: String? { return dict["TeamUrl"] as? String }
    var teamLogo: String? { return dict["TeamLogo"] as? String }
    
    // MARK: Convenience getters
    
    var teamIDValue: Int { return value(from: teamID) }
    var teamNameValue: String { return value(from: teamName) }
    var newTeammatesCountValue: Int { return value(from: newTeammatesCount) }
    var userIDValue: String { return value(from: userID) }
    var userNameValue: String { return value(from: userName) }
    var teammateIDValue: Int { return value(from: teammateID) }
    var messageValue: String { return value(from: message) }
    var topicIDValue: String { return value(from: topicID) }
    var postIDValue: String { return value(from: postID) }
    var topicNameValue: String { return value(from: topicName) }
    var postsCountValue: String { return value(from: postsCount) }
    var claimIDValue: Int { return value(from: claimID) }
    var amountValue: String { return value(from: amount) }
    var cryptoAmountValue: String { return value(from: cryptoAmount) }
    var currencyAmountValue: String { return value(from: currencyAmount) }
    
    // get the most relevant image
    var image: String {
        if let avatar = avatar {
            return avatar
        } else if let teamLogo = teamLogo {
            return teamLogo
        }
        return ""
    }
    
    init(dict: [AnyHashable: Any]) {
        self.dict = dict
        let claim = RemotePayload.Claim(dict: dict)
        let teammate = RemotePayload.Teammate(dict: dict)
        let discussion = RemotePayload.Discussion(dict: dict)
        self.claim = claim
        self.teammate = teammate
        self.discussion = discussion
    }
    
    private func value(from: String?) -> String {
        return from ?? ""
    }
    
    private func value(from: Int?) -> Int {
        return from ?? 0
    }
    
    private func value(from: Int64?) -> Int64 {
        return from ?? 0
    }
}
