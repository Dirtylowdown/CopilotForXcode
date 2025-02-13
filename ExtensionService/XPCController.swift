revoke
close
delete
stop
end

















































                } catch {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    #if DEBUG
                    // No log, but you should run CommunicationBridge, too.
                    #else
                    Logger.service
                        .error("Failed to connect to bridge: \(error.localizedDescription)")
                    #endif
                }
            }
        }
    }

    func connectionDidInvalidate() async {
        // ignore
    }

    func connectionDidInterrupt() async {
        createPingTask() // restart the ping task so that it can bring the bridge back immediately.
    }
}

