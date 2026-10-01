.PHONY: cat find grep

all:	cat find grep
cat:
	bash tests/test_cat.sh

find:
	bash tests/test_find.sh

grep:
	bash tests/test_grep.sh
