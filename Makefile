SRC_DIR=src
BUILD_DIR=lib

GRAMMAR_DIR=src
GRAMMAR_BUILD_DIR=lib

YML_DIR=.
JSON_DIR=.

COFFEE_SOURCES= $(wildcard $(SRC_DIR)/*.coffee)
COFFEE_OBJECTS=$(patsubst $(SRC_DIR)/%.coffee, $(BUILD_DIR)/%.js, $(COFFEE_SOURCES))

GRAMMAR_SOURCES= $(wildcard $(GRAMMAR_DIR)/*.pegjs)
GRAMMAR_TEMP_OBJECTS = $(patsubst $(GRAMMAR_DIR)/%.pegjs, $(GRAMMAR_DIR)/%.js, $(GRAMMAR_SOURCES))
GRAMMAR_OBJECTS= $(patsubst $(GRAMMAR_DIR)/%.pegjs, $(GRAMMAR_BUILD_DIR)/%.js, $(GRAMMAR_SOURCES))

YML_FILES=$(wildcard $(YML_DIR)/*.yml)
JSON_FILES=$(patsubst $(YML_DIR)/%.yml, $(JSON_DIR)/%.json, $(YML_FILES))

all: build

.PHONY: build
build: node_modules objects

.PHONY: objects
objects: $(COFFEE_OBJECTS) $(JSON_FILES) $(GRAMMAR_OBJECTS) $(GRAMMAR_TEMP_OBJECTS)

node_modules:
	npm install -d

$(JSON_DIR)/%.json: $(YML_DIR)/%.yml
	./node_modules/.bin/bean --source $<

$(BUILD_DIR)/%.js: $(SRC_DIR)/%.coffee
	coffee -o $(BUILD_DIR) -c $<

$(GRAMMAR_BUILD_DIR)/%.js: $(GRAMMAR_DIR)/%.pegjs
	./node_modules/.bin/pegjs $< $@

$(GRAMMAR_DIR)/%.js: $(GRAMMAR_DIR)/%.pegjs
	./node_modules/.bin/pegjs $< $@

.PHONY: test
test: build
	./node_modules/.bin/testlet

.PHONY: clean
clean:
	rm -f $(COFFEE_OBJECTS)

.PHONE: pristine
pristine: clean
	rm -rf node_modules

.PHONY: watch
watch:
	coffee --watch -o $(BUILD_DIR) -c $(SRC_DIR)

.PHONY: start
start:	all
	./node_modules/.bin/supervisor -w routes,views,lib,src -e coffee,hbs,js,json -q server.js
