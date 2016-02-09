import Foundation

func run(commands: String...) {
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

   fileHandle.waitForDataInBackgroundAndNotify()

   var observer: NSObjectProtocol!
   observer = NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification, object: fileHandle, queue: nil) {  notification -> Void in
       let data = fileHandle.availableData
       if data.length > 0 {
           if let output = NSString(data: data, encoding: NSUTF8StringEncoding) {
               print(output, terminator: "")
           }
           fileHandle.waitForDataInBackgroundAndNotify()
       } else {
           // print("Landed", observer)
           NSNotificationCenter.defaultCenter().removeObserver(observer)
       }
   }

    // task.waitUntilExit()

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
            run(".build/debug/Fly")
        case .docker:
            run("docker rm swift")
            run("docker build -t swift ./")
            run("docker run -p 80:8080 --name swift -it swift /bin/bash")
        case .clean:
            run("swift build --clean")
        case .help:
            print("help")
        }
    }

}

let arguments = Process.arguments[1..<Process.arguments.count]
// print(arguments)
let commandString = arguments.first ?? "help"

if let command = Command(rawValue: commandString) {
    command.execute()
} else {
    Command.help.execute()
}

CFRunLoopRun()


