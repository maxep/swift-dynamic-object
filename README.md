# DynamicObject

Dynamic-Typed Object in Swift

## Usage

```swift
import DynamicObject

let data = """
{
    "users": [
        { "username": "Tester 1" },
        { "username": "Tester 2" }
    ]
}
""".data(using: .utf8)!

let decoder = JSONDecoder()
let object = try decoder.decode(Object.self, from: data)
print(object.users[1].username) // Tester 2
```