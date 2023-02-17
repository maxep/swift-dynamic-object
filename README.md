# DynamicObject

Dynamic-Typed Object in Swift

## Usage

### Decoding

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
print(object.users[1].username) 
// Prints 'Tester 2'
```

### Encoding

```swift
let object = Object {
    $0.users = [
        Object { $0.username = "Tester 1" },
        Object { $0.username = "Tester 2" }
    ]
}

let encoder = JSONEncoder()
let data = try encoder.encode(object)
print(String(data: data, encoding: .utf8)!)
// Prints '{"users":[{"username":"Tester 1"},{"username":"Tester 2"}]}'
```
