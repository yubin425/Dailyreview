
import SwiftUI
import SwiftData
import Charts

struct MyPageView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("userName") private var userName = "User"
    @State private var showImagePicker = false
    @State private var profileImage: UIImage? = nil
    @Query private var reviews: [Review]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // 프로필 섹션
                HStack {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    } else {
                        Circle()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                            .overlay(Text("사진 추가").font(.caption))
                            .onTapGesture {
                                showImagePicker = true
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(userName)
                            .font(.headline)
                        Button("닉네임 변경") {
                            changeUserName()
                        }
                        .font(.subheadline)
                        .foregroundColor(.red)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(selectedImage: $profileImage)
                }

                // 설정 리스트
                List {
                    Section {
                        // 다크 모드 설정
                        Toggle(isOn: $isDarkMode) {
                            HStack {
                                Image(systemName: "moon.fill")
                                    .foregroundColor(.orange)
                                Text("다크 모드")
                            }
                        }

                        // 영화 통계 보기
                        NavigationLink(destination: UserStatisticsView(reviews: reviews)) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.blue)
                                Text("영화 통계 보기")
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle()) 
                .scrollContentBackground(.hidden)
                .frame(maxHeight: .infinity)
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .animation(.easeInOut, value: isDarkMode)
        }
    }

    private func changeUserName() {
        let alert = UIAlertController(title: "닉네임 변경", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = userName
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                userName = newName
            }
        }))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
}

struct UserStatisticsView: View {
    let reviews: [Review]

    @State private var statistics: [String] = []
    @State private var genreData: [GenreStat] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // 제목
                Text("\(UserDefaults.standard.string(forKey: "userName") ?? "User")님의 영화 통계")
                    .font(.largeTitle)
                    .padding()

                // 텍스트 통계
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(statistics, id: \.self) { stat in
                        Text(stat)
                            .font(.body)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
                .padding()

                // 장르별 영화 수 그래프
                if !genreData.isEmpty {
                    Text("장르별 영화 수")
                        .font(.headline)
                        .padding()

                    Chart(genreData) { genre in
                        BarMark(
                            x: .value("장르", genre.genre),
                            y: .value("수", genre.count)
                        )
                        .foregroundStyle(
                            genre.isHighest ? Color.red : Color.gray
                        )
                    }
                    .frame(height: 300)
                    .padding()
                }
            }
        }
        .onAppear {
            calculateStatistics()
        }
    }

    private func calculateStatistics() {
        statistics = generateStatistics(reviews: reviews)
        genreData = generateGenreData(reviews: reviews)
    }

    private func generateStatistics(reviews: [Review]) -> [String] {
        var stats: [String] = []

        let totalMovies = reviews.count
        stats.append("총 본 영화 수: \(totalMovies)개")

        let watchedThisMonth = moviesWatchedThisMonth(reviews: reviews)
        stats.append("이번 달에 본 영화 수: \(watchedThisMonth)개")

        let averageRating = reviews.isEmpty ? 0 : reviews.map { $0.rating }.reduce(0, +) / reviews.count
        stats.append("평균 평점: \(String(format: "%.1f", averageRating))점")

        let bestRated = bestRatedMovie(reviews: reviews)
        stats.append(bestRated)

        return stats
    }

    private func generateGenreData(reviews: [Review]) -> [GenreStat] {
        let genres = reviews.flatMap { $0.movieStorage.genre }
        let genreCounts = genres.reduce(into: [:]) { counts, genre in
            counts[genre, default: 0] += 1
        }
        
        let maxCount = genreCounts.values.max() ?? 0
        
        return genreCounts.map { GenreStat(genre: $0.key, count: $0.value, isHighest: $0.value == maxCount) }
    }

    private func moviesWatchedThisMonth(reviews: [Review]) -> Int {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())

        return reviews.filter {
            let month = Calendar.current.component(.month, from: $0.watchDate)
            let year = Calendar.current.component(.year, from: $0.watchDate)
            return month == currentMonth && year == currentYear
        }.count
    }

    private func bestRatedMovie(reviews: [Review]) -> String {
        guard let bestRated = reviews.max(by: { $0.rating < $1.rating }) else {
            return "아직 평점을 매긴 영화가 없어요"
        }
        let stars = String(repeating: "★", count: bestRated.rating) + String(repeating: "☆", count: 5 - bestRated.rating)
        return "최고 평점 영화: \(bestRated.movieStorage.title) (\(stars))"
    }
}

// 장르별 통계를 위한 데이터 모델
struct GenreStat: Identifiable {
    let id = UUID()
    let genre: String
    let count: Int
    let isHighest: Bool
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
