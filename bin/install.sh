#!/bin/bash
ver1=$1
ver2=$2

if [ $ver1 ]; then ENSEMBL_BRANCH="$ver1"; fi
if [ $ver2 ]; then EG_BRANCH="$ver2"; fi

## Check out *Ensembl* code (API, web and (web) tools) from GitHub:
for repo in \
  ensembl \
  ensembl-compara \
  ensembl-funcgen \
  ensembl-tools \
  ensembl-variation \
  ensembl-rest \
  ensembl-io;
do
  if [ ! -d "$repo" ]; then
    echo "Checking out $repo (branch ${ENSEMBL_BRANCH})"
    git clone --branch ${ENSEMBL_BRANCH} https://github.com/Ensembl/${repo}
  else
    echo Already got $repo, attempting to pull...
    cd $repo
    git pull
    git status
    cd ../
  fi

  echo
  echo
done

## Check out *Ensembl Genomes* code (API, web and (web) tools) from GitHub:
for repo in \
  ensemblgenomes-api;
do
  if [ ! -d "$repo" ]; then
    echo "Checking out $repo (branch ${EG_BRANCH})"
    git clone --branch ${EG_BRANCH} https://github.com/EnsemblGenomes/${repo}
  else
    echo Already got $repo, attempting to pull...
    cd $repo
    git pull
    git status
    cd ../
  fi

  echo
  echo
done

## Dir for starman logs and pid file
mkdir logs

## compile variation code
(cd ensembl-variation/C_code && make)

## Copy default VB configs
cp -vi eg-rest/eg_rest.conf.default eg-rest/eg_rest.conf
cp -vi eg-rest/bin/env.sh.default   eg-rest/bin/env.sh

## Remove Ensembl versions of endpoints we fully override
rm -v ensembl-rest/root/documentation/overlap.conf
rm -v ensembl-rest/root/documentation/compara.conf
rm -v ensembl-rest/root/documentation/vep.conf

## Remove some endpoints we dont want
rm -v ensembl-rest/root/documentation/regulatory.conf
rm -v ensembl-rest/root/documentation/gavariant.conf
rm -v ensembl-rest/root/documentation/gavariantset.conf
rm -v ensembl-rest/root/documentation/gacallset.conf
rm -v ensembl-rest/root/documentation/archive.conf