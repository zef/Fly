import Foundation

func run(commands: String..., longRunning: Bool = false, noWait: Bool = false) {
    func printFileData(fileHandle: NSFileHandle) -> Bool {
        let data = fileHandle.availableData
        if data.length > 0 {
            if let output = NSString(data: data, encoding: NSUTF8StringEncoding) {
               print(output, terminator: "")
            }
            return true
        } else {
            return false
        }
    }

    print("Executing command \"\(commands.joinWithSeparator(" "))\":")

    let task = NSTask()
    // task.launchPath = "/bin/sh"
    // task.arguments = ["-c", command]
    task.launchPath = "/usr/bin/env"
    task.arguments = commands


    let pipe = NSPipe()
    task.standardOutput = pipe

    task.launch()
    let fileHandle = pipe.fileHandleForReading

    if longRunning {
        fileHandle.waitForDataInBackgroundAndNotify()
        printFileData(fileHandle)

        var observer: NSObjectProtocol!
        observer = NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification, object: fileHandle, queue: nil) {  notification -> Void in
            if printFileData(fileHandle) {
                fileHandle.waitForDataInBackgroundAndNotify()
            } else {
               print("\nLanded", observer)
               NSNotificationCenter.defaultCenter().removeObserver(observer)
            }
        }
        CFRunLoopRun()
    } else {
        printFileData(fileHandle)
        if !noWait {
            task.waitUntilExit()
        }
    }

    print("end: \"\(commands.joinWithSeparator(" "))\"")

    // let status = task.terminationStatus
    // print(status)
}


enum Command: String {
    case server
    case docker
    case clean
    case help

    func execute() {
        switch self {
        case .server:
            run("swift", "build")
            // run(".build/debug/Fly", longRunning: true)
            run(".build/debug/Fly", noWait: true)
            run("tail", "-fn0", "log/development.log", longRunning: true)
        case .docker:
            run("docker rm swift")
            run("docker build -t swift ./")
            run("docker run -p 80:8080 --name swift -it swift /bin/bash")
        case .clean:
            run("swift", "build", "--clean")
        case .help:
            print("Help.")
            print("I should really find a nice command line lib to help me generate this...")
        }
    }

}

signal(SIGINT) { signal in
    print("So long...")
    exit(0)
}

let arguments = Process.arguments[1..<Process.arguments.count]
let commandString = arguments.first ?? "help"

if let command = Command(rawValue: commandString) {
    command.execute()
} else {
    Command.help.execute()
}


