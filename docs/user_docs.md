# User documentation

Simple Java pretty printer **JPrettyPrinter** corrects layout and indentation of
Java code.

## How to use

There are two main ways how to control the program. One is via the interactive ghci environment and the second one is by using the compiled program (the second one is more user-friendly and recommended). 

### Interactive environment

Firstly, the project is derided into several files therefore it is necessary to enable transitive imports via the command `:set -isrc` which enables to use files in the src directory. 

Afterward user can configurate the program via the arguments of the program, unfortunately this is not possible at the time of the calling the main function, it is necessary to set arguments via the environment variable as follows `:set args [arguments]`. For more detailed instructions about arguments look below. 

After setting up the environment variables the only things needed are loading the code via command `:l Main.hs`, with the preconditions that the user started ghci in the root directory of the git repository. After loading the user can run the program only by executing command main, which calls the main function. 

### Compiling

Firstly, move into the root directory of the git repository, afterward the project can be compiled via the following command `ghc -isrc Main.hs -o JPrettyPrinter`. After compiling you should see an executable file JPrettyPrinter in the directory.  

Now you can run the program via the executable file and control it via the cli arguments.

### How to control

Main and the only way how to control the program are flags/command line arguments. 

```commandline
-> ./JPrettyPrinter --help

Arguments:
	-f, --file		path to the directory/target file
	-o, --overwrite		whether the corrected files should overwrite the existing files
	-i, --indentation	number of spaces to use for indentation
	-h, --help		shows help menu
```

First option is `-f` or `--file` which is mandatory argument which denotes the target file or directory which will be processed. If file is provided then only that file will be used (even though it is not necessary needs to be java file), if directory is provided then will be processed all java files in this directory and subdirectories. 

* `./JPrettyPrinter -f inputs`
* `./JPrettyPrinter --file inputs/for.java`

Second option `-o` or `--overwrite` denotes whether the files should be overwritten or if should the corrected version be stored in the output directory. If the flag is not present then the default value is set to not overwrite the files. (If the overwrite mode is not enabled, then directory structure of the project is flattened, therefore all files are stored in the output directory.)


* `./JPrettyPrinter -f inputs --overwrite`
* `./JPrettyPrinter -f inputs -o`

Next option is `-i` or `--indentation` which denotes the value of how much wide should be one indentation level. If this option is not present then the default value is set to 4 spaces. 

* `./JPrettyPrinter -f inputs -i 8`
* `./JPrettyPrinter -f inputs --indentation 4`

Last option is `-h` or `--help` which shows help menu with quick overview of the cli options. In this case the file option is not mandatory because the program shows the menu and exits itself.

* `./JPrettyPrinter -h`
* `./JPrettyPrinter --help`

## Testing data

In the `inputs` directory can be found several Java files testing various aspects of the language and more importantly the files contains very badly formated code which can be used for testing how the JPrettyPrinter corrects these mistakes. 

## About the program

Firstly, here is a disclaimer, the JPrettyPrinter only corrects the formating of the Java code and assumes that the code is correct, therefore does not contain any syntax error etc. Furthermore, JPrettyPrinter does support only a subset of Java, especiality does not support code with comments, try block (try with resources) and streams.

### How does formating works

After loading content of the file the program converts the content into "normal form", eliminates ends of lines, unnecessary whitespaces etc. Only after converting to the normal form starts parsing. 

Afterward from the normal form is created a tree graph, be more precise several tree graphs, if the code in one file contains several top level elements (classes, package names etc.). In the trees loosely speaking one node represents one line of final code. A node has children if and only if it is header/start for some inner block such as method, inner class, loop etc. 

After creating the tree can the program create a new text representation of the code. It uses the tree structure to denote the structure of the code, it maintains the same order of instructions as in the input code and uses the depth of the tree to deduce the correct indentation. 

After creating text representation this new code is stored in the new file or overwrites old content based on the users preferences. 