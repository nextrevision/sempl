# sempl

[![Circle CI](https://circleci.com/gh/nextrevision/sempl.svg?style=svg)](https://circleci.com/gh/nextrevision/sempl)

Stupid simple `bash` templating.

Uses environment variables, inherited or sourced from a file, to render
templates using common bash utilities.

Given the following template (`examples/config.yaml.tmpl`):

    user: $USER
    password: ${password:-defaultpass}
    files:
      ### begin
      # for f in $(ls); do
      - $f
      # done
      ### end

We could expect the following output when running `sempl`:

    $ USER=myuser sempl -o examples/config.yaml.tmpl
    user: myuser
    password: defaultpass
    files:
      - README.md
      - examples
      - sempl

## Installation

    curl -L -o sempl https://github.com/nextrevision/sempl/raw/master/sempl
    chmod +x sempl

### Requirements

* bash
* sed (GNU)
* mktemp
* grep (egrep)
* openssl (if using encryption)

## Usage

    usage: ./sempl [args] template [outfile]

    args:
    -s [varsfile]   vars file
    -p [password]   decryption password
    -k [passfile]   decryption password file
    -v              verbose
    -o              prints template to stdout
    -h              help
    --version       print version and exit
    --update        update script to latest version

## Encryption

`crypttool` is a very simple wrapper around the openssl command that
can encrypt, decrypt, or edit a file. `sempl` can take an encrypted file
and decrypt it at runtime with a password/passfile specified as an argument.
This allows storing of secrets in variable files and decryption at the point
of rendering a template file.

### Encrypting a Varsfile

    ./crypttool -p mypassword encrypt examples/vars.sh

### Decrypting a Varsfile

    ./crypttool -p mypassword decrypt examples/vars.sh.enc

### Editing an Encrypted Varsfile

    ./crypttool -p mypassword edit examples/vars.sh.enc

## Loops

It is possible to use inline bash loops for more complex logic.

In order to designate where the loop should start, you must have in text
`### begin` followed at some point by `### end` signaling the end of a loop.
Any code you wish to execute must be preceded with a `#` and a space. Anything
without a preceding `#` will be rendered as output by the template.

## Caveats

* A backslash must be doubly escaped (i.e. `\\`)
* Redirection in command substitution does not work (i.e. `$(cat blah 2>&1)`)
* Quotes (single and double) must be closed or escaped

## Examples

### Template Expansion w/ Environment Vars

    source examples/vars.sh
    ./sempl -v examples/config.json.tmpl

### Template Expansion w/ Vars File

    ./sempl -v -s examples/vars.sh examples/config.json.tmpl

### Template Expansion w/ Outfile

    ./sempl -v -s examples/vars.sh examples/config.json.tmpl \
      examples/outfile.json

### Template Expansion w/ Decryption Key

    ./sempl -v -p mypassword -s examples/vars.sh \
      examples/config.json.tmpl examples/outfile.json

### Template Expansion w/ Decryption File

    ./sempl -v -k examples/passfile.txt -s examples/vars.sh \
      examples/outfile.json examples/config.json.tmpl

### Looping over a list of files

Given the template `test.txt.tmpl` below:

    This is a text file. Siblings include:
    ### begin
    # for i in $(ls); do
    # if [[ $i == "sibling1.txt" ]]; then
      $i (favorite)
    # else
      $i
    # fi
    # done
    ### end

Could be rendered as:

    This is a text file. Siblings include:
      test.txt.tmpl
      sibling1.txt (favorite)
      sibling2.txt
