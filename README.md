# sempl

Stupid simple `bash` templating.

## Requirements

* bash
* sed
* mktemp
* grep (egrep)

## Installation

```
curl -L -o sempl https://github.com/nextrevision/sempl/raw/master/sempl
chmod +x sempl
```

## Usage

```
usage: ./sempl [args] template [outfile]

args:
-s [varsfile]   vars file
-p [password]   decryption password
-k [passfile]   decryption password file
-v              verbose
-o              prints template to stdout
-h              help
```

## Examples

### Template Expansion w/ Environment Vars

```
source examples/vars.sh
./sempl -v examples/config.json.tmpl
```

### Template Expansion w/ Vars File

```
./sempl -v -s examples/vars.sh examples/config.json.tmpl
```

### Template Expansion w/ Outfile

```
./sempl -v -s examples/vars.sh examples/config.json.tmpl \
  examples/outfile.json
```

### Template Expansion w/ Decryption Key

```
./sempl -v -p mypassword -s examples/vars.sh \
  examples/config.json.tmpl examples/outfile.json
```

### Template Expansion w/ Decryption File

```
./sempl -v -k examples/passfile.txt -s examples/vars.sh \
  examples/outfile.json examples/config.json.tmpl
```

## Encryption

Creating an encryption file can easily be done by using `openssl`:

```
echo -e "VAR1=secretvar\nVAR2=secretvar2" > secret.txt
openssl aes-256-cbc -salt -in secret.txt -out secret.txt.enc
```

## Loops

It is possible to use inline bash loops for more complex logic.

In order to designate where the loop should start, you must have in text
```### begin``` followed at some point by ```### end``` signaling the end
of a loop. Any code you wish to execute must be preceded with a ```#``` and
a space. Anything without a preceding ```#``` will be rendered as output by the
template.

### Examples

Looping over a list of files

    # test.txt.tmpl

    This is a text file. Siblings include:
    ### begin
    # for i in $(ls); do
      $i
    # done
    ### end

    # Could possibly render as
    This is a text file. Siblings include:
      test.txt.tmpl
      sibling1.txt
      sibling2.txt
