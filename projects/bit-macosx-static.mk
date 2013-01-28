#
#   bit-macosx-static.mk -- Makefile to build Embedthis Bit for macosx
#

PRODUCT         ?= bit
VERSION         ?= 0.8.0
BUILD_NUMBER    ?= 0
PROFILE         ?= static
ARCH            ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
OS              ?= macosx
CC              ?= /usr/bin/clang
LD              ?= /usr/bin/ld
CONFIG          ?= $(OS)-$(ARCH)-$(PROFILE)

CFLAGS          += -w
DFLAGS          += $(patsubst %,-D%,$(filter BIT_%,$(MAKEFLAGS)))
IFLAGS          += -I$(CONFIG)/inc
LDFLAGS         += '-Wl,-rpath,@executable_path/' '-Wl,-rpath,@loader_path/'
LIBPATHS        += -L$(CONFIG)/bin
LIBS            += -lpthread -lm -ldl

DEBUG           ?= debug
CFLAGS-debug    := -g
DFLAGS-debug    := -DBIT_DEBUG
LDFLAGS-debug   := -g
DFLAGS-release  := 
CFLAGS-release  := -O2
LDFLAGS-release := 
CFLAGS          += $(CFLAGS-$(DEBUG))
DFLAGS          += $(DFLAGS-$(DEBUG))
LDFLAGS         += $(LDFLAGS-$(DEBUG))

all compile: prep \
        $(CONFIG)/bin/ca.crt \
        $(CONFIG)/bin/libmpr.a \
        $(CONFIG)/bin/libmprssl.a \
        $(CONFIG)/bin/makerom \
        $(CONFIG)/bin/libpcre.a \
        $(CONFIG)/bin/libsqlite3.a \
        $(CONFIG)/bin/sqlite \
        $(CONFIG)/bin/libhttp.a \
        $(CONFIG)/bin/http \
        $(CONFIG)/bin/http-ca.crt \
        $(CONFIG)/bin/libejs.a \
        $(CONFIG)/bin/ejs \
        $(CONFIG)/bin/ejsc \
        $(CONFIG)/bin/ejs.mod \
        $(CONFIG)/bin/bit.es \
        $(CONFIG)/bin/bit \
        $(CONFIG)/bin/bits

.PHONY: prep

prep:
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@[ ! -x $(CONFIG)/inc ] && mkdir -p $(CONFIG)/inc $(CONFIG)/obj $(CONFIG)/lib $(CONFIG)/bin ; true
	@[ ! -f $(CONFIG)/inc/bit.h ] && cp projects/bit-$(OS)-$(PROFILE)-bit.h $(CONFIG)/inc/bit.h ; true
	@[ ! -f $(CONFIG)/inc/bitos.h ] && cp src/bitos.h $(CONFIG)/inc/bitos.h ; true
	@if ! diff $(CONFIG)/inc/bit.h projects/bit-$(OS)-$(PROFILE)-bit.h >/dev/null ; then\
		echo cp projects/bit-$(OS)-$(PROFILE)-bit.h $(CONFIG)/inc/bit.h  ; \
		cp projects/bit-$(OS)-$(PROFILE)-bit.h $(CONFIG)/inc/bit.h  ; \
	fi; true
	@echo $(DFLAGS) $(CFLAGS) >projects/.flags

clean:
	rm -rf $(CONFIG)/bin/ca.crt
	rm -rf $(CONFIG)/bin/libmpr.a
	rm -rf $(CONFIG)/bin/libmprssl.a
	rm -rf $(CONFIG)/bin/makerom
	rm -rf $(CONFIG)/bin/libpcre.a
	rm -rf $(CONFIG)/bin/libsqlite3.a
	rm -rf $(CONFIG)/bin/sqlite
	rm -rf $(CONFIG)/bin/libhttp.a
	rm -rf $(CONFIG)/bin/http
	rm -rf $(CONFIG)/bin/http-ca.crt
	rm -rf $(CONFIG)/bin/libejs.a
	rm -rf $(CONFIG)/bin/ejs
	rm -rf $(CONFIG)/bin/ejsc
	rm -rf $(CONFIG)/bin/ejs.mod
	rm -rf $(CONFIG)/obj/estLib.o
	rm -rf $(CONFIG)/obj/mprLib.o
	rm -rf $(CONFIG)/obj/mprSsl.o
	rm -rf $(CONFIG)/obj/manager.o
	rm -rf $(CONFIG)/obj/makerom.o
	rm -rf $(CONFIG)/obj/pcre.o
	rm -rf $(CONFIG)/obj/sqlite3.o
	rm -rf $(CONFIG)/obj/sqlite.o
	rm -rf $(CONFIG)/obj/httpLib.o
	rm -rf $(CONFIG)/obj/http.o
	rm -rf $(CONFIG)/obj/ejsLib.o
	rm -rf $(CONFIG)/obj/ejs.o
	rm -rf $(CONFIG)/obj/ejsc.o
	rm -rf $(CONFIG)/obj/removeFiles.o
	rm -rf $(CONFIG)/obj/bit.o

