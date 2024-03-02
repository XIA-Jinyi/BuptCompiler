CC=gcc
CFLAGS=-I. --shared -fPIC -o libsymtab.so

lltest: clean
	$(CC) symtab_ll.c $(CFLAGS)
	@echo "\e[92mRunning test for \e[4mlinked list\e[24m implementation...\e[0m"
	@python3 test.py ||:
httest: clean
	$(CC) symtab_ht.c $(CFLAGS)
	@echo "\e[92mRunning test for \e[4mhash table\e[24m implementation...\e[0m"
	@python3 test.py ||:
bttest: clean
	$(CC) symtab_bt.c $(CFLAGS)
	@echo "\e[92mRunning test for \e[4mbinary tree\e[24m implementation...\e[0m"
	@python3 test.py ||:
clean:
	@rm -f *.o *.out *.so
.PHONY: lltest httest bttest
