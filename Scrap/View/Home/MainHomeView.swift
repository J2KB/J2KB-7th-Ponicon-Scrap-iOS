//
//  MainHomeView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//

import SwiftUI

struct MainHomeView: View {
    @EnvironmentObject var scrapVM : ScrapViewModel
    @EnvironmentObject var userVM : UserViewModel
    @State private var isShowingCategorySideMenuView = false
//    @State private var isPresentDataModalSheet = false
    @State private var selectedCategoryID = 0
    @State private var selectedCategoryOrder = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                HomeView(selectedCategoryID: $selectedCategoryID, selectedCategoryOrder: $selectedCategoryOrder, isShowingCategorySideMenuView: $isShowingCategorySideMenuView)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                CategoryView(categoryList: $scrapVM.categoryList.result, isShowingCategoryView: $isShowingCategorySideMenuView, selectedCategoryId: $selectedCategoryID, selectedCategoryOrder: $selectedCategoryOrder)
                    .frame(width: geometry.size.width)
                    .offset(x: isShowingCategorySideMenuView ? 0 : -geometry.size.width)
            }
        }
//        .gesture(DragGesture().onEnded({
//            if !isPresentDataModalSheet {
//                if $0.translation.width < -100 {
//                    withAnimation(.easeInOut) {
//                        self.isShowingCategorySideMenuView = false
//                    }
//                }
//               else if $0.translation.width > 100 {
//                    withAnimation(.easeInOut) {
//                        self.isShowingCategorySideMenuView = true
//                        scrapVM.getCategoryListData(userID: userVM.userIndex)
//                    }
//                }
//            }
//         }))
    }
}

struct MainHomeView_Previews: PreviewProvider { 
    static var previews: some View {
        MainHomeView()
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
    }
}
