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
    @State private var isDelete = false
    @Binding var isShowMovingCategory : Bool
    @Binding var data : DataResponse.Datas
    @Binding var isPresentHalfModal : Bool
    @Binding var currentCatOrder : Int
    @Binding var currentCategory : Int

    var body: some View {
        VStack(spacing: 24){
            Text(data.title ?? "")
                .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                .foregroundColor(Color("basic_text"))
            Button(action: {
                UIPasteboard.general.setValue(data.link ?? "", forPasteboardType: UTType.plainText.identifier)
                isPresentHalfModal.toggle()
            }) {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("list_color"))
                        .frame(width: UIScreen.main.bounds.width - 40, height: 46, alignment: .leading)
                    Label("링크 복사", systemImage: "doc.on.doc")
                        .foregroundColor(Color("basic_text"))
                        .frame(width: UIScreen.main.bounds.width - 40, height: 46, alignment: .leading)
                        .padding(.leading, 40)
                }
            }
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("list_color"))
                    .frame(width: UIScreen.main.bounds.width - 40, height: currentCatOrder == 0 ? 46 : 100, alignment: .leading)
                VStack(spacing: 4){
                    if currentCatOrder != 0 {
                        Button(action: {
                            isShowMovingCategory = true
                            isPresentHalfModal.toggle()
                        }) {
                            Label("카테고리 이동", systemImage: "arrow.turn.down.right")
                                .foregroundColor(Color("basic_text"))
                                .frame(width: UIScreen.main.bounds.width - 40, height: 40, alignment: .leading)
                                .padding(.leading, 40)
                        }
                        Divider()
                            .frame(width: UIScreen.main.bounds.width - 40)
                    }
                    Button(action:{
                        self.isDelete = true
                    }){
                        Label("삭제", systemImage: "trash")
                            .foregroundColor(.red)
                            .frame(width: UIScreen.main.bounds.width - 40, height: 40, alignment: .leading)
                            .padding(.leading, 40)
                    }
                }
            }
            Spacer()
        }
        .padding(.top, 48)
        .background(Color("sheet_background"))
        .alert("정말 삭제하시겠습니까?", isPresented: $isDelete, actions: {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                //📡 자료 삭제 서버 통신
                vm.deleteData(userID: userVM.userIdx, linkID: data.linkId!)
                vm.removeDataFromDataList(dataID: data.linkId!, categoryID: currentCategory)
                isPresentHalfModal = false
                self.isDelete = false
            }
        })
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
