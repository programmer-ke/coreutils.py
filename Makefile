TARGETS := cat find grep cut sed sort

.PHONY: $(TARGETS)

all:	$(TARGETS)

cat:
	bash tests/test_cat.sh

find:
	bash tests/test_find.sh

grep:
	bash tests/test_grep.sh

cut:
	bash tests/test_cut.sh

sed:
	bash tests/test_sed.sh

sort:
	bash tests/test_sort.sh
