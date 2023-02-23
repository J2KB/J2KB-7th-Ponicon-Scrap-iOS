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
    @State private var isPresentDataModalSheet = false
    @State private var selectedCategoryID = 0
    @State private var selectedCategoryOrder = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                HomeView(selectedCategoryID: $selectedCategoryID, selectedCategoryOrder: $selectedCategoryOrder, isShowingCategorySideMenuView: $isShowingCategorySideMenuView)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                CategoryView(categoryList: $scrapVM.categoryList.result, isShowingCategoryView: $isShowingCategorySideMenuView, selectedCategoryId: $selectedCategoryID, selectedCategoryOrder: $selectedCategoryOrder)
                    .frame(width: geometry.size.width)
//                        .transition(.move(edge: .leading))
                    .offset(x: isShowingCategorySideMenuView ? 0 : -geometry.size.width)
            }
        }
//        ZStack{
            //Main Home
//            HomeView()
//            NavigationView{
//                SubHomeView(datas: $scrapVM.dataList, isPresentDataModalSheet: $isPresentDataModalSheet, currentCategoryId: $selectedCategoryID, currentCategoryOrder: $selectedCategoryOrder)
//                    .navigationBarTitle("", displayMode: .inline)
//                    .toolbar{
//                        ToolbarItem(placement: .navigationBarLeading){
//                            HStack{
//                                Button(action: {
//                                    withAnimation(.spring()){
//                                        self.isShowingCategorySideMenuView = true
//                                        scrapVM.getCategoryListData(userID: userVM.userIndex)
//                                    }
//                                }) {
//                                    ZStack {
//                                        Image(systemName: "line.3.horizontal")
//                                            .resizable()
//                                            .frame(width: 22, height: 16)
//                                            .foregroundColor(Color("basic_text"))
//                                    }
//                                    .frame(width: 42, height: 40)
////                                    .background(.blue)
//                                }
//                                .padding(.trailing, -16)
////                                Text(categoryTitle)
//                                Text("카테고리 이름 입니다! 크기 18도 괜찮군요")
//                                    .font(.system(size: 18, weight: .semibold))
//                                    .foregroundColor(Color("basic_text"))
//                                    .frame(width: screenWidth / 1.27, alignment: .leading)
////                                    .background(.red)
//                                    .padding(.trailing)
//                                Spacer()
//                                    .frame(width: 10)
//                            }
//                            .frame(width: screenWidth)
//                            .background(.yellow)
//                        }
//                    }
//            }
            //Drawer
//            CategoryView(categoryList: $scrapVM.categoryList.result, isShowingCategoryView: $isShowingCategorySideMenuView, selectedCategoryId: $selectedCategoryID, selectedCategoryOrder: $selectedCategoryOrder)
//                .offset(x: isShowingCategorySideMenuView ? 0 : -UIScreen.main.bounds.width)
//            if isPresentDataModalSheet {
//                Color(.black)
//                    .opacity(0.2)
//                    .ignoresSafeArea()
//                    .onTapGesture {
//                        isPresentDataModalSheet = false
//                    }
//            }
//        }
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
