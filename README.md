# Fly: A Swift Web Framework

This is the beginning of some ideas for a Swift web framework intended to be run on linux.

Adapters for the server component are implemented for [http4swift](https://github.com/takebayashi/http4swift) and [Zewo's
Epoch](https://github.com/Zewo/Epoch). Epoch only compiles on linux, so it is currently disabled.


## Goals

- [Protocol-Oriented](https://developer.apple.com/videos/play/wwdc2015-408/). Components of Fly
  should be connected via protocols so that they can are useful outside of Fly, or can be replaced
  entirely by other libraries.
- Compiler-focused. Fly attempts to lean heavily on the type system to reduce bugs and potential for
  errors by pushing as much as possible to the compiler. This means:
    - Avoiding throwing out type data by using `Any` and `AnyObject`
    - Reducing the use of strings in subscripts for fetching data
- Concise, but not at the expense of clarity and flexibility.


## Ideas

- Localization
  - Use `enum` with associated values for localization of strings that require arguments
  - Provide a tool to help devs create localization files based on the added enum cases?
- A model layer that enables code sharing between server and client apps. This would expose the same
  API to each type of app, but the implementation that is called would change based on the app
  configuration. Not sure this is a good idea, but interesting :)


