#!/bin/bash

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

PRINT_ELEMENT_INFO() {
  read ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS TYPE MELTING_POINT BOILING_POINT <<< $(echo $1 | sed "s/|/ /g")
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
}

PSQL="psql -X -U freecodecamp -d periodic_table --no-align --tuples-only -c"
QUERY="$PSQL \"select atomic_number, symbol, name, atomic_mass, type, melting_point_celsius, boiling_point_celsius from elements inner join properties using(atomic_number) inner join types using(type_id)"
QUERY_BY_ATOMIC_NUMBER="$QUERY where atomic_number=$1\""
QUERY_BY_SYMBOL="$QUERY where symbol ilike '$1'\""
QUERY_BY_NAME="$QUERY where name ilike '$1'\""

if [[ $1 =~ ^[0-9]+$ ]]
then
  QUERY_RESULT=$(eval "$QUERY_BY_ATOMIC_NUMBER")
  if [[ ! -z $QUERY_RESULT ]]
  then
    PRINT_ELEMENT_INFO $QUERY_RESULT
    exit 0
  fi
elif [[ $1 =~ ^[a-zA-Z]+$ ]]
then
  QUERY_RESULT=$(eval "$QUERY_BY_SYMBOL")
  if [[ ! -z $QUERY_RESULT ]]
  then
    PRINT_ELEMENT_INFO $QUERY_RESULT
    exit 0
  fi

  QUERY_RESULT=$(eval "$QUERY_BY_NAME")
  if [[ ! -z $QUERY_RESULT ]]
  then
    PRINT_ELEMENT_INFO $QUERY_RESULT
    exit 0
  fi
fi

echo "I could not find that element in the database."
