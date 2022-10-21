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
    @State private var isPresentHalfModal = false
    @Binding var datas : DataResponse.Result
    
    var body: some View {
        VStack{
            //나열, 정렬 순서 버튼
            //자료 리스트 - dynamically list (ForEach)
            ScrollView(.vertical, showsIndicators: false){
                HStack{
                    Button(action: { self.isOneCol.toggle() }){
                        Image(systemName: isOneCol ? "square.grid.2x2.fill" : "line.3.horizontal")
                            .resizable()
                            .frame(width: 16, height: isOneCol ? 16 : 12)
                            .foregroundColor(.gray)
                    }
                    Text(isRecent ? "최신순" : "오래된 순") //정렬 순서에 따라 달라짐 (최신순/오래된순)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Button(action: { self.isRecent.toggle() }){
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
                            if let urlString = data.link {
                                let url = URL(string: urlString.wrappedValue!) //if-let으로 옵셔널 바인딩
                                if let Url = url {
                                    ZStack{
                                        Button(action: {
                                            //half-modal view 등장해야됨
                                            self.isPresentHalfModal = true
                                        }){
                                            Image(systemName: "ellipsis")
                                                .rotationEffect(.degrees(90))
                                                .foregroundColor(.black_bold)
                                        }
                                        .padding(EdgeInsets(top: 90, leading: 315, bottom: 0, trailing: 0))
                                        Link(destination: Url, label:{
                                            PageView(data: data, isOneCol: $isOneCol)
                                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                                        })
                                        .foregroundColor(.black)
                                    }
                                }
                            }
                        }
                    }else {
                        ForEach($datas.links) { data in
                            if let urlString = data.link {
                                let url = URL(string: urlString.wrappedValue!)
                                if let Url = url {
                                    ZStack{
                                        Button(action: {
                                            //half-modal view 등장해야됨
                                            self.isPresentHalfModal = true
                                        }){
                                            Image(systemName: "ellipsis")
                                                .rotationEffect(.degrees(90))
                                                .foregroundColor(.black_bold)
                                        }
                                        .padding(EdgeInsets(top: 90, leading: 315, bottom: 0, trailing: 0))
                                        Link(destination: Url, label:{
                                            PageView(data: data, isOneCol: $isOneCol)
                                                .padding(2)
                                        })
                                        .foregroundColor(.black)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, isOneCol ? 0 : 8)
            }
        }
        .onAppear{
            UITableView.appearance().backgroundColor = .clear
        }
        .sheet(isPresented: $isPresentHalfModal){
            HalfSheet {
                VStack(spacing: -2){
                    Text("Half_Modal View 만들어보기")
                        .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                    List {
                        Section {
                            Label("링크 복사", systemImage: "doc.on.doc")
                                .foregroundColor(.black)
                                .onTapGesture {

                                }
                        }
                        Section {
                            Label("카테고리 이동", systemImage: "arrow.turn.down.right")
                                .foregroundColor(.black)
                                .onTapGesture {
                                    
                                }
                            Label("삭제", systemImage: "trash")
                                .foregroundColor(.red)
                                .onTapGesture {
                                    
                                }
                        }
                    }
                    .background(Color("background"))
                }
                .padding(.top, 48)
                .background(Color("background"))
            }
            .ignoresSafeArea()
        }
    }
}

struct SubHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainHomeView(popRootView: .constant(true))
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
    }
}
