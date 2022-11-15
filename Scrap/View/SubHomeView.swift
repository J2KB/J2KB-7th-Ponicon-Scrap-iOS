//
//  MainHomeView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI

struct SubHomeView: View {
    @State private var isOneCol = true;
    @State private var isRecent = true;
    @Binding var datas : DataResponse.Result
    @Binding var isPresentHalfModal : Bool
    @Binding var currentCategory : Int
    @Binding var currentCategoryOrder : Int
    @Environment(\.colorScheme) var scheme //Light/Dark mode

    var body: some View {
        VStack{
            ScrollView(.vertical, showsIndicators: false){
                HStack{
                    Button(action: {
                        if !isPresentHalfModal {
                            self.isOneCol.toggle()
                        }
                    }){
                        Image(systemName: isOneCol ? "square.grid.2x2.fill" : "line.3.horizontal")
                            .resizable()
                            .frame(width: 16, height: isOneCol ? 16 : 12)
                            .foregroundColor(.gray)
                    }
                    Text(isRecent ? "최신순" : "오래된 순") //정렬 순서에 따라 달라짐 (최신순/오래된순)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Button(action: {
                        if !isPresentHalfModal {
                            self.isRecent.toggle()
                        }
                    }){
                        Image(systemName: "arrow.up.arrow.down")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 32, height: 40, alignment: .trailing)
                LazyVGrid(columns: isOneCol ? [GridItem(.flexible())] : [GridItem(.adaptive(minimum: UIScreen.main.bounds.width / 2.5))], spacing: 10){
                    if isRecent {
                        ForEach($datas.links.reversed()) { data in
                            PageView(data: data, isOneCol: $isOneCol, isPresentHalfModal: $isPresentHalfModal, currentCategory: $currentCategory, currentCatOrder: $currentCategoryOrder)
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                        }
                    }else {
                        ForEach($datas.links) { data in
                            PageView(data: data, isOneCol: $isOneCol, isPresentHalfModal: $isPresentHalfModal, currentCategory: $currentCategory, currentCatOrder: $currentCategoryOrder)
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                        }
                    }
                } //LAZYGRID
                .padding(.horizontal, isOneCol ? 0 : 8)
            }//ScrollView
        }//VStack
        .background(scheme == .light ? .white : .black_bg)
        .onAppear{
            UITableView.appearance().backgroundColor = .clear
        }
    }//body
}

struct SubHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainHomeView()
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
            .preferredColorScheme(.dark)
    }
}
