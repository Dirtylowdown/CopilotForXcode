revoke
end 
delete
void
close
end
























































        )

        let xcodeInspectorDebugMenu = NSMenu(title: "Xcode Inspector Debug")
        xcodeInspectorDebugMenu.identifier = xcodeInspectorDebugMenuIdentifier
        xcodeInspectorDebug.submenu = xcodeInspectorDebugMenu
        xcodeInspectorDebug.isHidden = false

        statusMenuItem = NSMenuItem(
            title: "",
            action: #selector(openStatusLink),
            keyEquivalent: ""
        )
        statusMenuItem.isHidden = true

        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quit),
            keyEquivalent: ""
        )
        quitItem.target = self

        let toggleCompletions = NSMenuItem(
            title: "Enable/Disable Completions",
            action: #selector(toggleCompletionsEnabled),
            keyEquivalent: ""
        )
        toggleCompletions.identifier = toggleCompletionsMenuItemIdentifier;

        let toggleIgnoreLanguage = NSMenuItem(
            title: "No Active Document",
            action: nil,
            keyEquivalent: ""
        )
        toggleIgnoreLanguage.identifier = toggleIgnoreLanguageMenuItemIdentifier;

        authMenuItem = NSMenuItem(
            title: "Copilot Connection: Checking...",
            action: #selector(openCopilotForXcode),
            keyEquivalent: ""
        )

        let openDocs = NSMenuItem(
            title: "View Copilot Documentation...",
            action: #selector(openCopilotDocs),
            keyEquivalent: ""
        )

        let openForum = NSMenuItem(
            title: "View Copilot Feedback Forum...",
            action: #selector(openCopilotForum),
            keyEquivalent: ""
        )

        statusBarMenu.addItem(openCopilotForXcodeItem)
        statusBarMenu.addItem(.separator())
        statusBarMenu.addItem(checkForUpdate)
        statusBarMenu.addItem(toggleCompletions)
        statusBarMenu.addItem(toggleIgnoreLanguage)
        statusBarMenu.addItem(.separator())
        statusBarMenu.addItem(authMenuItem)
        statusBarMenu.addItem(statusMenuItem)
        statusBarMenu.addItem(.separator())
        statusBarMenu.addItem(openDocs)
        statusBarMenu.addItem(openForum)
        statusBarMenu.addItem(.separator())
        statusBarMenu.addItem(xcodeInspectorDebug)
        statusBarMenu.addItem(quitItem)

        statusBarMenu.delegate = self
        xcodeInspectorDebugMenu.delegate = self
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        switch menu.identifier {
        case statusBarMenuIdentifier:
            if let xcodeInspectorDebug = menu.items.first(where: { item in
                item.submenu?.identifier == xcodeInspectorDebugMenuIdentifier
            }) {
                xcodeInspectorDebug.isHidden = !UserDefaults.shared
                    .value(for: \.enableXcodeInspectorDebugMenu)
            }

            if let toggleCompletions = menu.items.first(where: { item in
                item.identifier == toggleCompletionsMenuItemIdentifier
            }) {
                toggleCompletions.title = "\(UserDefaults.shared.value(for: \.realtimeSuggestionToggle) ? "Disable" : "Enable") Completions"
            }

            if let toggleLanguage = menu.items.first(where: { item in
                item.identifier == toggleIgnoreLanguageMenuItemIdentifier
            }) {
                if let lang = DisabledLanguageList.shared.activeDocumentLanguage {
                    toggleLanguage.title = "\(DisabledLanguageList.shared.isEnabled(lang) ? "Disable" : "Enable") Completions for \(lang.rawValue)"
                    toggleLanguage.action = #selector(toggleIgnoreLanguage)
                } else {
                    toggleLanguage.title = "No Active Document"
                    toggleLanguage.action = nil
                }
            }

        case xcodeInspectorDebugMenuIdentifier:
            let inspector = XcodeInspector.shared
            menu.items.removeAll()
            menu.items
                .append(.text("Active Project: \(inspector.activeProjectRootURL?.path ?? "N/A")"))
            menu.items
                .append(.text("Active Workspace: \(inspector.activeWorkspaceURL?.path ?? "N/A")"))
            menu.items
                .append(.text("Active Document: \(inspector.activeDocumentURL?.path ?? "N/A")"))

            if let focusedWindow = inspector.focusedWindow {
                menu.items.append(.text(
                    "Active Window: \(focusedWindow.uiElement.identifier)"
                ))
            } else {
                menu.items.append(.text("Active Window: N/A"))
            }

            if let focusedElement = inspector.focusedElement {
                menu.items.append(.text(
                    "Focused Element: \(focusedElement.description)"
                ))
            } else {
                menu.items.append(.text("Focused Element: N/A"))
            }

            if let sourceEditor = inspector.focusedEditor {
                let label = sourceEditor.element.description
                menu.items
                    .append(.text("Active Source Editor: \(label.isEmpty ? "Unknown" : label)"))
            } else {
                menu.items.append(.text("Active Source Editor: N/A"))
            }

            menu.items.append(.separator())

            for xcode in inspector.xcodes {
                let item = NSMenuItem(
                    title: "Xcode \(xcode.processIdentifier)",
                    action: nil,
                    keyEquivalent: ""
                )
                menu.addItem(item)
                let xcodeMenu = NSMenu()
                item.submenu = xcodeMenu
                xcodeMenu.items.append(.text("Is Active: \(xcode.isActive)"))
                xcodeMenu.items
                    .append(.text("Active Project: \(xcode.projectRootURL?.path ?? "N/A")"))
                xcodeMenu.items
                    .append(.text("Active Workspace: \(xcode.workspaceURL?.path ?? "N/A")"))
                xcodeMenu.items
                    .append(.text("Active Document: \(xcode.documentURL?.path ?? "N/A")"))

                for (key, workspace) in xcode.realtimeWorkspaces {
                    let workspaceItem = NSMenuItem(
                        title: "Workspace \(key)",
                        action: nil,
                        keyEquivalent: ""
                    )
                    xcodeMenu.items.append(workspaceItem)
                    let workspaceMenu = NSMenu()
                    workspaceItem.submenu = workspaceMenu
                    let tabsItem = NSMenuItem(
                        title: "Tabs",
                        action: nil,
                        keyEquivalent: ""
                    )
                    workspaceMenu.addItem(tabsItem)
                    let tabsMenu = NSMenu()
                    tabsItem.submenu = tabsMenu
                    for tab in workspace.tabs {
                        tabsMenu.addItem(.text(tab))
                    }
                }
            }

            menu.items.append(.separator())

            menu.items.append(NSMenuItem(
                title: "Restart Xcode Inspector",
                action: #selector(restartXcodeInspector),
                keyEquivalent: ""
            ))

        default:
            break
        }
    }
}

