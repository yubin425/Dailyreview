import Foundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers

func shareContent(_ codableObject: CodableWL) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    guard let jsonData = try? encoder.encode(codableObject),
          let jsonString = String(data: jsonData, encoding: .utf8) else {
        print("Failed to encode CodableWL object.")
        return
    }

    let activityController = UIActivityViewController(activityItems: [jsonString], applicationActivities: nil)
            
    // 현재 ViewController에서 표시 (SwiftUI에서 사용)
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootViewController = windowScene.windows.first?.rootViewController {
        rootViewController.present(activityController, animated: true, completion: nil)
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFileContent: WishListFolder
    @Binding var isLoaded: String

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.plainText, .json])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedFileContent: $selectedFileContent, isLoaded: $isLoaded)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        @Binding var selectedFileContent: WishListFolder
        @Binding var isLoaded: String
        
        init(selectedFileContent: Binding<WishListFolder>, isLoaded: Binding<String>) {
            _selectedFileContent = selectedFileContent
            _isLoaded = isLoaded
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            do {
                if url.startAccessingSecurityScopedResource() {
                    let data = try Data(contentsOf: url) // 데이터를 읽음
                    let decoder = JSONDecoder() // JSONDecoder 초기화
                    let decodedObject = try decoder.decode(CodableWL.self, from: data) // 디코딩
                    selectedFileContent = decodedObject.copy()
                    isLoaded = "불러오기 완료"
                }
                url.stopAccessingSecurityScopedResource()
            } catch {
                // 에러 처리
                print("Failed to decode file content: \(error.localizedDescription)")
                isLoaded = "불러오기 실패"
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            isLoaded = "불러오기 실패"
        }
    }
}
