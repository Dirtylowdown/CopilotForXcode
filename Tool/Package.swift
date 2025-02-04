 void
end
close
delete











































            dependencies: [
                "UserDefaultsObserver",
                "SuggestionBasic",
                "Logger",
                "Preferences",
                "XcodeInspector",
            ]
        ),

        .target(
            name: "WorkspaceSuggestionService",
            dependencies: [
                "Workspace",
                "SuggestionProvider",
                "XPCShared",
                "BuiltinExtension",
                "GitHubCopilotService",
            ]
        ),

        .testTarget(
            name: "WorkspaceSuggestionServiceTests",
            dependencies: [
                "ConversationServiceProvider",
                "WorkspaceSuggestionService"
            ]
        ),

        // MARK: - Services

        .target(name: "Status"),

        .target(name: "SuggestionProvider", dependencies: [
            "SuggestionBasic",
            "UserDefaultsObserver",
            "Preferences",
            "Logger",
            .product(name: "CopilotForXcodeKit", package: "CopilotForXcodeKit"),
        ]),
        .testTarget(name: "SuggestionProviderTests", dependencies: ["SuggestionProvider"]),
        
        .target(name: "ConversationServiceProvider", dependencies: [
            .product(name: "CopilotForXcodeKit", package: "CopilotForXcodeKit"),
        ]),


        // MARK: - GitHub Copilot

        .target(
            name: "GitHubCopilotService",
            dependencies: [
                "LanguageClient",
                "SuggestionBasic",
                "Logger",
                "Preferences",
                "Terminal",
                "BuiltinExtension",
                "ConversationServiceProvider",
                "Status",
                .product(name: "LanguageServerProtocol", package: "LanguageServerProtocol"),
                .product(name: "CopilotForXcodeKit", package: "CopilotForXcodeKit"),
            ]
        ),
        .testTarget(
            name: "GitHubCopilotServiceTests",
            dependencies: ["GitHubCopilotService",
                           "ConversationServiceProvider"]
        ),

        // MARK: - ChatAPI

        .target(
            name: "ChatAPIService",
            dependencies: [
                "Logger",
                "Preferences",
                .product(name: "JSONRPC", package: "JSONRPC"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),

        // MARK: - UI

        .target(
            name: "ChatTab",
            dependencies: [.product(
                name: "ComposableArchitecture",
                package: "swift-composable-architecture"
            )]
        ),
    ]
)