import XPCShared

private extension AppDelegate {
    @objc func restartXcodeInspector() {
        Task {
            await XcodeInspector.shared.restart(cleanUp: true)
        }
    }

    @objc func toggleCompletionsEnabled() {
        Task {
            let initialSetting = UserDefaults.shared.value(for: \.realtimeSuggestionToggle)
            do {
                let service = getXPCExtensionService()
                try await service.toggleRealtimeSuggestion()
            } catch {
                Logger.service.error("Failed to toggle completions enabled via XPC: \(error)")
                UserDefaults.shared.set(!initialSetting, for: \.realtimeSuggestionToggle)
            }
        }
    }

    @objc func toggleIgnoreLanguage() {
        guard let lang = DisabledLanguageList.shared.activeDocumentLanguage else { return }

        if DisabledLanguageList.shared.isEnabled(lang) {
            DisabledLanguageList.shared.disable(lang)
        } else {
            DisabledLanguageList.shared.enable(lang)
        }
    }

    @objc func openCopilotDocs() {
        if let urlString = Bundle.main.object(forInfoDictionaryKey: "COPILOT_DOCS_URL") as? String {
            if let url = URL(string: urlString) {
                NSWorkspace.shared.open(url)
            }
        }
    }

    @objc func openCopilotForum() {
        if let urlString = Bundle.main.object(forInfoDictionaryKey: "COPILOT_FORUM_URL") as? String {
            if let url = URL(string: urlString) {
                NSWorkspace.shared.open(url)
            }
        }
    }

    @objc func openStatusLink() {
        Task {
            let status = await Status.shared.getStatus()
            if let s = status.url, let url = URL(string: s) {
                NSWorkspace.shared.open(url)
            }
        }
    }
}

private extension NSMenuItem {
    static func text(_ text: String) -> NSMenuItem {
        let item = NSMenuItem(
            title: text,
            action: nil,
            keyEquivalent: ""
        )
        item.isEnabled = false
        return item
    }
}

