#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# read 
echo -e "\nEnter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT username FROM players WHERE username='$USERNAME'")
BEST_PLAYED=0

if [[ -z $USER_INFO ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  CREATE_PLAYER=$($PSQL "INSERT INTO players(username, games_played, best_played) VALUES('$USERNAME',0,0)")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played from players WHERE username='$USERNAME'")
  BEST_PLAYED=$($PSQL "SELECT best_played from players WHERE username='$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_PLAYED guesses."
fi

GUESS_COUNT=0
RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

echo -e "\nGuess the secret number between 1 and 1000:"

GUESSING() {

  # print arg message
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  read GUESS
  
  # check if guess is a number
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    GUESSING "That is not an integer, guess again:"
    return
  fi

  ((GUESS_COUNT++))
  if [[ $GUESS -gt $RANDOM_NUMBER ]]
  then
    GUESSING "It's lower than that, guess again:"
  elif [[ $GUESS -lt $RANDOM_NUMBER ]]
  then
    GUESSING "It's higher than that, guess again:"
  else
    ((GAMES_PLAYED++))

    echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
    
    if [[ $BEST_PLAYED -eq 0 || $GUESS_COUNT -lt $BEST_PLAYED ]]
    then
      BEST_PLAYED=$GUESS_COUNT
    fi

    UPDATE_PLAYER=$($PSQL "UPDATE players SET games_played=$GAMES_PLAYED, best_played=$BEST_PLAYED WHERE username='$USERNAME'")
    
  fi
}

GUESSING