clobber: clean
	rm -fr ./$(CONFIG)

$(CONFIG)/bin/ca.crt: 
	rm -fr $(CONFIG)/bin/ca.crt
	cp -r src/deps/est/ca.crt $(CONFIG)/bin/ca.crt

$(CONFIG)/inc/bitos.h: 
	rm -fr $(CONFIG)/inc/bitos.h
	cp -r src/bitos.h $(CONFIG)/inc/bitos.h

$(CONFIG)/inc/mpr.h:  \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/bitos.h
	rm -fr $(CONFIG)/inc/mpr.h
	cp -r src/deps/mpr/mpr.h $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/mprLib.o: \
        src/deps/mpr/mprLib.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/mpr.h
	$(CC) -c -o $(CONFIG)/obj/mprLib.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/mpr/mprLib.c

$(CONFIG)/bin/libmpr.a:  \
        $(CONFIG)/inc/mpr.h \
        $(CONFIG)/obj/mprLib.o
	/usr/bin/ar -cr $(CONFIG)/bin/libmpr.a $(CONFIG)/obj/mprLib.o

$(CONFIG)/inc/est.h:  \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/bitos.h
	rm -fr $(CONFIG)/inc/est.h
	cp -r src/deps/est/est.h $(CONFIG)/inc/est.h

$(CONFIG)/obj/mprSsl.o: \
        src/deps/mpr/mprSsl.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/mpr.h \
        $(CONFIG)/inc/est.h
	$(CC) -c -o $(CONFIG)/obj/mprSsl.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/mpr/mprSsl.c

$(CONFIG)/bin/libmprssl.a:  \
        $(CONFIG)/bin/libmpr.a \
        $(CONFIG)/obj/mprSsl.o
	/usr/bin/ar -cr $(CONFIG)/bin/libmprssl.a $(CONFIG)/obj/mprSsl.o

$(CONFIG)/obj/makerom.o: \
        src/deps/mpr/makerom.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/mpr.h
	$(CC) -c -o $(CONFIG)/obj/makerom.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/mpr/makerom.c

$(CONFIG)/bin/makerom:  \
        $(CONFIG)/bin/libmpr.a \
        $(CONFIG)/obj/makerom.o
	$(CC) -o $(CONFIG)/bin/makerom -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/makerom.o -lmpr $(LIBS)

$(CONFIG)/inc/pcre.h:  \
        $(CONFIG)/inc/bit.h
	rm -fr $(CONFIG)/inc/pcre.h
	cp -r src/deps/pcre/pcre.h $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/pcre.o: \
        src/deps/pcre/pcre.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/pcre.h
	$(CC) -c -o $(CONFIG)/obj/pcre.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/pcre/pcre.c

$(CONFIG)/bin/libpcre.a:  \
        $(CONFIG)/inc/pcre.h \
        $(CONFIG)/obj/pcre.o
	/usr/bin/ar -cr $(CONFIG)/bin/libpcre.a $(CONFIG)/obj/pcre.o

$(CONFIG)/inc/sqlite3.h:  \
        $(CONFIG)/inc/bit.h
	rm -fr $(CONFIG)/inc/sqlite3.h
	cp -r src/deps/sqlite/sqlite3.h $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite3.o: \
        src/deps/sqlite/sqlite3.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/sqlite3.h
	$(CC) -c -o $(CONFIG)/obj/sqlite3.o -arch x86_64 -w $(DFLAGS) -I$(CONFIG)/inc src/deps/sqlite/sqlite3.c

