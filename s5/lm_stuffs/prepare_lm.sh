#!/bin/bash

# Copyright 2012 Vassil Panayotov
# Apache 2.0

. ./path.sh || exit 1

echo "=== Building a language model ..."

locdata=data/local
loctext=lm_stuffs

echo "--- Preparing a corpus from test and train transcripts ..."

# Language model order
order=2

loc=`which ngram-count`;
if [ -z $loc ]; then
  if uname -a | grep 64 >/dev/null; then # some kind of 64 bit...
    sdir=$KALDI_ROOT/tools/srilm/bin/i686-m64 
  else
    sdir=$KALDI_ROOT/tools/srilm/bin/i686
  fi
  if [ -f $sdir/ngram-count ]; then
    echo Using SRILM tools from $sdir
    export PATH=$PATH:$sdir
  else
    echo You appear to not have SRILM tools installed, either on your path,
    echo or installed in $sdir.  See tools/install_srilm.sh for installation
    echo instructions.
    exit 1
  fi
fi

ngram-count -order $order -write-vocab $locdata/vocab-full.txt \
  -text $loctext/lm.txt -lm $locdata/lm.arpa

echo "*** Finished building the LM model!"
