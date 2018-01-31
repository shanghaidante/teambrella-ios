//
/* Copyright(C) 2018 Teambrella, Inc.
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

class Dumper {
    var api: BlockchainServer

    var applicationSupportURL: URL {
        let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        var dbURL = urls[urls.count - 1]
        dbURL = dbURL.appendingPathComponent("Application Support/")
        return dbURL
    }

    var dbURL: URL {
        return applicationSupportURL.appendingPathComponent("TransactionsModel").appendingPathExtension("sqlite")
    }

    init(api: BlockchainServer) {
        self.api = api
    }

    func printContents() {
        let url = applicationSupportURL
        log("Path: \(url.path)", type: .cryptoDetails)
        do {
            let content = try FileManager.default.contentsOfDirectory(atPath: url.path)
            for item in content {
                log(item, type: .cryptoDetails)
            }
        } catch {
            log("Dumper error printing: \(error)", type: [.error, .cryptoDetails])
        }
    }

    func sendDatabaseDump(privateKey: String) {
        let url = dbURL
        printContents()
        log("Trying to send dump", type: .crypto)
        do {
            let file = try Data(contentsOf: url)
            print("Bytes: \(file.count)")
            api.postData(to: "me/debugDB",
                         data: file,
                         privateKey: privateKey,
                         success: { json in
                            print("Dump sent successfully: \(json)")
            }, failure: { error in
                log("Dump not sent with error: \(String(describing: error))", type: [.error, .crypto])
            })
        } catch {
            log("Error reading database file: \(error)", type: [.error, .cryptoDetails])
        }
    }

}