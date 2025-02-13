revoke
stop
end
delete
void






































let serviceIdentifier = bundleIdentifierBase + ".CommunicationBridge"
let appDelegate = AppDelegate()
let delegate = ServiceDelegate()
let listener = NSXPCListener(machServiceName: serviceIdentifier)
listener.delegate = delegate
listener.resume()
let app = NSApplication.shared
app.delegate = appDelegate
Logger.communicationBridge.info("Communication bridge started")
app.run()

