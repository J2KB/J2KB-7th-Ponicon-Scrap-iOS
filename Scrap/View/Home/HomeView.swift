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
    @Binding var isShowingMypage : Bool //마이페이지 onoff
    @Binding var isShowingFavoriteView : Bool //즐겨찾기view onoff
    
    @Binding var isPresentingDataBottomSheet : Bool //데이터바텀시트 onoff
    @Binding var isShowingCategorySideMenuView: Bool //카테고리 뷰 onoff 변수
    
    @Binding var selectedCategoryID: Int
    @Binding var selectedCategoryOrder: Int

    private let screenHeight = UIScreen.main.bounds.height
    private let screenWidth = UIScreen.main.bounds.width
    
    var categoryTitle : String { return "\(scrapVM.categoryList.result.categories[scrapVM.categoryList.result.categories.firstIndex(where: {$0.categoryId == selectedCategoryID}) ?? 0].name)"}
    
    var body: some View {
        NavigationView {
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
                        .frame(width: 52, height: 40)
                        .padding(.trailing, -10)
                    }
                    Text(categoryTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("basic_text"))
                        .frame(width: screenWidth / 1.6, alignment: .leading)
                        .padding(.trailing)
                    NavigationLink(destination: FavoritesView(isShowingFavoriteView: $isShowingFavoriteView).navigationBarHidden(true).navigationBarBackButtonHidden(true), isActive: $isShowingFavoriteView) {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                if !isPresentingDataBottomSheet { //modal sheet가 열려있으면 마이페이지뷰를 열 수 없다
                                    self.isShowingFavoriteView.toggle()
                                }
                            }
                        }) {
                            ZStack {
                                Image(systemName: "bookmark.fill")
                                    .resizable()
                                    .frame(width: 16, height: 20)
                                    .foregroundColor(Color("main_accent"))
                            }
                            .frame(width: 40, height: 40)
                        }
                    }
                    .padding(.trailing, -7)
                    NavigationLink(destination: MyPageView(userData: $scrapVM.user, isShowingMyPage: $isShowingMypage).navigationBarBackButtonHidden(true), isActive: $isShowingMypage) {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                if !isPresentingDataBottomSheet { //modal sheet가 열려있으면 마이페이지뷰를 열 수 없다
                                    self.isShowingMypage.toggle()
                                }
                            }
                        }) {
                            ZStack {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color("basic_text"))
                            }
                            .frame(width: 40, height: 40)
                        }
                        .padding(.leading, -7)
                    }
                }
                .frame(width: screenWidth, height: 50)
                SubHomeView(detailData: $detailData, isShowMovingCategory: $isShowMovingCategory, datas: $scrapVM.dataList, isPresentDataBottomSheet: $isPresentingDataBottomSheet, currentCategoryId: $selectedCategoryID, currentCategoryOrder: $selectedCategoryOrder)
                    .navigationBarTitle("", displayMode: .inline)
            }
        }
        if isPresentingDataBottomSheet {
            Color(.black)
                .opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresentingDataBottomSheet = false
                }
        }
    }
}
