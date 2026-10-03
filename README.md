# coreutils.py

A re-implementation of common coreutils in python

<details>
<summary>cat</summary>

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

</details>

<details>
<summary>find</summary>

## find

Behaviour supported:

### 1) No arguments lists everything in current directory

```bash
$ ./find
```

### 2) No glob pattern lists everything in target directory

```bash
$ ./find data
```

### 3) Directory and glob pattern matches filtered files

```bash
$ ./find data -name "*.txt"
```

### 4) Matching directories or regular files

```bash
$ ./find data -type d
...
$ ./find data -type f
...
```

### 5) Matching by modified time

```bash
./find . -mtime +1
...
./find . -mtime -1
...
./find . -mtime 1
...
```
### 6) Executing commands on each output path

```bash
./find data -exec wc -l {} \;
```

### 7) Using null as separator in the output paths

```bash
./find data -print0
```

</details>

<details>
<summary>grep</summary>

## grep

Behaviour supported:

### 1) Searching from stdin

```bash
cat data/file1.txt | ./grep two
```

### 2) Searching from file argument list

```bash
./grep two data/file1.txt data/file2.txt
```

### 3) Doing a case-insensitive search

```bash
./grep -i hello data/file1.txt data/file2.txt
```

### 4) Doing a recursive search into directories

```bash
./grep -r hello data
```

### 5) Showing line number

```bash
./grep -n hello data/*
```

### 6) Inverting the search

```bash
./grep -v hello data/*
```

### 7) Showing a count of matching lines per file

```bash
./grep -c two data/*
```

</details>

<details>
<summary>cut</summary>

## cut

Supported behaviour:

### 1) Extracting fields from stdin with default tab separator

```bash
printf "a\tb\tc\n" | ./cut -f2 
```

### 2) Extracting fields from argument files and/or stdin

```bash
printf "a\tb\tc\n" | ./cut -f2 data/file1.txt -
```

### 3) Using a custom delimiter for selecting and displaying fields

```bash
./cut -d ':' -f1-2 /etc/passwd
```

### 4) Extracting by character position

```bash
printf 'abcd\n' | ./cut -c1-2
```

### 5) Extracting the complement of the selection

```bash
printf 'abcd\n' | ./cut -c1-2 --complement
```

</details>

<details>
<summary>sed</summary>

## sed

Behaviours implemented

### 1) Simple substitution

```bash
echo 'hello world' | ./sed s/world/there/
```

</details>
