//
//  PageView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI

struct PageView: View {
    @State private var height = 200
    @State var selection: Int = -1
    @State private var menu = ["삭제", "카테고리 이동", "이름 변경"]
    
    var body: some View {
        VStack(spacing: 0){
            //imageUrl == nil
            //light_color
            //imageUrl != nil
            Image("sample")
                .resizable()
                .frame(width: UIScreen.main
                        .bounds.width - 24, height: 130)
                .cornerRadius(10, corners: .topLeft)
                .cornerRadius(10, corners: .topRight)
                .shadow(radius: 2)
            ZStack{
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width - 23, height: 88)
                    .foregroundColor(.white)
                    .cornerRadius(10, corners: .bottomLeft)
                    .cornerRadius(10, corners: .bottomRight)
                    .opacity(1)
                    .shadow(radius: 2)
                VStack(spacing: 12){
                    HStack(spacing: -2){
                        Text("인텔리제이 디버깅 해보기 여기도 마찬가지로 칸을 넘어가는 제목같은 경우는 점으로 표시합니다. 글자수 채우기 위한 것으로")
                            .lineLimit(2)
                            .font(.system(size: 13, weight: .medium))
                            .frame(width: UIScreen.main.bounds.width - 70, height: 40, alignment: .topLeading)
                        Spacer()
//                        Picker(selection: $selection, label: Image(systemName: "ellipsis")) {
//                            ForEach(0..<3, id: \.self) { index in
//                                Text(String(index))
//                            }
//                        }.pickerStyle(MenuPickerStyle())
                        Menu{
//                            Button(action: {
//
//                            }){
//                                Text("삭제")
//                                    .foregroundColor(.red)
//                            }
//                            Button("카테고리 이동", action: {})
//                            Button("이름 변경", action: {})
                            ForEach(menu, id: \.self) { button in
                                Button(button, action: {})
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                        .padding(.trailing, 4)
                        .padding(.vertical, 4)
                        .foregroundColor(.black)
                    }
                    .frame(width: UIScreen.main
                            .bounds.width - 40, height: 36, alignment: .center)
                    Text("naver.com") //출처
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(0)
                        .frame(width: UIScreen.main
                                .bounds.width - 44, alignment: .leading)
                }
            }
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView()
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
