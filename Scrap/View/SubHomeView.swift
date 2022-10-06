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
                                let url = URL(string: urlString.wrappedValue)
                                if let Url = url {
                                    Link(destination: Url, label:{
                                        PageView(data: data, isOneCol: $isOneCol)
                                            .padding(2)
                                    })
                                    .foregroundColor(.black)
                                }
                            }
                        }
                    }else {
                        ForEach($datas.links) { data in
                            if let urlString = data.link {
                                let url = URL(string: urlString.wrappedValue)
                                if let Url = url {
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
                .padding(.horizontal, isOneCol ? 0 : 8)
            }
        }
    }
}

struct SubHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainHomeView(popRootView: .constant(true), autoLogin: .constant(true))
    }
}
