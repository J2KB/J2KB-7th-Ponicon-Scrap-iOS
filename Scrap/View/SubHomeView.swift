//
//  MainHomeView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI

struct DataModel: Identifiable{
    var id = UUID()
    var title : String
    var link : String
    var imageURL : String?
    var domain: String
    
    init(title: String, link: String, imageURL: String, domain: String){
        self.title = title
        self.link = link
        self.imageURL = imageURL
        self.domain = domain
    }
}

struct SubHomeView: View {
    @State private var items = [
      DataModel(title: "인텔리제이 디버깅 해보기 여기도 마찬가지로 칸을 넘어가는 제목같은 경우는 점으로 표시합니다. 글자수 채우기 위한 것으로 허허", link: "https://www.twitter.com", imageURL: "sample", domain: "twitter.com"),
      DataModel(title: "Developer", link: "https://www.developer.apple.com", imageURL: "developer", domain: "developer.apple.com"),
      DataModel(title: "Goole(Korea)", link: "https://www.google.co.kr", imageURL: "", domain: "google.co.kr"),
      DataModel(title: "Apple(Korea)", link: "https://www.apple.com", imageURL: "iOS", domain: "apple.com")
    ]
    
    @State private var isOneCol = true;
    @State private var isRecent = true;
    
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
                        ForEach($items.reversed()) { item in
                            if let urlString = item.link {
                                let url = URL(string: urlString.wrappedValue)
                                if let Url = url {
                                    Link(destination: Url, label:{
                                        PageView(data: item, isOneCol: $isOneCol)
                                            .padding(2)
                                    })
                                    .foregroundColor(.black)
                                }
                            }
                        }
                    }else {
                        ForEach($items) { item in
                            if let urlString = item.link {
                                let url = URL(string: urlString.wrappedValue)
                                if let Url = url {
                                    Link(destination: Url, label:{
                                        PageView(data: item, isOneCol: $isOneCol)
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
        SubHomeView()
    }
}
