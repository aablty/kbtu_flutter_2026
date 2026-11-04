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
