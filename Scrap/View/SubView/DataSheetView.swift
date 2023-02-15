//
//  DataSheetView.swift
//  Scrap
//
//  Created by 김영선 on 2022/11/23.
//

import SwiftUI
import UniformTypeIdentifiers

enum DataNameField {
    case rename
}

struct DataSheetView: View {
    @EnvironmentObject var scrapVM : ScrapViewModel
    @EnvironmentObject var userVM : UserViewModel
    @FocusState var focusState : DataNameField?

    @State private var isDeleteData = false
    @State private var isEditingDataName = false
    @State private var renamedDataName = ""
    
    @Binding var isShowMovingCategoryView : Bool
    @Binding var data : DataResponse.Datas
    @Binding var isPresentDataModalSheet : Bool
    @Binding var currentCategoryOrder : Int
    @Binding var currentCategoryId : Int

    var body: some View {
        VStack(spacing: 24){
            if isEditingDataName {
                HStack{
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("textfield_color"))
                            .opacity(0.4)
                            .frame(width: UIScreen.main.bounds.width / 1.25, height: 36, alignment: .leading)
                        HStack(spacing: 13){
                            TextField("자료 이름", text: $renamedDataName)
                                .focused($focusState, equals: .rename)
                                .font(.system(size: 18, weight: .regular))
                                .frame(width: UIScreen.main.bounds.width / 1.5, alignment: .leading)
                                .foregroundColor(Color("basic_text"))
                            Button(action: {
                                renamedDataName = "" //clear category name
                            }) {
                                ZStack{
                                    Image(systemName: "xmark.circle")
                                        .resizable()
                                        .foregroundColor(.gray)
                                        .frame(width: 14, height: 14)
                                }
                                .frame(width: 24, height: 36)
                            }
                        }
                    }
                    Button(action: {
                        if !renamedDataName.isEmpty {
//                            scrapVM.renameCategory(categoryID: category.categoryId, renamed: renamedCategoryName)
//                            scrapVM.modifyCategoryName(categoryID: category.categoryId, categoryName: renamedCategoryName)
                            self.isEditingDataName = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                scrapVM.getCategoryListData(userID: userVM.userIndex)
                            }
                        } else {
                            renamedDataName = data.title ?? "" //원래 카테고리 이름으로
                            self.isEditingDataName = false
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("list_color"))
                                .frame(width: 36, height: 36, alignment: .leading)
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(Color("blue_bold"))
                        }
                    }
                }
                .padding(.bottom, 10)
            }else {
                Text(data.title ?? "")
                    .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                    .foregroundColor(Color("basic_text"))
            }
            Button(action: {
                UIPasteboard.general.setValue(data.link ?? "", forPasteboardType: UTType.plainText.identifier)
                isPresentDataModalSheet.toggle()
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
                    .frame(width: UIScreen.main.bounds.width - 40, height: currentCategoryOrder == 0 ? 46 : 140, alignment: .leading)
                VStack(spacing: 4){
                    Button(action: {
                        self.isEditingDataName = true
                    }) {
                        Label("이름 수정", systemImage: "pencil")
                            .foregroundColor(Color("basic_text"))
                            .frame(width: UIScreen.main.bounds.width - 40, height: 40, alignment: .leading)
                            .padding(.leading, 40)
                    }
                    Divider()
                        .frame(width: UIScreen.main.bounds.width - 40)
                    if currentCategoryOrder != 0 {
                        Button(action: {
                            isShowMovingCategoryView = true
                            isPresentDataModalSheet.toggle()
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
                        self.isDeleteData = true
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
        .alert("정말 삭제하시겠습니까?", isPresented: $isDeleteData, actions: {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                scrapVM.deleteData(userID: userVM.userIndex, linkID: data.linkId!) //📡 자료 삭제 서버 통신
                scrapVM.removeDataFromDataList(dataID: data.linkId!, categoryID: currentCategoryId)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    scrapVM.getCategoryListData(userID: userVM.userIndex)
                }
                isPresentDataModalSheet = false
                self.isDeleteData = false
            }
        })
    }
}

struct DataSheetView_Previews: PreviewProvider {
    static var previews: some View {
        DataSheetView(
            isShowMovingCategoryView: .constant(true),
            data: .constant(DataResponse.Datas(linkId: 0, link: "https://www.apple.com", title: "명탐정코난재미있네허허남도일! 이름도 참 잘지었어 유명한 이름도 진짜 독특하고 잘지은듯 유명한 탐정 유명한!ㅋㅋㅋㅋ", domain: "naver.com", imgUrl: "")),
            isPresentDataModalSheet: .constant(true),
            currentCategoryOrder: .constant(1),
            currentCategoryId: .constant(1)
        )
        .environmentObject(ScrapViewModel())
        .environmentObject(UserViewModel())
        .preferredColorScheme(.dark)
    }
}
