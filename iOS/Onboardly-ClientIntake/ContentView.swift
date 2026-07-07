import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var editingItem: ClientTask?
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.items) { item in
                        Button {
                            editingItem = item
                        } label: {
                            row(for: item)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Theme.background)
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("Onboardly - Client Intake")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore(isPro: purchases.isPro) {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Theme.accent)
                    }
                    .accessibilityIdentifier("button.add")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Theme.ink)
                    }
                    .accessibilityIdentifier("button.settings")
                }
            }
            .sheet(isPresented: $showingAdd) {
                ItemEditorView(mode: .add) { newItem in
                    _ = store.add(newItem, isPro: purchases.isPro)
                }
            }
            .sheet(item: $editingItem) { item in
                ItemEditorView(mode: .edit(item)) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }

    @ViewBuilder
    func row(for item: ClientTask) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.ink)
            Text("\(String(describing: item.step))  \u{00B7}  \(String(describing: item.status))")
                .font(.caption)
                .foregroundStyle(Theme.ink.opacity(0.65))
        }
        .padding(.vertical, 4)
    }
}

enum EditorMode: Equatable {
    case add
    case edit(ClientTask)
}

struct ItemEditorView: View {
    @Environment(\.dismiss) var dismiss
    let mode: EditorMode
    let onSave: (ClientTask) -> Void

    @State private var draft: ClientTask

    init(mode: EditorMode, onSave: @escaping (ClientTask) -> Void) {
        self.mode = mode
        self.onSave = onSave
        switch mode {
        case .add:
            _draft = State(initialValue: ClientTask(title: ""))
        case .edit(let item):
            _draft = State(initialValue: item)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("ClientTask") {
                    TextField("Name", text: $draft.title)
                        .accessibilityIdentifier("field.title")
                    TextField("Step", text: $draft.step)
                        .accessibilityIdentifier("field.step")
                    Picker("Status", selection: $draft.status) {
                        ForEach(["Not Started", "In Progress", "Complete"], id: \.self) { Text($0).tag($0) }
                    }
                    TextField("Notes", text: $draft.notes, axis: .vertical)
                        .accessibilityIdentifier("field.notes")
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(mode == .add ? "Add ClientTask" : "Edit ClientTask")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("button.cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(draft)
                        dismiss()
                    }
                    .accessibilityIdentifier("button.save")
                    .disabled(draft.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#if canImport(UIKit)
import UIKit
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
