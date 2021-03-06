//  InitialVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.05.17.

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

import PKHUD
import UIKit

final class InitialVC: UIViewController {
    enum InitialVCMode {
        case idle
        case login
        case demoExpired
    }
    
    var mode: InitialVCMode = .login
    weak var sod: SODVC?
    var isFirstLoad: Bool = true

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        /*
         When application wakes up by PushKit after been killed or by BackgroundFetch
         it runs viewDidAppear in background.
         if we start loading teams in that mode our server won't distinguish background fetch from UI activity
         that's why we use the following hack
                                            ||
                                            \/
         */
        let state = UIApplication.shared.applicationState
        print("Application state is: \(state.rawValue)")
        guard state != .background else {
            print("Running in background")
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(performTransitionsAfterWakeUp),
                                                   name: .UIApplicationDidBecomeActive,
                                                   object: nil)
            return
        }

        performTransitions()
    }

    @objc
    func performTransitionsAfterWakeUp() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIApplicationDidBecomeActive,
                                                  object: nil)
        performTransitions()
    }

    func performTransitions() {
        if isFirstLoad, service.keyStorage.isUserSelected {
            mode = .idle
            startLoadingTeams()
        } else {
            switch mode {
            case .login:
                performSegue(type: .login)
            case .demoExpired:
                let router = service.router
                if let vc = SODManager(router: router).showOutdatedDemo(in: self) {
                    vc.upperButton.addTarget(self, action: #selector(tapDemo), for: .touchUpInside)
                    vc.lowerButton.addTarget(self, action: #selector(tapBack), for: .touchUpInside)
                    sod = vc
                }
            default:
                break
            }

            mode = .idle
        }
        isFirstLoad = false
    }
    
    // MARK: Callbacks
    
    @IBAction func unwindToInitial(segue: UIStoryboardSegue) {
        mode = .idle
        startLoadingTeams()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        HUD.hide()
        if segue.type == .teambrella {

        }
    }
    
    @objc
    private func tapDemo() {
        service.keyStorage.setToDemoUser()
        self.startLoadingTeams()
        sod?.dismiss(animated: true) {
            
        }
    }
    
    @objc
    private func tapBack() {
        sod?.dismiss(animated: true) {
            self.performSegue(type: .login)
        }
    }
    
    // MARK: Private
    
    private func getTeams() {
        let isDemo = service.keyStorage.isDemoUser
        service.dao.requestTeams(demo: isDemo).observe { [weak self] result in
            switch result {
            case let .value(teamsEntity):
                self?.startSession(teamsEntity: teamsEntity, isDemo: isDemo)
            case let .error(error):
                self?.failure(error: error)
            }
        }
    }
    
    private func startSession(teamsEntity: TeamsModel, isDemo: Bool) {
        service.session = Session(isDemo: isDemo)
        service.teambrella.startUpdating(completion: { result in
            let description = result.rawValue == 0 ? "new data" : result.rawValue == 1 ? "no data" : "failed"
            log("Teambrella service get updates results: \(description)", type: .info)
        })
        
        /*
         Selecting team that was used last time
         
         Firstly we try to use teamID that comes from server (but it is not implemented yet)
         Secondly we use a stored on device last used teamID
         and lastly if everything fails we take the first team from the list
         */
        let lastTeamID: Int
        if let receivedID = teamsEntity.lastTeamID {
            lastTeamID = receivedID
        } else if let storedID = SimpleStorage().int(forKey: .teamID) {
            lastTeamID = storedID
        } else {
            lastTeamID = teamsEntity.teams.first?.teamID ?? 0
        }
        var currentTeam: TeamEntity?
        for team in teamsEntity.teams where team.teamID == lastTeamID {
            currentTeam = team
            break
        }
        service.session?.currentTeam = currentTeam ?? teamsEntity.teams.first
        
        service.session?.teams = teamsEntity.teams
        service.session?.currentUserID = teamsEntity.userID
        let socket = SocketService(dao: service.dao, url: nil)
        service.socket = socket
        service.teambrella.signToSockets(service: socket)
        SimpleStorage().store(bool: true, forKey: .didLogWithKey)
        HUD.hide()
        presentMasterTab()
        requestPush()
    }
    
    private func failure(error: Error) {
        print("InitialVC got error: \(error)")
        HUD.hide()
        service.router.logout()
        SimpleStorage().store(bool: false, forKey: .didLogWithKey)
        performSegue(type: .login)
    }

    private func startLoadingTeams() {
        HUD.show(.progress)
        getTeams()
    }
    
    private func presentMasterTab() {
        performSegue(type: .teambrella)
        if service.dao.recentScene == .feed {
            service.router.switchToFeed()
        } else {
            // present default .home screen
        }
    }
    
    private func requestPush() {
        let application = UIApplication.shared
        service.push.askPermissionsForRemoteNotifications(application: application)
    }
    
}