$(CONFIG)/bin/libsqlite3.a:  \
        $(CONFIG)/inc/sqlite3.h \
        $(CONFIG)/obj/sqlite3.o
	/usr/bin/ar -cr $(CONFIG)/bin/libsqlite3.a $(CONFIG)/obj/sqlite3.o

$(CONFIG)/obj/sqlite.o: \
        src/deps/sqlite/sqlite.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/sqlite3.h
	$(CC) -c -o $(CONFIG)/obj/sqlite.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/sqlite/sqlite.c

$(CONFIG)/bin/sqlite:  \
        $(CONFIG)/bin/libsqlite3.a \
        $(CONFIG)/obj/sqlite.o
	$(CC) -o $(CONFIG)/bin/sqlite -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/sqlite.o -lsqlite3 $(LIBS)

$(CONFIG)/inc/http.h:  \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/mpr.h
	rm -fr $(CONFIG)/inc/http.h
	cp -r src/deps/http/http.h $(CONFIG)/inc/http.h

$(CONFIG)/obj/httpLib.o: \
        src/deps/http/httpLib.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/http.h
	$(CC) -c -o $(CONFIG)/obj/httpLib.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/http/httpLib.c

$(CONFIG)/bin/libhttp.a:  \
        $(CONFIG)/bin/libmpr.a \
        $(CONFIG)/bin/libpcre.a \
        $(CONFIG)/inc/http.h \
        $(CONFIG)/obj/httpLib.o
	/usr/bin/ar -cr $(CONFIG)/bin/libhttp.a $(CONFIG)/obj/httpLib.o

$(CONFIG)/obj/http.o: \
        src/deps/http/http.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/http.h
	$(CC) -c -o $(CONFIG)/obj/http.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/http/http.c

$(CONFIG)/bin/http:  \
        $(CONFIG)/bin/libhttp.a \
        $(CONFIG)/obj/http.o
	$(CC) -o $(CONFIG)/bin/http -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/http.o -lhttp $(LIBS) -lpcre -lmpr

$(CONFIG)/bin/http-ca.crt: 
	rm -fr $(CONFIG)/bin/http-ca.crt
	cp -r src/deps/http/http-ca.crt $(CONFIG)/bin/http-ca.crt

$(CONFIG)/inc/ejs.slots.h:  \
        $(CONFIG)/inc/bit.h
	rm -fr $(CONFIG)/inc/ejs.slots.h
	cp -r src/deps/ejs/ejs.slots.h $(CONFIG)/inc/ejs.slots.h

$(CONFIG)/inc/ejs.h:  \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/bitos.h \
        $(CONFIG)/inc/mpr.h \
        $(CONFIG)/inc/http.h \
        $(CONFIG)/inc/ejs.slots.h
	rm -fr $(CONFIG)/inc/ejs.h
	cp -r src/deps/ejs/ejs.h $(CONFIG)/inc/ejs.h

$(CONFIG)/inc/ejsByteGoto.h: 
	rm -fr $(CONFIG)/inc/ejsByteGoto.h
	cp -r src/deps/ejs/ejsByteGoto.h $(CONFIG)/inc/ejsByteGoto.h

$(CONFIG)/obj/ejsLib.o: \
        src/deps/ejs/ejsLib.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/ejs.h \
        $(CONFIG)/inc/mpr.h \
        $(CONFIG)/inc/pcre.h \
        $(CONFIG)/inc/sqlite3.h
	$(CC) -c -o $(CONFIG)/obj/ejsLib.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/ejs/ejsLib.c

$(CONFIG)/bin/libejs.a:  \
        $(CONFIG)/bin/libhttp.a \
        $(CONFIG)/bin/libpcre.a \
        $(CONFIG)/bin/libmpr.a \
        $(CONFIG)/bin/libsqlite3.a \
        $(CONFIG)/inc/ejs.h \
        $(CONFIG)/inc/ejs.slots.h \
        $(CONFIG)/inc/ejsByteGoto.h \
        $(CONFIG)/obj/ejsLib.o
	/usr/bin/ar -cr $(CONFIG)/bin/libejs.a $(CONFIG)/obj/ejsLib.o

