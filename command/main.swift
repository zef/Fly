import Foundation

func run(command: String) {
    print("Executing command \"\(command)\":")
    let task = NSTask()
    task.launchPath = "/bin/sh"
    task.arguments = ["-c", command]

    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = NSString(data: data, encoding: NSUTF8StringEncoding) {
        print(output)
    }

    task.waitUntilExit()
    // let status = task.terminationStatus
    // print(status)
}

enum Command: String {
    case server
    case help

    func execute() {
        switch self {
        case .server:
            run("docker rm swift")
            run("docker build -t swift ./")
            run("docker run -p 80:8080 --name swift -it swift /bin/bash")
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





