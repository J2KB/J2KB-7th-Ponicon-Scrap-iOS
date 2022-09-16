//
//  HomeView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//


//로그인이 된 상태라면, 앱의 처음 시작은 HomeView
//사용자가 저장한 자료를 보거나 수정, 삭제할 수 있는 공간

import SwiftUI

struct HomeView: View {
    @State private var isShowing = false
    @State private var isShowingMyPage = false
    @State private var isAddingCategory = false
    @Binding var rootView : Bool
    
    var body: some View {
        NavigationView{
            ZStack(alignment: .leading){
                MainHomeView()
                    .padding(.horizontal)
                HStack{
                    SideMenuView(isAddingCategory: $isAddingCategory)
                        .offset(x: isShowing ? 0 : -UIScreen.main.bounds.width-50)
                    Spacer(minLength: 0)
                }
//                    .navigationTitle("카테고리 이름")
                .navigationBarTitle("", displayMode: .inline)
                .toolbar{
                        ToolbarItem(placement: .navigationBarLeading){
                            HStack(spacing: 2){
                                Button(action: {
                                    withAnimation(.spring()){
                                        isShowing.toggle()
                                    }
                                }) {
                                    Image(systemName: isShowing ? "chevron.backward" :
                                            "line.3.horizontal")
                                        .resizable()
                                        .frame(width: isShowing ? 12 : 20, height: isShowing ? 16 : 14)
                                        .foregroundColor(.black)
                                }
                                Text("카테고리 이름")
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .toolbar{
                        ToolbarItem(placement: .navigationBarTrailing){
                            if !isShowing {
                                VStack{
                                    NavigationLink(destination: MyPageView(rootView: $rootView), isActive: $isShowingMyPage) {
                                        Button(action: {
                                            self.isShowingMyPage.toggle()
                                        }) {
                                            Image(systemName: "person.circle")
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
                            }else {
                                HStack{
                                    Button(action: {}){
                                        Image(systemName: "pencil")
                                            .resizable()
                                            .foregroundColor(.black)
                                            .frame(width: 18, height: 18)
                                    }
                                    Button(action: {
                                        self.isAddingCategory.toggle()
                                        if isAddingCategory { //checkmark인 경우
                                            //새로운 카테고리 생성 & 저장
                                        }
                                    }){
                                        Image(systemName: isAddingCategory ? "checkmark" : "plus")
                                            .resizable()
                                            .foregroundColor(.black)
                                            .frame(width: 18, height: 18)
                                    }
                                }
                            }
                        }
                    }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(rootView: .constant(true))
//        LoginView()
    }
}
