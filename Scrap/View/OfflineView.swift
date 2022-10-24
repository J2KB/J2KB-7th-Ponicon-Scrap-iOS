//
//  OfflineView.swift
//  Scrap
//
//  Created by 김영선 on 2022/10/24.
//

import SwiftUI

struct OfflineView: View {
    var body: some View {
        VStack(spacing: 40){
            Text("we're not connected to the Internet🥲")
            Image(systemName: "xmark.circle")
                .resizable()
                .frame(width: 50, height: 50)
        }
    }
}

struct OfflineView_Previews: PreviewProvider {
    static var previews: some View {
        OfflineView()
    }
}
