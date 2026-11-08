# ===================== Basic =====================
PREFIX ?= /usr/local
DESTDIR ?=
BINDIR := $(PREFIX)/bin
SHAREDIR := $(PREFIX)/share
FISH_COMP_DIR := $(shell pkg-config --variable=completionsdir fish 2>/dev/null || echo $(SHAREDIR)/fish/vendor_completions.d)

# ===================== Source =====================
BUILD_DIR := build
# Argbash Template For Main Script
TEMPLATE_SRC := src/templates/argbash/save-music.tmpl.bash
BIN_SCRIPTS := src/bin/flac-normalize src/bin/mp3-normalize
FISH_COMP_SRC := src/share/fish/vendor_completions.d/save-music.fish
MAIN_SCRIPT := $(BUILD_DIR)/save-music

# ===================== Tools =====================
ARGBASH := build/argbash/bin/argbash
INSTALL := install
MKDIR := mkdir -p
RM := rm -rf

# ===================== Default Target =====================
all: check $(MAIN_SCRIPT)

# Check Dependencies
check:
	@command -v pkg-config >/dev/null 2>&1 || { echo >&2 "Error：command pkg-config mission"; exit 1; }

# Compile Main Script
$(MAIN_SCRIPT): $(TEMPLATE_SRC)
	$(MKDIR) $(BUILD_DIR)
	$(ARGBASH) $(TEMPLATE_SRC) -o $@
	chmod +x $@

# ===================== Installation =====================
install: all
	# 1. Create Directories
	$(INSTALL) -d $(DESTDIR)$(BINDIR)
	$(INSTALL) -d $(DESTDIR)$(FISH_COMP_DIR)

	# 2. Install Executable Files
	$(INSTALL) -m755 $(MAIN_SCRIPT) $(DESTDIR)$(BINDIR)/
	$(INSTALL) -m755 $(BIN_SCRIPTS) $(DESTDIR)$(BINDIR)/

	# 3. Install Fish Completion Script
	$(INSTALL) -m644 $(FISH_COMP_SRC) $(DESTDIR)$(FISH_COMP_DIR)/

# ===================== Uninstallation ===================

uninstall:
	$(RM) $(addprefix $(DESTDIR)$(BINDIR)/, $(notdir $(BIN_SCRIPTS) $(MAIN_SCRIPT))) \
		$(addprefix $(DESTDIR)$(FISH_COMP_DIR)/, $(notdir $(FISH_COMP_SRC)))

# ===================== Clean =====================
clean:
	$(RM) $(BUILD_DIR)/save-music

# ===================== Phony Targets =====================
.PHONY: all check install uninstall clean

