# the compiler: g++ for C++
CXX = g++

# compiler flags:
#  -Wall turns on most, but not all, compiler warnings
CXXFLAGS  = -Wall

LDFLAGS = "-Wl,-rpath,." -L. -lLexActivator

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Linux)
    LDFLAGS += -lcurl
endif

# the build target executable:
TARGET = Sample

all: $(TARGET)

$(TARGET): $(TARGET).cpp
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $(TARGET) $(TARGET).cpp

clean:
	$(RM) $(TARGET)