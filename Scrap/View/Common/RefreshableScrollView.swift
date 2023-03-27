//
//  RefreshableScrollView.swift
//  Scrap
//
//  Created by 김영선 on 2023/03/27.
//

import SwiftUI

struct RefreshableScrollView<Content: View> : View {
    var content : Content
    var refreshable: () -> Void
    
    init(content: @escaping () -> Content, refreshable: @escaping () -> Void) {
        self.content = content()
        self.refreshable = refreshable
    }
    
    var body: some View {
        List {
            content
                .listRowSeparatorTint(.clear)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.plain)
        .refreshable {
            refreshable()
        }
    }
}
