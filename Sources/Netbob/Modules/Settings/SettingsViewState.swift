//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine

class SettingsViewStateAbstract: ObservableObject {
    @Published var isEnabled = true
    @Published var contentTypes: [ContentTypeSetting] = []
    @Published var actionSheetState: ActionSheetState?
    @Published var blacklistedHosts: [String] = []
    @Published var maxItems: Int?  = Netbob.shared.maxListItems

    func handleClearAction() {}
}

class SettingsViewState: SettingsViewStateAbstract {
    private let httpConnectionRepository: HTTPConnectionRepositoryProtocol

    private var subscriptions = Set<AnyCancellable>()

    init(
        isEnabled: Bool = Netbob.shared.isStarted,
        allowedContentTypes: [HTTPContentType] = Netbob.shared.allowedContentTypes,
        blacklistedHosts: [String] = Netbob.shared.blacklistedHosts,
        httpConnectionRepository: HTTPConnectionRepositoryProtocol = HTTPConnectionRepository.shared
    ) {
        self.httpConnectionRepository = httpConnectionRepository

        super.init()

        self.blacklistedHosts = blacklistedHosts
        self.isEnabled = isEnabled

        contentTypes = HTTPContentType.allCases.map { contentType in
            ContentTypeSetting(
                name: contentType.toString,
                isEnabled: allowedContentTypes.contains(contentType)
            )
        }

        configureSubscriptions()
    }

    override func handleClearAction() {
        actionSheetState = .init(
            title: "Clear session?",
            message: nil,
            actions: [
                .default(text: "Yes") { [httpConnectionRepository] in
                    httpConnectionRepository.clear()
                },
                .default(text: "No") {}
            ]
        )
    }

    private func configureSubscriptions() {
        $isEnabled
            .sink { isEnabled in
                if isEnabled {
                    Netbob.shared.start()
                } else {
                    Netbob.shared.stop()
                }
            }
            .store(in: &subscriptions)

        $contentTypes
            .sink { [httpConnectionRepository] settings in
                let contentTypes = HTTPContentType.allCases.filter { contentType in
                    settings.contains { $0.name == contentType.toString && $0.isEnabled }
                }
                httpConnectionRepository.allowedContentTypes.send(contentTypes)
            }
            .store(in: &subscriptions)
    }
}

struct ContentTypeSetting: Identifiable, Equatable {
    let name: String
    var isEnabled: Bool

    var id: String { name }
}

private extension HTTPContentType {
    var toString: String {
        switch self {
        case .html:
            return "HTML"
        case .image:
            return "Image"
        case .json:
            return "JSON"
        case .unknown:
            return "unknown"
        case .xml:
            return "XML"
        }
    }
}
