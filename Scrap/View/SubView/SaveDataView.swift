////
////  SaveDataView.swift
////  Scrap
////
////  Created by 김영선 on 2022/11/16.
////
//
//import SwiftUI
//
//struct SaveDataView: View {
//    @Environment(\.colorScheme) var scheme //Light/Dark mode
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //pop
//    @State private var selection = 0
//    @EnvironmentObject var vm : ScrapViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
//    @EnvironmentObject var userVM : UserViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
//    let url = UserDefaults(suiteName: "group.com.thk.Scrap")?.string(forKey: "WebURL") ?? ""
//
//    var body: some View {
//        NavigationView {
//            List{
//                ForEach($vm.categoryList.result.categories){ $category in
//                    if category.order != 0 { //모든 자료는 제외
//                        Button(action :{
//                            self.selection = category.categoryId
//                        }){
//                            Text(category.name)
//                            .foregroundColor(scheme == .light ? .black : .gray_sub)
//                        }
//                        .listRowBackground(self.selection == category.categoryId ? (scheme == .light ? .gray_sub : .black_accent) : scheme == .light ? Color(.white) : .black_bg)
//                        .frame(width: UIScreen.main.bounds.width, height: 30, alignment: .leading)
//                    }
//                }
//            }
//            .listStyle(PlainListStyle())
//            .background(scheme == .light ? .white : .black_bg)
//            .navigationBarTitle("자료 저장", displayMode: .inline)
//            .foregroundColor(scheme == .light ? .black : .gray_sub)
//            .navigationBarItems(leading: Button(action: {
//                UserDefaults(suiteName: "group.com.thk.Scrap")?.set("", forKey: "WebURL") //""로 업데이트
//                self.presentationMode.wrappedValue.dismiss()
//            }){
//                Text("취소")
//                    .fontWeight(.semibold)
//                    .foregroundColor(scheme == .light ? .black : .gray_sub)
//            })
//            .navigationBarItems(trailing: Button(action: {
//                print("add new data?")
//                print("url: \(url)")
//                vm.addNewData(baseurl: url, catID: selection, userIdx: userVM.userIdx) //📡데이터 저장 서버 통신
//                UserDefaults(suiteName: "group.com.thk.Scrap")?.set("", forKey: "WebURL") //""로 업데이트
//                self.presentationMode.wrappedValue.dismiss()
//            }){
//                Text("저장")
//                    .fontWeight(.semibold)
//                    .foregroundColor(.blue_bold)
//            })
//        }
//
//    }
//}
//
//struct SaveDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        SaveDataView()
//            .environmentObject(ScrapViewModel())
//            .environmentObject(UserViewModel())
//            .preferredColorScheme(.dark)
//    }
//}
