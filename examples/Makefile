# the compiler: g++ for C++
CXX = g++

# compiler flags:
#  -Wall turns on most, but not all, compiler warnings
CXXFLAGS  = -Wall

LDFLAGS = "-Wl,-rpath,." -L. -lLexActivator

# the build target executable:
TARGET = Sample

all: $(TARGET)

$(TARGET): $(TARGET).cpp
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $(TARGET) $(TARGET).cpp

clean:
	$(RM) $(TARGET)