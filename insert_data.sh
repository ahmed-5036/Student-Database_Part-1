#!/bin/bash  #shebang 

# Script to insert data from courses.csv and students.csv into students database

PSQL="psql -X --username=freecodecamp --dbname=students --no-align --tuples-only -c"

# Truncate the tables to clear existing data
echo $($PSQL "TRUNCATE students, majors, courses, majors_courses")

# Process courses.csv file
cat courses.csv | while IFS="," read MAJOR COURSE
do
  # Check if the line is not the header row ("major")
  if [[ $MAJOR != "major" ]]
  then
    # Get major_id from majors table based on major
    MAJOR_ID=$($PSQL "SELECT major_id FROM majors WHERE major='$MAJOR'")

    # If major is not found, insert a new row into majors table and retrieve the newly generated major_id
    if [[ -z $MAJOR_ID ]]
    then
      INSERT_MAJOR_RESULT=$($PSQL "INSERT INTO majors(major) VALUES('$MAJOR')")
      if [[ $INSERT_MAJOR_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into majors, $MAJOR
      fi
      MAJOR_ID=$($PSQL "SELECT major_id FROM majors WHERE major='$MAJOR'")
    fi

    # Get course_id from courses table based on course
    COURSE_ID=$($PSQL "SELECT course_id FROM courses WHERE course='$COURSE'")

    # If course is not found, insert a new row into courses table and retrieve the newly generated course_id
    if [[ -z $COURSE_ID ]]
    then
      INSERT_COURSE_RESULT=$($PSQL "INSERT INTO courses(course) VALUES('$COURSE')")
      if [[ $INSERT_COURSE_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into courses, $COURSE
      fi
      COURSE_ID=$($PSQL "SELECT course_id FROM courses WHERE course='$COURSE'")
    fi

    # Insert a row into majors_courses table with major_id and course_id
    INSERT_MAJORS_COURSES_RESULT=$($PSQL "INSERT INTO majors_courses(major_id, course_id) VALUES($MAJOR_ID, $COURSE_ID)")
    if [[ $INSERT_MAJORS_COURSES_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into majors_courses, $MAJOR : $COURSE
    fi
  fi
done

# Process students.csv file
cat students.csv | while IFS="," read FIRST LAST MAJOR GPA
do
  # Check if the line is not the header row ("first_name")
  if [[ $FIRST != "first_name" ]]
  then
    # Get major_id from majors table based on major
    MAJOR_ID=$($PSQL "SELECT major_id FROM majors WHERE major='$MAJOR'") 

    # If major is not found, set major_id to null
    if [[ -z $MAJOR_ID ]]
    then
      MAJOR_ID=null
    fi

    # Insert a row into students table with first_name, last_name, major_id, and gpa
    INSERT_STUDENT_RESULT=$($PSQL "INSERT INTO students(first_name, last_name, major_id, gpa) VALUES('$FIRST', '$LAST', $MAJOR_ID, $GPA)")
    if [[ $INSERT_STUDENT_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into students, $FIRST $LAST
    fi
  fi
done
