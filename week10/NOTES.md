# Practice 10 notes

## Level 1: event order

Before running the experiment, the expected order was:

```text
A
C
first frame of the app
B
6 students
```

The actual order was the same: synchronous `main()` output first, the app
frame next, then both two-second callbacks. `B` was registered first, so it
ran before the completed fake request.

## Level 2: four states by hand

`StudentsScreen` stores loading, error, empty, and data state explicitly. The
two `mounted` guards protect both continuations after `fetchStudents()`.

## Level 3: FutureBuilder

`StudentsFutureScreen` stores its request in `_future`; changing the compact
switch only changes tile density and does not create another request. `_retry`
is the only method that replaces the stored future.

## Level 4: countdown

The StreamBuilder version is cancelled by the framework when it leaves the
tree. The subscription version explicitly calls `cancel()` in `dispose`, so
leaving it mid-count stops the tick output and prevents updates to a dead
State.
