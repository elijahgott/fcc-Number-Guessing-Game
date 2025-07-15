#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align --tuples-only -c"

PLAY () {
  read GUESS
  ((NUM_OF_GUESSES++))

  #check if guess is integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    PLAY
  else
    # check if high or low
    if [[ $GUESS > $RANDOM_NUM ]]
    then
      echo -e "\nIt's lower than that, guess again:"
      PLAY
    elif [[ $GUESS < $RANDOM_NUM ]]
    then
      echo -e "\nIt's higher than that, guess again:"
      PLAY
    else
      UPDATE_USER "$NUM_OF_GUESSES"
      echo -e "\nYou guessed it in $NUM_OF_GUESSES tries. The secret number was $RANDOM_NUM. Nice job!"
    fi
  fi
}

GET_USER (){
  echo "Enter your username:"
  read USERNAME_INPUT

  FIND_USER=$($PSQL "select username, games_played, best_game from users where username='$USERNAME_INPUT'")

  if [[ -z $FIND_USER ]]
  then
  # USER NOT FOUND -> create new user
  INSERT_NEW_USER=$($PSQL "insert into users(username) values ('$USERNAME_INPUT')")

  echo -e "\nWelcome, $USERNAME_INPUT! It looks like this is your first time here."
  echo -e "\nGuess the secret number between 1 and 1000:"
  PLAY
  else
  # USER FOUND -> returning user
  echo $FIND_USER | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
  do
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
  echo -e "\nGuess the secret number between 1 and 1000:"

  PLAY
  fi
}

UPDATE_USER () {
  # get user info again
  FIND_USER=$($PSQL "select username, games_played, best_game from users where username='$USERNAME_INPUT'")

  echo $FIND_USER | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
  do
    ((GAMES_PLAYED++))
    # update user info

    #check if this score is better than user's best score
    if [[ $1 < $BEST_GAME ]] || [[ -z $BEST_GAME ]]
    then
      UPDATE_USER=$($PSQL "update users set games_played=$GAMES_PLAYED, best_game=$NUM_OF_GUESSES where username='$USERNAME'")
    else
      UPDATE_USER=$($PSQL "update users set games_played=$GAMES_PLAYED where username='$USERNAME'")
    fi
  done
  
}

RANDOM_NUM=$((1 + $RANDOM % 1000))
GET_USER
