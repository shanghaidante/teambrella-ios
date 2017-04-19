//
//  KeychainSignature.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import CoreData

class KeychainSignature: NSManagedObject {
    var teammateID: Int { return Int(teammateIDValue) }
    var id: String { return idValue! }
    var inputID: String { return inputIDValue! }
    var isServerUpdateNeeded: Bool { return isServerUpdateNeededValue }
    var signature: Data { return signatureValue! as Data }
}
