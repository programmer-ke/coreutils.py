.PHONY: cat find

all:	cat find
cat:
	bash tests/test_cat.sh

find:
	bash tests/test_find.sh
