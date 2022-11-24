//
//  DataSheetView.swift
//  Scrap
//
//  Created by 김영선 on 2022/11/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct DataSheetView: View {
    @Environment(\.colorScheme) var scheme //Light/Dark mode
    @EnvironmentObject var vm : ScrapViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @EnvironmentObject var userVM : UserViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @Binding var isShowMovingCategory : Bool
    @Binding var data : DataResponse.Datas
    @Binding var isPresentHalfModal : Bool
    @Binding var currentCatOrder : Int
    @Binding var currentCategory : Int

    var body: some View {
        VStack{
            Text(data.title ?? "")
                .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
            List {
                Section {
                    Button(action:{
                        UIPasteboard.general.setValue(data.link ?? "", forPasteboardType: UTType.plainText.identifier)
                        isPresentHalfModal.toggle()
                    }){
                        Label("링크 복사", systemImage: "doc.on.doc")
                            .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
                    }
                }
                .listRowBackground(scheme == .light ? Color(.white) : .black_bold)
                Section {
                    if currentCatOrder != 0 { //전체 자료는 카테고리 이동 불가
                        Button(action: {
                            isShowMovingCategory = true
                            isPresentHalfModal.toggle()
                        }) {
//                            NavigationLink(destination: MoveCategoryView(isShowMovingCategory: $isShowMovingCategory, categoryList: $vm.categoryList.result, data: $data, currentCategory: $currentCategory).navigationBarBackButtonHidden(true).navigationBarBackButtonHidden(true), isActive: $isShowMovingCategory){
                            Label("카테고리 이동", systemImage: "arrow.turn.down.right")
                                .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
//                            }
                        }
                    }
                    Button(action:{
                        vm.deleteData(userID: userVM.userIdx, linkID: data.linkId!)
                        vm.removeData(linkID: data.linkId!)
                        isPresentHalfModal.toggle()
                    }){
                        Label("삭제", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                .listRowBackground(scheme == .light ? Color(.white) : .black_bold)
            }
            .background(scheme == .light ? Color("background") : .black_bg)
        }
        .padding(.top, 48)
        .background(scheme == .light ? Color("background") : .black_bg)
    }
}

struct DataSheetView_Previews: PreviewProvider {
    static var previews: some View {
        DataSheetView(
            isShowMovingCategory: .constant(true),
            data: .constant(DataResponse.Datas(linkId: 0, link: "https://www.apple.com", title: "명탐정코난재미있네허허남도일! 이름도 참 잘지었어 유명한 이름도 진짜 독특하고 잘지은듯 유명한 탐정 유명한!ㅋㅋㅋㅋ", domain: "naver.com", imgUrl: "")),
            isPresentHalfModal: .constant(true),
            currentCatOrder: .constant(1),
            currentCategory: .constant(1)
        )
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
            .preferredColorScheme(.dark)
    }
}
