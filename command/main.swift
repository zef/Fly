import Foundation

var tasksToKill = [NSTask]()

// not super happy with a lot of stuff here, especially tasksToKill and the longRunning / wait options.
func run(commands: String..., message: String? = nil, longRunning: Bool = false, wait: Bool = true) {

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

    if let message = message {
        print(message)
    }

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
               NSNotificationCenter.defaultCenter().removeObserver(observer)
            }
        }
    } else {
        if wait {
            printFileData(fileHandle)
            task.waitUntilExit()
        } else {
            tasksToKill.append(task)
        }
    }

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
            run("swift", "build", message: "Building...", longRunning: true)
            run(".build/debug/Fly", wait: false)
            run("tail", "-fn0", "log/development.log", longRunning: true)
        case .docker:
            run("docker rm swift")
            run("docker", "build", "-t", "swift", "./", message: "Building Docker container...")
            run("docker", "run", "-p", "80:8080", "--name", "swift", "-it", "swift", "/bin/bash")
        case .clean:
            run("swift", "build", "--clean", message: "Cleaning...")
        case .help:
            print("Help.")
            print("I should really find a nice command line lib to help me generate this...")
        }
    }

}

signal(SIGINT) { signal in
    print("\n🛬 ")
    for task in tasksToKill {
        task.terminate()
    }
    exit(0)
}

let arguments = Process.arguments[1..<Process.arguments.count]
let commandString = arguments.first ?? "help"

if let command = Command(rawValue: commandString) {
    command.execute()
} else {
    Command.help.execute()
}

CFRunLoopRun()