$(CONFIG)/obj/ejs.o: \
        src/deps/ejs/ejs.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/ejs.h
	$(CC) -c -o $(CONFIG)/obj/ejs.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/ejs/ejs.c

$(CONFIG)/bin/ejs:  \
        $(CONFIG)/bin/libejs.a \
        $(CONFIG)/obj/ejs.o
	$(CC) -o $(CONFIG)/bin/ejs -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejs.o -lejs $(LIBS) -lsqlite3 -lmpr -lpcre -lhttp -ledit -ledit

$(CONFIG)/obj/ejsc.o: \
        src/deps/ejs/ejsc.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/ejs.h
	$(CC) -c -o $(CONFIG)/obj/ejsc.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/ejs/ejsc.c

$(CONFIG)/bin/ejsc:  \
        $(CONFIG)/bin/libejs.a \
        $(CONFIG)/obj/ejsc.o
	$(CC) -o $(CONFIG)/bin/ejsc -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejsc.o -lejs $(LIBS) -lsqlite3 -lmpr -lpcre -lhttp

$(CONFIG)/bin/ejs.mod:  \
        $(CONFIG)/bin/ejsc
	cd src/deps/ejs >/dev/null ;\
		../../../$(CONFIG)/bin/ejsc --out ../../../$(CONFIG)/bin/ejs.mod --optimize 9 --bind --require null ejs.es ;\
		cd - >/dev/null 

$(CONFIG)/bin/bit.es: 
	rm -fr $(CONFIG)/bin/bit.es
	cp -r src/bit.es $(CONFIG)/bin/bit.es

$(CONFIG)/bin/bits: 
	cd . >/dev/null ;\
		rm -fr ./$(CONFIG)/bin/bits ;\
	cp -r bits ./$(CONFIG)/bin ;\
		cd - >/dev/null 

$(CONFIG)/obj/bit.o: \
        src/bit.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/ejs.h
	$(CC) -c -o $(CONFIG)/obj/bit.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/bit.c

$(CONFIG)/bin/bit:  \
        $(CONFIG)/bin/libmpr.a \
        $(CONFIG)/bin/libhttp.a \
        $(CONFIG)/bin/libejs.a \
        $(CONFIG)/bin/bits \
        $(CONFIG)/bin/bit.es \
        $(CONFIG)/inc/bitos.h \
        $(CONFIG)/obj/bit.o
	$(CC) -o $(CONFIG)/bin/bit -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/bit.o $(CONFIG)/obj/mprLib.o $(CONFIG)/obj/pcre.o $(CONFIG)/obj/httpLib.o $(CONFIG)/obj/sqlite3.o $(CONFIG)/obj/ejsLib.o $(LIBS)

version: 
	cd bits >/dev/null ;\
		@echo 0.8.0-0 ;\
		cd - >/dev/null 

install: 
	cd . >/dev/null ;\
		sudo make root-install ;\
		cd - >/dev/null 

install-prep:  \
        compile
	cd . >/dev/null ;\
		$(BIN)/ejs bits/getbitvals projects/$(NAME)-$(OS)-$(PROFILE)-bit.h PRODUCT VERSION CFG_PREFIX PRD_PREFIX WEB_PREFIX LOG_PREFIX BIN_PREFIX SPL_PREFIX BIN_PREFIX >.prefixes; chmod 666 .prefixes ;\
	echo $(eval include .prefixes) ;\
		cd - >/dev/null 

root-install:  \
        compile \
        install-prep
	cd . >/dev/null ;\
		rm -f $(BIT_PRD_PREFIX)/latest /bit  ;\
	install -d -m 755 $(BIT_CFG_PREFIX) $(BIT_BIN_PREFIX) ;\
	install -m 755 $(wildcard $(BIN)/*) $(BIT_BIN_PREFIX) ;\
	ln -s $(BIT_VERSION) $(BIT_PRD_PREFIX)/latest ;\
	ln -s $(BIT_BIN_PREFIX)/bit /bit ;\
	exit 0 ;\
		cd - >/dev/null 

uninstall: 
	cd . >/dev/null ;\
		sudo make root-uninstall ;\
		cd - >/dev/null 

root-uninstall:  \
        compile \
        install-prep
	cd . >/dev/null ;\
		echo rm -fr $(BIT_PRD_PREFIX) ;\
		cd - >/dev/null 
