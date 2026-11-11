# Practice 11 notes

## Level 1: Postman first

The API used is `https://jsonplaceholder.typicode.com`.

| Request | Result |
| --- | --- |
| `GET /users` | HTTP 200, `Content-Type: application/json`, list of 10 users |
| `GET /users/1` | HTTP 200, one user object |
| `GET /users/999` | HTTP 404, empty JSON object `{}` |
| `GET /users?id=3` | HTTP 200, list containing one user |
| `POST /users` | HTTP 201, response contains the submitted fields and server id `11` |

### User fields

| JSON field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| `id` | number | `int` | no |
| `name` | string | `String` | no |
| `username` | string | `String` | no |
| `email` | string | `String` | no |
| `address` | object | `Address` | no |
| `phone` | string | `String` | no |
| `website` | string | `String?` | yes in the model |
| `company` | object | record | no |

### Address fields

| JSON field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| `street` | string | `String` | no |
| `suite` | string | `String` | no |
| `city` | string | `String` | no |
| `zipcode` | string | `String` | no |
| `geo` | object | `Geo` | no |

### Geo fields

| JSON field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| `lat` | string | `double` | no |
| `lng` | string | `double` | no |

### Company fields

| JSON field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| `name` | string | `String` | no |
| `catchPhrase` | string | `String` | no |
| `bs` | string | not used | no |

The response is a list for `/users` and `/users?id=3`, but an object for
`/users/1`. The nested objects are `address` and `company`; `address.geo` is
nested twice. `lat` and `lng` are strings in the wire format even though the
model will store them as `double`.

## Level 2: models

`Geo`, `Address`, and `User` use `const` constructors, strict casts, nested
`fromJson` calls, and matching `toJson` maps. Coordinates are parsed from the
server's strings with `double.parse`; `website` is the only nullable field in
the model. `User` equality is based on `id`.

## Level 3: repository

`ApiClient` is the only low-level HTTP client. It injects `http.Client`, uses
`Uri.https`, adds a ten-second timeout, maps socket/timeout failures to
`NoConnectionException`, checks status codes before decoding, and converts
invalid JSON to `BadResponseException`.

`UserRepository` exposes only `User` and `List<User>` methods: `getAll`,
`getById`, and `create`. Screens never receive `http.Response` or status codes.
