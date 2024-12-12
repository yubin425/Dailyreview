import Foundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers

func createJsonFile(wishlist: CodableWL){
    // 로컬 파일 경로 생성
    let fileManager = FileManager.default
    let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentDirectory.appendingPathComponent("movie.json")

    do {
        // Movie 객체를 JSON 데이터로 인코딩
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(wishlist)
        
        // JSON 데이터를 해당 파일에 저장
        try jsonData.write(to: fileURL)
        print("파일이 성공적으로 저장되었습니다: \(fileURL.path)")
    } catch {
        print("저장 중 오류 발생: \(error)")
    }
}

// WishListFolder 객체를 JSON 파일에서 읽어오는 함수
func loadJsonFile() -> WishListFolder? {
    let fileManager = FileManager.default
    let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentDirectory.appendingPathComponent("movie.json")
    
    do {
        // 파일에서 데이터를 읽어오기
        let jsonData = try Data(contentsOf: fileURL)
        
        // JSON 데이터를 WishListFolder 객체로 디코딩
        let decoder = JSONDecoder()
        let wishlist = try decoder.decode(CodableWL.self, from: jsonData)
        
        print("파일이 성공적으로 불러와졌습니다.")
        return wishlist.copy()
    } catch {
        print("파일 읽기 또는 디코딩 오류 발생: \(error)")
        return nil
    }
}

// `UIDocumentPickerViewController`를 SwiftUI에 통합
struct DocumentPickerView: UIViewControllerRepresentable {
    var wl: CodableWL
    @Binding var wishlist: WishListFolder
    @Binding var isLoaded: String
    @Environment(\.modelContext) private var modelContext
    var mode: DocumentPickerMode
    var onError: (String) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker: UIDocumentPickerViewController
        if mode == .export {
            documentPicker = UIDocumentPickerViewController(forExporting: [])
        } else {
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.json])
        }
        documentPicker.allowsMultipleSelection = false
        documentPicker.delegate = context.coordinator
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView
        
        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }
        
        // 파일 불러오기 처리
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let selectedURL = urls.first else { return }
            
            switch parent.mode {
            case .export:
                do {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    let jsonData = try encoder.encode(parent.wl)
                    try jsonData.write(to: selectedURL)
                    print("파일이 성공적으로 저장되었습니다: \(selectedURL)")
                } catch {
                    parent.onError("파일 저장 실패: \(error.localizedDescription)")
                }
            case .importFile:
                do {
                    let jsonData = try Data(contentsOf: selectedURL)
                    let decoder = JSONDecoder()
                    let wishlist = try decoder.decode(CodableWL.self, from: jsonData)
                    parent.wishlist = wishlist.copy()
                    print("파일이 성공적으로 불러와졌습니다: \(selectedURL)")
                    parent.isLoaded = "불러오기 완료"
                } catch {
                    parent.onError("파일 불러오기 실패: \(error.localizedDescription)")
                }
            }
        }
        
        // 취소 처리
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("사용자가 파일 선택을 취소했습니다.")
        }
    }
}

enum DocumentPickerMode {
    case export
    case importFile
}
