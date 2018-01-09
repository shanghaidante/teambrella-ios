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

struct ServerReply {
    enum CodingKeys: String {
        case status = "Status"
        case paging = "Meta"
        case data = "Data"
    }
    
    let status: ServerStatus
    let paging: PagingInfo?
    let json: Any
    
    // swiftlint:disable:next force_try
    var data: Data { return try! JSONSerialization.data(withJSONObject: json, options: []) }
    
    init(status: ServerStatus, paging: PagingInfo?, json: Any) {
        self.status = status
        self.paging = paging
        self.json = json
    }
    
    init(data: Data) throws {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any] else {
            throw TeambrellaErrorFactory.wrongReply()
        }
        guard let statusJSON = json[CodingKeys.status.rawValue] else {
            throw TeambrellaErrorFactory.emptyReplyError()
        }
        guard let dataJSON = json[CodingKeys.data.rawValue] else {
            throw TeambrellaErrorFactory.emptyReplyError()
        }
        
        let decoder = JSONDecoder()
        let statusData = try JSONSerialization.data(withJSONObject: statusJSON, options: [])
   
        print("JSON: \(json)")
        if let pagingJSON = json[CodingKeys.paging.rawValue] {
            let pagingData = try JSONSerialization.data(withJSONObject: pagingJSON, options: [])
            paging = try decoder.decode(PagingInfo.self, from: pagingData)
        } else {
            paging = nil
        }
        status = try decoder.decode(ServerStatus.self, from: statusData)
        self.json = dataJSON
    }
    
}