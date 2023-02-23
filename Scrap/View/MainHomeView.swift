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
    
    var categoryTitle : String { return "\(scrapVM.categoryList.result.categories[scrapVM.categoryList.result.categories.firstIndex(where: {$0.categoryId == selectedCategoryID}) ?? 0].name)"}
    
    var body: some View {
        ZStack{
            //Main Home
            NavigationView{
                SubHomeView(datas: $scrapVM.dataList, isPresentDataModalSheet: $isPresentDataModalSheet, currentCategoryId: $selectedCategoryID, currentCategoryOrder: $selectedCategoryOrder)
                    .navigationBarTitle("", displayMode: .inline)
                    .toolbar{
                        ToolbarItem(placement: .navigationBarLeading){
                            HStack(spacing: -4){
                                Button(action: {
                                    withAnimation(.spring()){
                                        self.isShowingCategorySideMenuView = true
                                        scrapVM.getCategoryListData(userID: userVM.userIndex)
                                    }
                                }) {
                                    ZStack {
                                        Image(systemName: "line.3.horizontal")
                                            .resizable()
                                            .frame(width: 22, height: 16)
                                            .foregroundColor(Color("basic_text"))
                                    }
                                    .frame(width: 36, height: 30)
                                }
                                Text(categoryTitle)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color("basic_text"))
                                    .frame(width: UIScreen.main.bounds.width / 1.3, alignment: .leading)
                            }
                        }
                    }
            }
            //Drawer
            SideMenuView(categoryList: $scrapVM.categoryList.result, isShowingCategoryView: $isShowingCategorySideMenuView, selectedCategoryId: $selectedCategoryID, selectedCategoryOrder: $selectedCategoryOrder)
                .offset(x: isShowingCategorySideMenuView ? 0 : -UIScreen.main.bounds.width)
            if isPresentDataModalSheet {
                Color(.black)
                    .opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresentDataModalSheet = false
                    }
            }
        }
        .gesture(DragGesture().onEnded({
            if !isPresentDataModalSheet {
                if $0.translation.width < -100 {
                    withAnimation(.easeInOut) {
                        self.isShowingCategorySideMenuView = false
                    }
                }
               else if $0.translation.width > 100 {
                    withAnimation(.easeInOut) {
                        self.isShowingCategorySideMenuView = true
                        scrapVM.getCategoryListData(userID: userVM.userIndex)
                    }
                }
            }
         }))
    }
}

struct MainHomeView_Previews: PreviewProvider { 
    static var previews: some View {
        MainHomeView()
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
    }
}
