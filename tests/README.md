# Testing

A suite of unit tests is provided using [luaunit](https://luaunit.readthedocs.io). These tests
must be compiled and run either in the Playdate Simulator or on Playdate hardware. Follow
these steps to run the tests:

1. Compile the tests. You can do this from the top level `Acetate` directory using:
   `pdc -k tests tests/test.pdx`

2. Double-click the resulting `test.pdx` binary inside the `tests` folder to run it in the
   Playdate Simulator.

3. Open the console (`⌘⇧D`) to view test results. A sucess or failure message will also appear
   on the Playdate screen.

4. Optionally upload and run the binary to connected Playdate hardware (`⌘U`).
