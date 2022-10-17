//
//  PageView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI

struct PageView: View {
    @Binding var data : DataResponse.Datas
    @Binding var isOneCol : Bool
    @State private var height = 200
    @State private var menu = ["삭제", "카테고리 이동", "이름 변경"]

    var body: some View {
        VStack(spacing: 0){
            //imageUrl == nil
            //light_color
            //imageUrl != nil
            if data.imgUrl == ""{ //image 없으면 default light_blue color
                Rectangle()
                    .foregroundColor(.light_blue)
                    .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 10, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 2) / 1.5 : (UIScreen.main.bounds.width / 2.5) / 1.65)
                    .cornerRadius(10, corners: .topLeft)
                    .cornerRadius(10, corners: .topRight)
                    .shadow(radius: 2)
            }else{
                Image(systemName: "person.fill")
                    .imageData(url: URL(string: data.imgUrl)!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 10, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 2) / 1.5 : (UIScreen.main.bounds.width / 2.5) / 1.65)
                    .cornerRadius(10, corners: .topLeft)
                    .cornerRadius(10, corners: .topRight)
                    .shadow(radius: 2)
            }
            ZStack{
                Rectangle()
                    .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 10, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 5) : (UIScreen.main.bounds.width / 2.5) / 2.3)
                    .foregroundColor(.white)
                    .cornerRadius(10, corners: .bottomLeft)
                    .cornerRadius(10, corners: .bottomRight)
//                    .opacity(1)
                    .shadow(radius: 2)
                VStack(spacing: 2){
                    HStack(spacing: -2){
                        Text(data.title)
                            .lineLimit(2)
                            .font(.system(size: 13, weight: .medium))
                            .frame(width: isOneCol ? UIScreen.main.bounds.width - 80 : UIScreen.main.bounds.width / 3, height: 40, alignment: .topLeading)
                        Menu{
                            //half view 등장
                        } label: {
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 16)
                        .foregroundColor(.black)
                    }
                    .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 10, height: (UIScreen.main.bounds.width - 40) / 8.75)
                    Text("domain") //출처 -> link에서 자르기
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .padding(.horizontal, 5)
                        .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 10, alignment: .leading)
                }
            }
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(data: .constant(DataResponse.Datas(linkId: 0, link: "", title: "", domain: "", imgUrl: "")), isOneCol: .constant(true))
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

extension Image {
    func imageData(url: URL) -> Self {
        if let data = try? Data(contentsOf: url){
            return Image(uiImage: UIImage(data: data)!)
        }
        return self
    }
}
