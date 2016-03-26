# Fly: A Swift Web Framework

This is the beginning of some ideas for a Swift web framework intended to be run on linux.

Adapters for the server component are implemented for [http4swift](https://github.com/takebayashi/http4swift) and [Zewo's
Epoch](https://github.com/Zewo/Epoch). Epoch only compiles on linux, so it is currently disabled.

## What makes Fly special?

- Application code is decoupled from server implementation.
  This is also true of other areas in Fly, but at this point in the evolution of
  Swift web frameworks, this is especially important for the HTTP server layer.
- The Swift compiler is strongly relied upon for as much as possible. Every use of `String` in the framework
  introduces the potential for bugs that cannot be caught by the compiler.
- Router is built on generics, making it usable in many contexts. The `Request` and `Response` objects
  can be any type, so in the context of an iOS app for deep linking into the app,
  you might use a `String` as the Request, and a `Bool` as the response, simply indicating success or failure.
- Build HTML views directly in Swift with [SwifTML](https://github.com/zef/SwifTML). We'll see if this is a good idea long-term, but I find this preferable to
  existing Swift templating solutions like mustache.
- Comes with a `fly` command line tool that assists in development, similar to `rails`.


## Goals

- [Protocol-Oriented](https://developer.apple.com/videos/play/wwdc2015-408/). Components of Fly
  should be connected via protocols so that they can are useful outside of Fly, or can be replaced
  entirely by other libraries.
- Concise, but not at the expense of clarity, flexibility, or advantageous use of the type system.
- Compiler-focused. Fly attempts to lean heavily on the type system to reduce bugs and potential for
  errors by pushing as much as possible to the compiler. This means:
    - Avoiding throwing out type data by using `Any` and `AnyObject`
    - Reducing the use of strings in subscripts for fetching data.

**Each use of `String` in a framework or your application increases the surface areas for bugs
that the compiler can't catch.**

## Component Libraries:

[SwifTML](https://github.com/zef/SwifTML)
[AirTrafficController](https://github.com/zef/AirTrafficController)
[HTTPStatus](https://github.com/zef/HTTPStatus)


## Ideas

- Localization
  - Use `enum` with associated values for localization of strings that require arguments
  - Provide a tool to help devs create localization files based on the added enum cases?
- A model layer that enables code sharing between server and client apps. This would expose the same
  API to each type of app, but the implementation that is called would change based on the app
  configuration. Not sure this is a good idea, but interesting :)


## Swift Version

`DEVELOPMENT-SNAPSHOT-2016-03-24-a`

