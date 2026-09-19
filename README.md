# coreutils.py

A re-implementation of common coreutils in python

## cat

Behaviour supported:

### 1) No arguments, echo output

```bash
$ echo "hello world" | ./cat
hello world
```

### 2) Display single file

```bash
$ ./cat somefile.txt
```

### 3) Concatenate multiple files

```bash
$ ./cat somefile.txt otherfile.txt
```

### 4) Create a new file

```bash
$ echo "hello world" | ./cat > newfile.txt
```

### 5) Append existing file

```bash
$ echo "hello world" | ./cat >> existingfile.txt
```

### 6) Show line numbers

```bash
$ ./cat -n file1.txt file2.txt
```

### 7) The here-document construct

```bash
$ ./cat <<EOF > somefile.txt
> line 1
> line 2
> EOF
```

### 8) stdin in argument list

`-` anywhere in the argument list is assumed to be stdin

```bash
$ printf "sometext\n" | ./cat - somefile.txt
```
