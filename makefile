# Makefile for ti-msp430
MCU_DIR = /opt/ti-msp430
MCU_HEADERS = $(MCU_DIR)/lib/gcc/msp430-elf/9.3.1/include
MCU_LINKS = $(MCU_DIR)/lib/gcc/msp430-elf/9.3.1/include

# Set your device here
MCU ?= msp430g2553
CC = msp430-elf-gcc
GDB = msp430-elf-gdb

UNITYCC = gcc

SRCDIR := src
TSTDIR := tests
UNITYDIR := $(TSTDIR)/Unity
OBJDIR := .obj
DEPDIR := .deps

CFLAGS = -mmcu=$(MCU) -O2 -Wall -c -g
LFLAGS = -L $(MCU_LINKS)
DEPFLAGS = -MT $@ -MMD -MP -MF $(DEPDIR)/$*.d
UNITYCFLAGS = -O2 -Wall -c -g

SRCS := $(wildcard $(SRCDIR)/*.c)
SRCOBJS := $(SRCS:%.c=$(OBJDIR)/%.o)
SRCDEPS := $(subst $(SRCDIR), $(DEPDIR), $(SRCS:%.c=%.d))

TSTS := $(wildcard $(TSTDIR)/*.c)
TSTOBJS := $(TSTS:%.c=$(OBJDIR)/%.o)
TSTDEPS := $(subst $(TSTDIR), $(DEPDIR), $(TSTS:%.c=%.d))
UNITY := $(wildcard $(UNITYDIR)/*.c)
UNITYOBJS := $(UNITY:%.c=$(OBJDIR)/%.o)
UNITYDEPS := $(subst $(UNITYDIR), $(DEPDIR), $(UNITY:%.c=%.d))


TARGET := main
TESTS := tests_all

.PHONY: all test
all: $(TARGET).elf $(TESTS).elf
test: $(TESTS).elf

$(TARGET).elf: $(SRCOBJS)
	@echo "--- Linking build"
	$(CC) $(LFLAGS) -mmcu=$(MCU) $(SRCOBJS) -o $@
	msp430-elf-size $(@)

$(OBJDIR)/$(SRCDIR)/%.o : $(SRCDIR)/%.c $(SRCDEPS) | $(DEPDIR)
	@echo "--- Compiling objects"
	@mkdir -p $(@D)
	$(CC) -I $(MCU_HEADERS) $(LFLAGS) $(CFLAGS) $(DEPFLAGS) -c $< -o $@

$(DEPDIR) : ; @mkdir -p $@

tests_all.elf: $(TSTOBJS) $(UNITYOBJS)
	@echo "--- Linking build"
	gcc $(LFLAGS) $(TSTOBJS) $(UNITYOBJS) -o $@
	size $(@)

$(OBJDIR)/$(UNITYDIR)/%.o : $(UNITYDIR)/%.c $(UNITYDEPS) | $(DEPDIR)
	@echo "--- Compiling objects"
	@mkdir -p $(@D)
	$(UNITYCC) -I $(MCU_HEADERS) -I $(UNITYDIR) $(LFLAGS) $(UNITYCFLAGS) $(DEPFLAGS) -c $< -o $@

$(OBJDIR)/$(TSTDIR)/%.o : $(TSTDIR)/%.c $(TSTDEPS) | $(DEPDIR)
	@echo "--- Compiling objects"
	@mkdir -p $(@D)
	$(UNITYCC) -I $(MCU_HEADERS) -I $(UNITYDIR) $(LFLAGS) $(UNITYCFLAGS) $(DEPFLAGS) -c $< -o $@

$(SRCDEPS):
$(TSTDEPS):
$(UNITYDEPS):

.PHONY: clean
clean:
	@echo "--- Cleaning build"
	-rm $(TARGET).elf $(TESTS).elf
	-rm -rf $(DEPDIR) $(OBJDIR)

include $(SRCDEPS) $(TSTDEPS) $(UNITYDEPS)
