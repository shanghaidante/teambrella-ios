//
//  ChatEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 17.07.17.

/* Copyright(C) 2017  Teambrella, Inc.
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

struct ChatEntity: Decodable {
    let userID: String
    let lastUpdated: Int64
    let id: String
    let points: Int
    let text: String
    let images: [String]
    let smallImages: [String]
    let imageRatios: [CGFloat]
    let teammate: TeammatePart

    private let dateCreated: UInt64

    var created: Date { return Date(ticks: dateCreated) }

    enum CodingKeys: String, CodingKey {
        case userID = "UserId"
        case lastUpdated = "LastUpdated"
        case id = "Id"
        case points = "Points"
        case text = "Text"
        case images = "Images"
        case smallImages = "SmallImages"
        case imageRatios = "ImageRatios"
        case teammate = "TeammatePart"
        case dateCreated = "Created"
    }

    struct TeammatePart: Decodable {
        let isMyProxy: Bool
        let name: Name
        let avatar: Avatar
        let vote: Double?

        enum CodingKeys: String, CodingKey {
            case isMyProxy = "IsMyProxy"
            case name = "Name"
            case avatar = "Avatar"
            case vote = "Vote"
        }
        
    }

}
