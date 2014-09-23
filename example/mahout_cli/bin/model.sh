#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# To run:  change into the mahout directory and type:
# water_est.sh

OUTPUT=$LOG_DIR/$(date "+%m%d_%H%M%S.out")

rm -rf ${WORK_DIR}
mkdir -p ${WORK_DIR}

if [ "$1" = "--help" ] || [ "$1" = "--?" ]; then
  echo "This script runs SGD and Bayes classifiers over the classic Reputation Groups."
  exit
fi

SCRIPT_PATH=${0%/*}
if [ "$0" != "$SCRIPT_PATH" ] && [ "$SCRIPT_PATH" != "" ]; then
  cd $SCRIPT_PATH
fi

if [ "$HADOOP_HOME" != "" ] && [ "$MAHOUT_LOCAL" == "" ] ; then
  HADOOP="$HADOOP_HOME/bin/hadoop"
  if [ ! -e $HADOOP ]; then
    echo "Can't find hadoop in $HADOOP, exiting"
    exit 1
  fi
fi

algorithm=( cnaivebayes naivebayes sgd clean)
if [ -n "$1" ]; then
  choice=$1
else
  echo "Please select a number to choose the corresponding task to run"
  echo "1. ${algorithm[0]}"
  echo "2. ${algorithm[1]}"
  echo "3. ${algorithm[2]}"
  echo "4. ${algorithm[3]} -- cleans up the work area in $WORK_DIR"
  read -p "Enter your choice : " choice
fi

echo "ok. You chose $choice and we'll use ${algorithm[$choice-1]}"
alg=${algorithm[$choice-1]}

if [ "x$alg" != "xclean" ]; then
  echo "creating work directory at ${WORK_DIR}"

  mkdir -p ${WORK_DIR}
  if [ ! -e ${WORK_DIR}/water-bydate ]; then
      mkdir -p ${WORK_DIR}/water-bydate
      #INPUT DATA ON THIS
  fi
fi
cd $MAHOUT_HOME

set -e

if [ "x$alg" == "xnaivebayes"  -o  "x$alg" == "xcnaivebayes" ]; then
  c=""

  if [ "x$alg" == "xcnaivebayes" ]; then
    c=" -c"
  fi

  set -x
  echo "Preparing watergroups data"
  rm -rf ${WORK_DIR}/water-all
  mkdir -p ${WORK_DIR}/water-all
  cp -R ${APP_DIR}/repo/*/* ${WORK_DIR}/water-all

  if [ "$HADOOP_HOME" != "" ] && [ "$MAHOUT_LOCAL" == "" ] ; then
    echo "Copying watergroups data to HDFS"
    set +e
    $HADOOP dfs -rmr ${WORK_DIR}/water-all
    set -e
    $HADOOP dfs -put ${WORK_DIR}/water-all ${WORK_DIR}/water-all
  fi

  echo "Creating sequence files from watergroups data"
  ./bin/mahout seqdirectory \
    -i ${WORK_DIR}/water-all \
    -o ${WORK_DIR}/water-seq -ow

  echo "Converting sequence files to vectors"
  ./bin/mahout seq2sparse \
    -i ${WORK_DIR}/water-seq \
    -o ${WORK_DIR}/water-vectors  -lnorm -nv -wt tfidf $OPT_VCT

  echo "Creating training and holdout set with a random 80-20 split of the generated vector dataset"
  ./bin/mahout split \
    -i ${WORK_DIR}/water-vectors/tfidf-vectors \
    --trainingOutput ${WORK_DIR}/water-train-vectors \
    --testOutput ${WORK_DIR}/water-test-vectors  \
    --randomSelectionPct 20 --overwrite --sequenceFiles -xm sequential

  echo "Training Naive Bayes model"
  ./bin/mahout trainnb \
    -i ${WORK_DIR}/water-train-vectors -el \
    -o ${WORK_DIR}/model \
    -li ${WORK_DIR}/labelindex \
    -ow $c

  echo "Self testing on training set"

  ./bin/mahout testnb \
    -i ${WORK_DIR}/water-train-vectors\
    -m ${WORK_DIR}/model \
    -l ${WORK_DIR}/labelindex \
    -ow -o ${WORK_DIR}/water-testing $c 

  echo "Testing on holdout set"

  ./bin/mahout testnb \
    -i ${WORK_DIR}/water-test-vectors\
    -m ${WORK_DIR}/model \
    -l ${WORK_DIR}/labelindex \
    -ow -o ${WORK_DIR}/water-testing $c 

elif [ "x$alg" == "xsgd" ]; then
  if [ ! -e "/tmp/news-group.model" ]; then
    echo "Training on ${WORK_DIR}/water-bydate/water-bydate-train/"
    ./bin/mahout org.apache.mahout.classifier.sgd.TrainNewsGroups ${WORK_DIR}/water-bydate/water-bydate-train/
  fi
  echo "Testing on ${WORK_DIR}/water-bydate/water-bydate-test/ with model: /tmp/news-group.model"
  ./bin/mahout org.apache.mahout.classifier.sgd.TestNewsGroups --input ${WORK_DIR}/water-bydate/water-bydate-test/ --model /tmp/news-group.model
elif [ "x$alg" == "xclean" ]; then
  rm -rf ${WORK_DIR}
  rm -rf /tmp/news-group.model
fi
# Remove the work directory
#
