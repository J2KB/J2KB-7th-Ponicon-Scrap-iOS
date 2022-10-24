//
//  Network.swift
//  Scrap
//
//  Created by 김영선 on 2022/10/24.
//

import Foundation
import Network

class Network : ObservableObject{
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor") //monitor를 실행시킨다
        @Published private(set) var connected: Bool = false //네트워크 연결 상태 변수
        func checkConnection(){
            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                        self.connected = true
                } else {
                        self.connected = false
                }
            }
            monitor.start(queue: queue)
        }
}

