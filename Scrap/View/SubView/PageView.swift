//
//  PageView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI
import UniformTypeIdentifiers

struct PageView: View {
    @EnvironmentObject var vm : ScrapViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @Binding var data : DataResponse.Datas
    @Binding var isOneCol : Bool
    @State private var height = 200
    @State private var isPresentHalfModal = false
    @State private var isShowMovingCategory = false
    @Binding var currentCategory : Int

    var body: some View {
        VStack(spacing: 0){
            if data.imgUrl == "" || data.imgUrl == nil { //image 없으면 default light_blue color
                VStack(spacing: -2){
                    if let urlString = data.link {
                        let url = URL(string: urlString)
                        if let Url = url {
                            Link(destination: Url, label:{
                                Rectangle()
                                    .foregroundColor(.light_blue)
                                    .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 10, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 2) / 1.5 : (UIScreen.main.bounds.width / 2.5) / 1.65)
                                    .cornerRadius(10, corners: .topLeft)
                                    .cornerRadius(10, corners: .topRight)
                                    .shadow(radius: 2)
                            })
                            .foregroundColor(.black)
                        }
                    }
                    ZStack{
                        Rectangle()
                            .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 10, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 5) : (UIScreen.main.bounds.width / 2.5) / 2.3)
                            .foregroundColor(.white)
                            .cornerRadius(10, corners: .bottomLeft)
                            .cornerRadius(10, corners: .bottomRight)
                            .shadow(radius: 2)
                        VStack(spacing: 2){
                            Text(data.title ?? "")
                                .lineLimit(2)
                                .font(.system(size: 13, weight: .medium))
                                .frame(width: isOneCol ? UIScreen.main.bounds.width - 90 : UIScreen.main.bounds.width / 3 - 14, height: 40, alignment: .topLeading)
                                .padding(.trailing, 40)
                            Text(data.domain ?? "") //출처 -> link에서 자르기
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                                .padding(.horizontal, 5)
                                .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 10, alignment: .leading)
                        }
                        Button(action: {
                            self.isPresentHalfModal = true //half-modal view 등장
                        }){
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                                .foregroundColor(.black_bold)
                        }
                        .padding(EdgeInsets(top: 1, leading: isOneCol ? 315 : 136, bottom: 20, trailing: 0))
                    }
                }
            } else {
                VStack(spacing: -2){
                    ZStack {
                        Rectangle()
                            .foregroundColor(.light_blue)
                            .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 10, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 2) / 1.5 : (UIScreen.main.bounds.width / 2.5) / 1.65)
                            .cornerRadius(10, corners: .topLeft)
                            .cornerRadius(10, corners: .topRight)
                            .shadow(radius: 2)
                        if let urlString = data.link {
                            let url = URL(string: urlString)
                            if let Url = url {
                                Link(destination: Url, label:{
                                    Image(systemName: "person.fill")
                                        .imageData(url: URL(string: data.imgUrl!)!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 10, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 2) / 1.5 : (UIScreen.main.bounds.width / 2.5) / 1.65)
                                        .cornerRadius(10, corners: .topLeft)
                                        .cornerRadius(10, corners: .topRight)
                                })
                                .foregroundColor(.black)
                            }
                        }
                    }
                    ZStack{
                        Rectangle()
                            .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 10, height: isOneCol ? ((UIScreen.main.bounds.width - 40) / 5) : (UIScreen.main.bounds.width / 2.5) / 2.3)
                            .foregroundColor(.white)
                            .cornerRadius(10, corners: .bottomLeft)
                            .cornerRadius(10, corners: .bottomRight)
                            .shadow(radius: 2)
                        VStack(spacing: 2){
                            Text(data.title ?? "")
                                .lineLimit(2)
                                .font(.system(size: 13, weight: .medium))
                                .frame(width: isOneCol ? UIScreen.main.bounds.width - 90 : UIScreen.main.bounds.width / 3 - 14, height: 40, alignment: .topLeading)
                                .padding(.trailing, 40)
                            Text(data.domain ?? "") //출처 -> link에서 자르기
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                                .padding(.horizontal, 5)
                                .frame(width: isOneCol ? UIScreen.main.bounds.width - 40 : UIScreen.main.bounds.width / 2.5 + 10, alignment: .leading)
                        }
                        Button(action: {
                            self.isPresentHalfModal = true //half-modal view 등장
                        }){
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                                .foregroundColor(.black_bold)
                        }
                        .padding(EdgeInsets(top: 1, leading: isOneCol ? 315 : 200, bottom: 20, trailing: isOneCol ? 0 : 100))
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentHalfModal){
            HalfSheet {
                VStack{
                    Text(data.title ?? "")
                        .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                    List {
                        Section {
                            Button(action:{
                                UIPasteboard.general.setValue(data.link ?? "", forPasteboardType: UTType.plainText.identifier)
                                self.isPresentHalfModal = false
                            }){
                                Label("링크 복사", systemImage: "doc.on.doc")
                                    .foregroundColor(.black)
                            }
                            .foregroundColor(.black)
                        }
                        Section {
                            Button(action: {
                                self.isPresentHalfModal = false  //이거 안됨🚨
                                self.isShowMovingCategory = true
                            }) {
                                NavigationLink(destination: MoveCategoryView(categoryList: $vm.categoryList.result, data: $data, currentCategory: $currentCategory).navigationBarBackButtonHidden(true), isActive: $isShowMovingCategory){
                                    Label("카테고리 이동", systemImage: "arrow.turn.down.right")
                                        .foregroundColor(.black)
                                }
                            }
                            .foregroundColor(.black)
                            Button(action:{
                                //이 자료의 인덱스를 찾아서 삭제해야됨...
                                vm.removeData(linkID: data.linkId!)
                                self.isPresentHalfModal = false
                            }){
                                Label("삭제", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .background(Color("background"))
                }
                .padding(.top, 48)
                .background(Color("background"))
            }
            .ignoresSafeArea()
        }
        .onAppear{
            UITableView.appearance().backgroundColor = .clear
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(data: .constant(DataResponse.Datas(linkId: 0, link: "", title: "", domain: "", imgUrl: "")), isOneCol: .constant(false), currentCategory: .constant(0))
            .environmentObject(ScrapViewModel())
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
