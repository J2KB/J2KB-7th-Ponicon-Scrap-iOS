//
//  HomeView.swift
//  Scrap
//
//  Created by 김영선 on 2023/02/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var scrapVM : ScrapViewModel
    @EnvironmentObject var userVM : UserViewModel
    
    @State private var isShowMovingCategory = false //자료의 카테고리 이동뷰 onoff
    @State private var detailData = DataResponse.Datas(linkId: 0, link: "", title: "", domain: "", imgUrl: "", bookmark: false)
    
    @Binding var isPresentingDataBottomSheet : Bool //데이터바텀시트 onoff
    @Binding var isShowingCategorySideMenuView: Bool //카테고리 뷰 onoff 변수
    
    @Binding var selectedCategoryID: Int
    @Binding var selectedCategoryOrder: Int

    private let screenHeight = UIScreen.main.bounds.height
    private let screenWidth = UIScreen.main.bounds.width
    
    var categoryTitle : String { return "\(scrapVM.categoryList.result.categories[scrapVM.categoryList.result.categories.firstIndex(where: {$0.categoryId == selectedCategoryID}) ?? 0].name)"}
    
    var body: some View {
        VStack {
            //Header
            HStack {
                Button(action: {
                    withAnimation(.easeInOut) {
                        if !isPresentingDataBottomSheet {
                            isShowingCategorySideMenuView = true //카테고리뷰 on
                            scrapVM.getCategoryListData(userID: userVM.userIndex)
                        }
                    }
                }) {
                    ZStack {
                        Image(systemName: "line.3.horizontal")
                            .resizable()
                            .frame(width: 22, height: 16)
                            .foregroundColor(Color("basic_text"))
                    }
                    .frame(width: 55, height: 40)
                    .padding(.trailing, -10)
                }
                Text(categoryTitle)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("basic_text"))
                    .frame(width: screenWidth / 1.22, alignment: .leading)
                    .padding(.trailing)
                Spacer()
                    .frame(width: 5)
            }
            .frame(width: screenWidth, height: 40)
            SubHomeView(detailData: $detailData, isShowMovingCategory: $isShowMovingCategory, datas: $scrapVM.dataList, isPresentDataBottomSheet: $isPresentingDataBottomSheet, currentCategoryId: $selectedCategoryID, currentCategoryOrder: $selectedCategoryOrder)
                .navigationBarTitle("", displayMode: .inline)
        }
        if isPresentingDataBottomSheet {
            Color(.black)
                .opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresentingDataBottomSheet = false
                }
        }
//        .sheet(isPresented: $isPresentingDataBottomSheet){
//             HalfSheet {
//                 DataSheetView(isShowMovingCategoryView: $isShowMovingCategory, data: $detailData, isPresentDataModalSheet: $isPresentingDataBottomSheet, currentCategoryOrder: $selectedCategoryOrder, currentCategoryId: $selectedCategoryID)
//             }
//             .ignoresSafeArea()
//         }
//        .bottomSheet(showSheet: $isPresentingDataBottomSheet) { //데이터바텀시트 on -ing
//            DataSheetView(isShowMovingCategoryView: $isShowMovingCategory, data: $detailData, isPresentDataModalSheet: $isPresentingDataBottomSheet, currentCategoryOrder: $selectedCategoryOrder, currentCategoryId: $selectedCategoryID)
//                .environmentObject(scrapVM)
//                .environmentObject(userVM)
//        } onEnd: {
//            print("✅ data bottom sheet dismissed")
////            isPresentingDataBottomSheet = false //데이터바텀시트 off
//        }
    }
}
