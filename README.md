# ti84p-cellular-automata

A TI84+ assembly program that explores 1-dimensional cellular automata

## Description
This project builds builds a TI-84+ assembly program called `CA`, which demos all 256 []()

## Building
This project uses [Brass 3](https://github.com/benryves/Brass3) as its assembler, using Wine on Linux. The output is directed to the `E:\` drive in Wine, which must 
be symlinked to the `build/` directory in the project. Additionally, the working directory for the Brass executable must bee the `src/` directory of the project.

## Running
The program has been tested using the [TilEm 2](http://lpg.ticalc.org/prj_tilem/) emulator, which is the most Linux-compatible TI-84+ emulator available at the moment.
The built .8xp can be loaded into any TI-84+ emulator and run that way, or it can be uploaded to a physical device.

## Note
The TI-84+ emulator .rom image is not available freely online, as it is proprietary. Users are recommended to obtain a rom through legitimate means.
