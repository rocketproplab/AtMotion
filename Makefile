OBJ_DIR=build
BUILD_DIR=${OBJ_DIR}
CC:=gcc
TEST_DIR=test
CPP_DIR=cpp

MODEL_OBJECTS:=$(wildcard cpp/*.cpp)
MODEL_OBJECTS_TMP=$(CPP_PROGRAMS:.cpp=.o)
DIS_FILES=$(addprefix ${BUILD_DIR}/${CPP_DIR}, ${MODEL_OBJECTS_TMP})

${OBJ_DIR}/cpp/%.o: cpp/%.cpp
	@mkdir -p ${OBJ_DIR}/${CPP_DIR}
	$(CC) -g -c $< -o $@

build/test/FrameProcessor: ${TEST_DIR}/FrameProcessorTest.cpp ${BUILD_DIR}/cpp/FrameProcessor.o
	@mkdir -p ${OBJ_DIR}/test/
	echo ${DIS_FILES}
	$(CC) -I ${CPP_DIR} -g $< ${BUILD_DIR}/cpp/FrameProcessor.o -o $@
# build/test/%: ${TEST_DIR}/%.cpp ${DIS_FILES}
# 	@mkdir -p ${OBJ_DIR}
# 	$(CC) g $< ${DIS_FILES} -o $@