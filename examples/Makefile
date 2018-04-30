# the compiler: g++ for C++
CXX = g++

# compiler flags:
#  -Wall turns on most, but not all, compiler warnings
CXXFLAGS  = -Wall

LDFLAGS = "-Wl,-rpath,." -L. -lLexActivator

# Uncomment for static linking on Linux
#LDFLAGS += -Wl,-Bstatic -L. -lLexActivator -Wl,-Bdynamic -lpthread -lssl3 -lnss3 -lnspr4

# Uncomment for static linking on MacOS
#LDFLAGS += -Wl,-Bstatic -L. -lLexActivator

# the build target executable:
TARGET = Sample

all: $(TARGET)

$(TARGET): $(TARGET).cpp
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(TARGET).cpp $(LDFLAGS)

clean:
	$(RM) $(TARGET)