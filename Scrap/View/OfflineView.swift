//
//  OfflineView.swift
//  Scrap
//
//  Created by 김영선 on 2022/10/24.
//

import SwiftUI

struct OfflineView: View {
    var body: some View {
        VStack(){
            Text("네트워크에 연결되어 있지 않습니다.")
                .font(.system(size: 24, weight: .medium))
                .padding(.bottom, 2)
            Text("네트워크 연결 후 다시 시도해주세요.")
                .font(.system(size: 16, weight: .regular))
                .padding(.bottom, 8)
            Image(systemName: "xmark.circle")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.red)
        }
    }
}

struct OfflineView_Previews: PreviewProvider {
    static var previews: some View {
        OfflineView()
    }
}
