
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    header
                    actionButtons
                    recentSwings
                }
                .padding()
            }
            .navigationTitle("SwingFix")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.golf")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("AI Golf Swing Coach")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Record or import your swing and get focused, personalized feedback.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 24)
    }

    private var actionButtons: some View {
        VStack(spacing: 14) {
            NavigationLink {
                PlaceholderView(title: "Record Swing")
            } label: {
                ActionButton(
                    title: "Record Swing",
                    systemImage: "video.fill",
                    isPrimary: true
                )
            }

            NavigationLink {
                PlaceholderView(title: "Import Video")
            } label: {
                ActionButton(
                    title: "Import Video",
                    systemImage: "square.and.arrow.down",
                    isPrimary: false
                )
            }
        }
    }

    private var recentSwings: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent Swings")
                .font(.title3)
                .fontWeight(.semibold)

            ContentUnavailableView(
                "No Swings Yet",
                systemImage: "figure.golf",
                description: Text("Your analyzed swings will appear here.")
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct ActionButton: View {
    let title: String
    let systemImage: String
    let isPrimary: Bool

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(isPrimary ? .white : .primary)
            .background(isPrimary ? Color.green : Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct PlaceholderView: View {
    let title: String

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: "hammer",
            description: Text("This feature is coming next.")
        )
        .navigationTitle(title)
    }
}

#Preview {
    ContentView()
}
