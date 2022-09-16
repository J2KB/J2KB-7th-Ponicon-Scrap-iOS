//
//  SideOptionView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI

struct CategoryRowView: View {
    @Binding var text : String
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.885))
                .frame(width: UIScreen.main.bounds.width/1.2, height: UIScreen.main.bounds.height / 14, alignment: .center)
            HStack{
                Text("\(text)") //카테고리 이름
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Text("13")      //자료 개수 - count
                    .font(.system(size: 16, weight: .medium))
            }
            .frame(width: UIScreen.main.bounds.width/1.35, height: UIScreen.main.bounds.height / 14)
        }
//        HStack{
//            Text("카테고리 1") //카테고리 이름
//                .font(.system(size: 16, weight: .medium))
//            Spacer()
//            Text("13")      //자료 개수 - count
//                .font(.system(size: 16, weight: .medium))
////            Image(systemName: "ellipsis")
//        }
    }
}

struct SideOptionView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryRowView(text: .constant("모든 자료"))
    }
}
