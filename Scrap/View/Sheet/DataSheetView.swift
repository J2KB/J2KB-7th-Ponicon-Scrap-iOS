//
//  DataSheetView.swift
//  Scrap
//
//  Created by 김영선 on 2022/11/23.
//

import SwiftUI
import UniformTypeIdentifiers
import UserNotifications

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
    @State private var isBookmarked = false
    
    @Binding var isShowMovingCategoryView : Bool
    @Binding var data : DataResponse.Datas
    @Binding var isPresentDataModalSheet : Bool
    @Binding var currentCategoryOrder : Int
    @Binding var currentCategoryId : Int
    
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height

    var body: some View {
        VStack(spacing: 24){
            if isEditingDataName { RenameView }
            else                 { TitleView }
            CopyLinkButton
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("list_color"))
                    .frame(width: screenWidth - 40, height: screenHeight / 4.7, alignment: .leading)
                VStack(spacing: 2){
                    FavoriteButton
                    Divider().frame(width: screenWidth - 40).padding(.vertical, 0)
                    RenameButton
                    Divider().frame(width: screenWidth - 40)
                    MoveCategoryButton
                    Divider().frame(width: screenWidth - 40)
                    DeleteButton
                }
            }
            Spacer()
        }
        .onAppear {
            self.renamedDataName = data.title ?? ""
            self.isBookmarked = data.bookmark
        }
        .padding(.top, 48)
        .background(Color("sheet_background"))
        .alert("정말 삭제하시겠습니까?", isPresented: $isDeleteData, actions: {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                removeData()
            }
        })
    }
    
    private func removeData() {
        scrapVM.deleteData(userID: userVM.userIndex, linkID: data.linkId!) //📡 자료 삭제 서버 통신
        scrapVM.removeDataFromDataList(dataID: data.linkId!, categoryID: currentCategoryId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            scrapVM.getCategoryListData(userID: userVM.userIndex)
        }
        isPresentDataModalSheet = false
        self.isDeleteData = false
    }
    
    var TitleView: some View {
        Text(data.title ?? "")
            .frame(width: screenWidth - 40, alignment: .leading)
            .foregroundColor(Color("basic_text"))
    }
    
    var RenameView: some View {
        HStack{
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("textfield_color"))
                    .opacity(0.4)
                    .frame(width: screenWidth / 1.25, height: 36, alignment: .leading)
                HStack(spacing: 13){
                    TextField("자료 이름", text: $renamedDataName)
                        .focused($focusState, equals: .rename)
                        .font(.system(size: 14, weight: .regular))
                        .frame(width: screenWidth / 1.5, alignment: .leading)
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
                if !renamedDataName.isEmpty { //새로 쓴 이름이 비어있지 않을 경우 -> 이름 수정 저장
                    scrapVM.renameData(dataID: data.linkId ?? 0, renamed: renamedDataName) //local method
                    scrapVM.modifyDataName(dataID: data.linkId ?? 0, dataName: renamedDataName, userIdx: userVM.userIndex) //server
                    self.isEditingDataName = false
                    data.title = renamedDataName
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        scrapVM.getCategoryListData(userID: userVM.userIndex)
                    }
                } else { //새로 쓴 이름이 비어있을 경우
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
    }
    
    var CopyLinkButton: some View {
        Button(action: {
            UIPasteboard.general.setValue(data.link ?? "", forPasteboardType: UTType.plainText.identifier)
            isPresentDataModalSheet = false
        }) {
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("list_color"))
                    .frame(width: screenWidth - 40, height: 46, alignment: .leading)
                Label("링크 복사", systemImage: "doc.on.doc")
                    .foregroundColor(Color("basic_text"))
                    .frame(width: screenWidth - 40, height: 46, alignment: .leading)
                    .padding(.leading, 40)
            }
        }
    }
    
    var FavoriteButton: some View {
        Button(action: {
            //즐겨찾기 기능
            self.isBookmarked = !isBookmarked
            scrapVM.modifyFavoritesData(userID: userVM.userIndex, linkID: data.linkId!) //서버통신
            scrapVM.bookmark(dataID: data.linkId!, isBookmark: isBookmarked)
            isPresentDataModalSheet = false
        }) {
            //즐겨찾기에 추가 되어/안되어 있으면, 해제 / 추가
            Label(isBookmarked ? "즐겨찾기 해제" : "즐겨찾기 추가", systemImage: "heart")
                .foregroundColor(Color("basic_text"))
                .frame(width: screenWidth - 40, height: 42, alignment: .leading)
                .padding(.leading, 40)
        }
    }
    
    var RenameButton: some View {
        Button(action: {
            self.isEditingDataName = true
        }) {
            Label("이름 수정", systemImage: "pencil")
                .foregroundColor(Color("basic_text"))
                .frame(width: screenWidth - 40, height: 40, alignment: .leading)
                .padding(.leading, 40)
        }
    }
    
    var MoveCategoryButton: some View {
        Button(action: {
            isShowMovingCategoryView = true
            isPresentDataModalSheet = false
        }) {
            Label("카테고리 이동", systemImage: "arrow.turn.down.right")
                .foregroundColor(Color("basic_text"))
                .frame(width: screenWidth - 40, height: 40, alignment: .leading)
                .padding(.leading, 40)
        }
    }
    
    var DeleteButton: some View {
        Button(action:{
            self.isDeleteData = true
        }){
            Label("삭제", systemImage: "trash")
                .foregroundColor(.red)
                .frame(width: screenWidth - 40, height: 40, alignment: .leading)
                .padding(.leading, 40)
        }
    }
}

struct DataSheetView_Previews: PreviewProvider {
    static var previews: some View {
        DataSheetView(
            isShowMovingCategoryView: .constant(true),
            data: .constant(DataResponse.Datas(linkId: 0, link: "https://www.apple.com", title: "명탐정코난재미있네유명한이름진짜독특하고 잘지은듯.. 유명한탐정유명한ㅋㅋㅋㅋ", domain: "naver.com", imgUrl: "", bookmark: false)),
            isPresentDataModalSheet: .constant(true),
            currentCategoryOrder: .constant(1),
            currentCategoryId: .constant(1)
        )
        .environmentObject(ScrapViewModel())
        .environmentObject(UserViewModel())
    }
}
