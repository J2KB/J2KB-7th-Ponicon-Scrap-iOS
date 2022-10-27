//
//  HomeView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//

//로그인이 된 상태라면, 앱의 처음 시작은 HomeView
//사용자가 저장한 자료를 보거나 수정, 삭제할 수 있는 공간

import SwiftUI

struct MainHomeView: View {
    @EnvironmentObject var scrapVM : ScrapViewModel //ScrapApp에서 연결받은 EnvironmentObject
    @EnvironmentObject var userVM : UserViewModel //ScrapApp에서 연결받은 EnvironmentObject
    @State private var isShowingCategory = false
    @State private var isShowingMyPage = false
    @Binding var popRootView : Bool
//    @Binding var autoLogin : Bool
    @State private var selected = UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "lastCategory") ?? 0 //last category id 가져오기
    var categoryTitle : String {
        print(self.selected)
        return "\(scrapVM.categoryList.result.categories[scrapVM.categoryList.result.categories.firstIndex(where: {$0.categoryId == selected}) ?? 0].name)"
    }
    
    var body: some View {
        ZStack(){
            //Main Home
            NavigationView{
                SubHomeView(datas: $scrapVM.dataList.result) //⭐️여기로 category 데이터 넘겨줘야 됨
                .navigationBarTitle("", displayMode: .inline)
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading){
                        HStack(spacing: 2){
                            Button(action: {
                                withAnimation(.easeInOut){
                                    self.isShowingCategory = true
                                }
                            }) {
                                Image(systemName: "line.3.horizontal")
                                    .resizable()
                                    .frame(width: 20, height: 14)
                                    .foregroundColor(.black)
                            }
                            Text(categoryTitle)
                                .fontWeight(.bold)
                        }
                    }
                }
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing){
                        VStack{
                            NavigationLink(destination: MyPageView(userData: $scrapVM.user.result, popRootView: $popRootView), isActive: $isShowingMyPage) {
                                Button(action: {
                                    self.isShowingMyPage.toggle()
                                    scrapVM.getMyPageData(userID: userVM.userIdx)
                                }) {
                                    Image(systemName: "person.circle")
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            if isShowingCategory {
                Rectangle()
                    .background(.black)
                    .opacity(0.4)
                    .ignoresSafeArea()
            }
            //Drawer
            SideMenuView(categoryList: $scrapVM.categoryList.result, isShowingCateogry: $isShowingCategory, selected: $selected)
                .offset(x: isShowingCategory ? -(UIScreen.main.bounds.width / 6) : -UIScreen.main.bounds.width)
        }
        .frame(width: UIScreen.main.bounds.width)
        .onAppear{ //MainHomeView 등장하면 api 통신
//            print("현재 UserDefaults id 값은? : \(UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID"))")
            userVM.userIdx = UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") == Optional(0) ? userVM.userIdx : UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") as! Int
            print("user idx: \(userVM.userIdx)")
            scrapVM.getCategoryData(userID: userVM.userIdx)
            if self.selected == 0 {
                scrapVM.getAllData(userID: userVM.userIdx)
            } else {
                scrapVM.getData(userID: userVM.userIdx, catID: selected, seq: "seq")
            }
        }
        .gesture(DragGesture().onEnded({
            if $0.translation.width < -100 {
                withAnimation(.easeInOut) {
                    self.isShowingCategory = false
                }
            }else if $0.translation.width > 100 {
                withAnimation(.easeInOut) {
                    self.isShowingCategory = true
                }
            }
        }))
    }
}

struct MainHomeView_Previews: PreviewProvider { 
    static var previews: some View {
        MainHomeView(popRootView: .constant(true))
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
    }
}
