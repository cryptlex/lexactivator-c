# the compiler: g++ for C++
CXX = g++

# compiler flags:
#  -Wall turns on most, but not all, compiler warnings
CXXFLAGS  = -Wall

LDFLAGS = "-Wl,-rpath,." -L. -lLexActivator
#LDFLAGS += -Wl,-Bstatic -lLexActivator


# the build target executable:
TARGET = Sample

all: $(TARGET)

$(TARGET): $(TARGET).cpp
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(TARGET).cpp $(LDFLAGS)

clean:
	$(RM) $(TARGET)