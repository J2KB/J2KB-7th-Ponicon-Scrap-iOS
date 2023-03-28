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
    
    @State private var isShowingCategorySideMenuView = false //카테고리사이드뷰 onoff
    @State private var isPresentDataBottomSheet = false
    @State private var selectedCategoryID = 0
    @State private var selectedCategoryOrder = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                HomeView(isPresentingDataBottomSheet: $isPresentDataBottomSheet, isShowingCategorySideMenuView: $isShowingCategorySideMenuView, selectedCategoryID: $selectedCategoryID, selectedCategoryOrder: $selectedCategoryOrder)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                CategoryView(categoryList: $scrapVM.categoryList.result, isShowingCategorySideMenuView: $isShowingCategorySideMenuView,  selectedCategoryId: $selectedCategoryID, selectedCategoryOrder: $selectedCategoryOrder)
                    .frame(width: geometry.size.width)
                    .offset(x: isShowingCategorySideMenuView ? 0 : -geometry.size.width)
            }
        }

        //카테고리뷰 -> isShowingCategorySideMenuView
//        .gesture(DragGesture().onEnded({
//            if !isPresentDataBottomSheet { //바텀시트들이 열려있지 않을 때 사용 가능
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
