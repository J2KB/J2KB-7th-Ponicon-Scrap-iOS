//
//  PageView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI

struct PageView: View {
    @Binding var data : DataModel
    @Binding var isOneCol : Bool
    @State private var height = 200
    @State var selection: Int = -1
    @State private var menu = ["삭제", "카테고리 이동", "이름 변경"]
    let light_blue = Color(red: 70/255, green: 193/255, blue: 241/255)

    var body: some View {
        VStack(spacing: 0){
            //imageUrl == nil
            //light_color
            //imageUrl != nil
            if data.imageURL == ""{ //image 없으면 default light_blue color
                Rectangle()
                    .foregroundColor(light_blue)
                    .frame(width: isOneCol ? UIScreen.main.bounds.width - 24 : UIScreen.main.bounds.width / 2.2, height: isOneCol ? 130 : 98)
                    .cornerRadius(10, corners: .topLeft)
                    .cornerRadius(10, corners: .topRight)
                    .shadow(radius: 2)
            }else{
                Image(data.imageURL!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
//                    .aspectRatio(contentMode: .fit)
                    .frame(width: isOneCol ? UIScreen.main.bounds.width - 24 : UIScreen.main.bounds.width / 2.2, height: isOneCol ? 130 : 98)
                    .cornerRadius(10, corners: .topLeft)
                    .cornerRadius(10, corners: .topRight)
                    .shadow(radius: 2)
            }
            ZStack{
                Rectangle()
                    .frame(width: isOneCol ? UIScreen.main.bounds.width - 23 : UIScreen.main.bounds.width / 2.225, height: 76)
                    .foregroundColor(.white)
                    .cornerRadius(10, corners: .bottomLeft)
                    .cornerRadius(10, corners: .bottomRight)
                    .opacity(1)
                    .shadow(radius: 2)
                VStack(spacing: 12){
                    HStack(spacing: -2){
                        Text(data.title)
                            .lineLimit(2)
                            .font(.system(size: 13, weight: .medium))
                            .frame(width: isOneCol ? UIScreen.main.bounds.width - 70 : UIScreen.main.bounds.width / 2.8, height: 40, alignment: .topLeading)
                        Spacer()
                        Menu{
//                            Button(action: {}){
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
                    .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.4, height: 36, alignment: .center)
                    Text(data.domain) //출처
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(0)
                        .frame(width: isOneCol ? UIScreen.main.bounds.width - 44 : UIScreen.main.bounds.width / 2.3, alignment: .leading)
                }
            }
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(data: .constant(DataModel(title: "apple", link: "https://www.apple.com", imageURL: "iOS", domain: "apple.com")), isOneCol: .constant(false))
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
