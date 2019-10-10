# docgen

![GPLv3](https://img.shields.io/github/license/Sodaware/docgen.svg)
![GitHub release](https://img.shields.io/github/release/Sodaware/docgen.svg)


`docgen` is a tool for extracting information from BlitzMax source and exporting
it into another file format.

It is currently under *heavy development* and isn't 100% ready yet.


## Quick Links

Project Homepage:
: https://www.sodaware.net/docgen/

Source Code
: https://github.com/sodaware/docgen/


## Overview

`docgen` parses BlitzMax source files and creates a JSON file containing
types, functions, methods and other BlitzMax constructs. It can also extract
data from XML documentation tags.

It does not currently extract bbdoc tags. If you're looking to generate project
documentation from bbdoc, BlitzMax's built-in tools will be a better fit.

For example, the following BlitzMax:

```blitzmax
''' <summary>This is my function.</summary>
''' <return>The current time.</return>
Function doThis:String()
    Return CurrentTime()
End Function
```

Will be parsed into this:

```json
{
  "docgen": {
    "version": "0.1.0.0",
    "created_at": "09 Oct 2019 12:08:50"
  },
  "files": [
    {
      "name": "text.bmx",
      "last_modified": "2019-10-9 12:8:13",
      "globals": [],
      "constants": [],
      "types": [],
      "functions": [
        {
          "name": "doThis",
          "type": "String",
          "summary": "This is my function.",
          "description": "",
          "returnType": "String",
          "returnDescription": "The current time.",
          "seeAlso": "",
          "example": "",
          "line": 3,
          "column": 1
        }
      ]
    }
  ]
}
```


## Usage

`docgen` takes the following command line parameters.

  - `-i` or `--input`    -- The file or module name to parse.
  - `-o` or `--output`   -- The file to save information to.
  - `-m` or `--mod-path` -- The full path to BlitzMax's mod directory. Only
                            required when passing a mod name in `--input`.

For example:

  - `docgen -i=file.bmx -o=data.json` will parse `file.bmx` and save the
    json data as `data.json`.
  - `docgen -i=brl.basic -o=brl_basic.json -m=/path/to/mods` will
    extract data from the `brl.basic` module.

`docgen` will automatically parse any included or imported files in the input
file.


## Building

### Prerequisites

  - BlitzMax
  - Modules required (not including built-in brl.mod and pub.mod):
    - [sodaware.mod](https://github.com/sodaware/sodaware.mod)
      - sodaware.blitzmax\_array
      - sodaware.console\_color
      - sodaware.console\_commandline
      - sodaware.file\_config
      - sodaware.file\_config\_iniserializer
      - sodaware.file\_fnmatch
      - sodaware.file\_json
      - sodaware.file\_util
    - [bah.mod](https://github.com/maxmods/bah.mod)
      - bah.volumes
      - bah.libxml

### Compiling

To build the app in release mode, run the following from the command line:

```
bmk makeapp -h -r -o build/docgen src/main.bmx
```

Alternatively, if [blam](https://www.sodaware.net/blam) is installed run `blam` in the project directory.

Copy the `docgen` executable to its final destination.


## Licence

Released under the GPLv3. See `COPYING` for the full licence.
