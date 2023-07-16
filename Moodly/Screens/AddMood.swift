import SwiftUI
import Combine
import SwiftUISnackbar

class AddMoodViewModel: ObservableObject {
    let moodsRepository: MoodsRepositoryProtocol
    var snackbarStore: SnackbarStore
    @Published var selectedMood: Mood?
    @Published var notes: String = ""
    @Binding var modalOpen: Bool
    @Binding var moods: [MoodEntry]

    private var cancelBag = Set<AnyCancellable>()

    init(
        snackbarStore: SnackbarStore,
        moodsRepository: MoodsRepositoryProtocol,
        moods: Binding<[MoodEntry]>,
        modalOpen: Binding<Bool>
    ) {
        self.snackbarStore = snackbarStore
        self.moodsRepository = moodsRepository
        self._moods = moods
        self._modalOpen = modalOpen
    }

    var canSave: Bool {
        self.selectedMood != nil
    }
    
    func closeModal() {
        self.modalOpen = false
    }

    func saveEntry() {
        guard let selectedMood else {
            return
        }
        
        let entry = MoodEntry(
            mood: selectedMood,
            notes: self.notes,
            createdAt: Date()
        )
        
        self.moodsRepository.saveMood(entry: entry)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(_) = completion {
                        self.snackbarStore.display(
                            title: "Error creating Mood. Please try again.",
                            text: nil,
                            style: .error
                        )
                    }
                },
                receiveValue: {
                    // entry was successfully added
                    self.snackbarStore.display(title: "Mood added!")
                    self.closeModal()
                }
            )
            .store(in: &cancelBag)
    }

    func selectMood(_ mood: Mood) {
        self.selectedMood = mood
    }
}

struct AddMood: View {
    @StateObject var viewModel: AddMoodViewModel

    var body: some View {
        SnackbarNavigatior {
            addMoodForm
                .navigationTitle("Add Mood")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: viewModel.closeModal) {
                            Text("Close")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: viewModel.saveEntry) {
                            Text("Save")
                                .bold()
                        }
                        .disabled(!viewModel.canSave)
                    }
                }
        }
        .environmentObject(viewModel.snackbarStore)
    }

    private var addMoodForm: some View {
        List {
            Section("How are you feeling?") {
                ForEach(Mood.allCases, id: \.self) { mood in
                    moodRow(mood)
                        .listRowBackground(backgroundForRow(mood: mood))
                }
            }
            
            Section("Notes") {
                TextField("Notes", text: $viewModel.notes)
            }
        }
    }

    private func backgroundForRow(mood: Mood) -> some View {
        if viewModel.selectedMood == mood {
            return Color(uiColor: .systemGray3)
        } else {
            return Color(uiColor: .tertiarySystemBackground)
        }
    }

    private func moodRow(_ mood: Mood) -> some View {
        Button(action: { viewModel.selectMood(mood) }) {
            HStack {
                Text(mood.emojii)
                Text(mood.rawValue)
            }
        }
    }
}

struct AddMood_Previews: PreviewProvider {
    static var previews: some View {
        AddMood(viewModel: .init(
            snackbarStore: SnackbarStore(),
            moodsRepository: FakeMoodsRepository(),
            moods: .constant([]),
            modalOpen: .constant(true)
        ))
    }
}
