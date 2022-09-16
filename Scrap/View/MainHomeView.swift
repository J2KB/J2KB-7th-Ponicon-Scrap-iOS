//
//  MainHomeView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI

struct MainHomeView: View {
    var body: some View {
        VStack{
            //나열, 정렬 순서 버튼
            //자료 리스트 - dynamically list (ForEach)
            ScrollView(.vertical, showsIndicators: false){
                HStack{
                    Button(action: {
                        
                    }){
                        Image(systemName: "square.grid.2x2.fill")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.gray)
                    }
                    Text("최신순") //정렬 순서에 따라 달라짐 (최신순/오래된순)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Button(action: {
                        
                    }){
                        Image(systemName: "arrow.up.arrow.down")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.black)
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 32, height: 40, alignment: .trailing)
                ForEach(0...9, id: \.self) { page in
                    PageView()
                        .padding(4)
                }
            }
        }

    }
}

struct MainHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainHomeView()
    }
}
