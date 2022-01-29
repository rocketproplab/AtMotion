OBJ_DIR=build
BUILD_DIR=${OBJ_DIR}
CC:=gcc
TEST_DIR=test
CPP_DIR=cpp

MODEL_OBJECTS:=$(wildcard cpp/*.cpp)
TEST_OBJECTS=$(notdir $(basename $(MODEL_OBJECTS)))
#MODEL_OBJECTS_TMP=$(CPP_PROGRAMS:.cpp=.o)
MODEL_OBJECTS_TMP=$(MODEL_OBJECTS:.cpp=.o)
#DIS_FILES=$(addprefix ${BUILD_DIR}/${CPP_DIR}, ${MODEL_OBJECTS_TMP})
DIS_FILES=$(addprefix ${BUILD_DIR}/, ${MODEL_OBJECTS_TMP})
TEST_FILES=$(addprefix ${BUILD_DIR}/${TEST_DIR}/, ${TEST_OBJECTS})

#all: build/cpp/PacketDetectionUnit.o build/cpp/FrameProcessor.o
all: ${DIS_FILES} ${TEST_FILES} #${BUILD_DIR}/${TEST_DIR}/${TEST_OBJECTS}

${OBJ_DIR}/cpp/%.o: cpp/%.cpp
	echo "model object: ${MODEL_OBJECTS}"
	echo "test object: ${TEST_OBJECTS}"
	echo ${DIS_FILES}
	@mkdir -p ${OBJ_DIR}/${CPP_DIR}
	$(CC) -g -c $< -o $@

# build/test/FrameProcessor: ${TEST_DIR}/FrameProcessorTest.cpp ${BUILD_DIR}/cpp/FrameProcessor.o
# 	@mkdir -p ${OBJ_DIR}/test/
# 	echo ${DIS_FILES}
# 	$(CC) -I ${CPP_DIR} -g $< ${BUILD_DIR}/cpp/FrameProcessor.o -o $@

# build/test/PacketDetectionUnit: ${TEST_DIR}/PacketDetectionUnitTest.cpp ${BUILD_DIR}/cpp/PacketDetectionUnit.o
# 	@mkdir -p ${OBJ_DIR}/test/
# 	echo ${DIS_FILES}
# 	$(CC) -I ${CPP_DIR} -g $< ${BUILD_DIR}/cpp/PacketDetectionUnit.o -o $@

clean: 
	rm -r ${BUILD_DIR}

build/test/%: ${TEST_DIR}/%Test.cpp ${DIS_FILES}
	@mkdir -p ${OBJ_DIR}/${TEST_DIR}/
	$(CC) -I ${CPP_DIR} -g $< ${DIS_FILES} -o $@
#	$(CC) g $< ${DIS_FILES} -o $@
