# Building firmware targets for Demon Debugger

Firstly, if you're really lucky, you might find your target code in the bin directory.

If not, head to the src directory

The code is split into subdirectories as follows:

    * core - assembly routines for all CPUs which define the core of Demon Debugger
    * io - assembly routines for interfacing to your target via romio, or tethered mode
    * templates - configuration files (with code snippets) defining how to build a rom image
    * targets - configuration files for each supported target
    * tools - tools needed to build the firmware, but especially ddmake, which does it all

Each target file references a single template file.  This helps a lot, because similar targets share a single template.

For example, if you have a 2K Z80 target (at 0x0000), or a 2K 6502 target (at 0xF800), all the work is done for you.
You will see template files for building either of these, and the z80ref and 6502ref targets use them.

There is also a template for building Z80 cartridge images, which currently works with the Astrocade and Colecovision.

Finally, there are examples of older targets/templates which use the tethered mode of communication.

To build an image, go into the targets directory (where the target .toml files are) and invoke the ddmake.py program with the target (basename) as an argument.  (You will need a python3 environment for now.)  ddmake scans the target and referenced template files, and builds an asm in the corresponding bin/<target>/<target>.asm.  Then, it invokes the assembler, linker, and output converter programs.  If all goes well, you will have:

    * <target>.asm - abbreviated assembly program
    * <target>.bin - binary image
    * <target>.hex - hex file suitable for automatic upload to the Demon Debugger hardware
    * <target>.rst - a nice, absolute listing file of the build image, generated by the linker
