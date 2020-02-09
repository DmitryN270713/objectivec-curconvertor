#Some stuff can be included here later on
#At this point an empty non-existing file "nothing" is "included"

-include nothing

Q = @
INCLUDE_PREF = -I

CC := gcc 

#Here the source files are specified

list_src_files = $(shell find . -type f -name "*.m")
SRCS := $(subst ./,,$(call list_src_files))

#Here is our include files

list_include_dirs = $(shell find . -type d -name "include")
INCLUDE_LS := $(call list_include_dirs)
INCLUDE_DIRS := $(INCLUDE_PREF).
INCLUDE_DIRS += $(addprefix $(INCLUDE_PREF), $(subst ./,,$(INCLUDE_LS)))

#Flags used with gcc

#CFLAGS = -Wall -fobjc-arc -framework Foundation -g -O0 $(INCLUDE_DIRS)
CFLAGS = -Wall -fno-objc-arc -framework Foundation -g -O3 $(INCLUDE_DIRS)
#CFLAGS = -Wall -fno-objc-arc -g -O3 $(INCLUDE_DIRS)

#Here all object files are specified

OBJS := $(SRCS:%.m=%.o)


#Here is the name of target specified

TARGET := Convertor

#Here is our target

$(TARGET): $(OBJS)
					@echo "Building target"
				  $(Q)$(CC) $(CFLAGS) $^ -o $@

%.o: %.m
		@echo "Building object: "$<
		$(Q)$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean

clean:
	$(Q)-rm $(OBJS) $(TARGET) 2>/dev/null || true
