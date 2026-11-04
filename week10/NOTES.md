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

## Level 5: errors that do not vanish

The unhandled version loses the error in the console:

```text
Unhandled Exception: Bad state: server rejected 6
```

The `setState` continuation error is:

```text
setState() called after dispose()
```

The final Save callback awaits the request, disables the button while it is in
flight, checks `context.mounted`, shows a SnackBar for `StateError`, and pops
only after success.

For countdown cleanup, leaving the StreamBuilder version mid-count stops its
stream automatically. Leaving the subscription version stops output because
`cancel()` runs in `dispose`; without that line the listener continues through
`tick 6`, `tick 5`, and eventually `tick 0` while the screen is gone.

Runtime screenshots were not captured because this environment has no Flutter
device available; no fake images were added.
