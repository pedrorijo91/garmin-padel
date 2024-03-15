import Toybox.Lang;
import Toybox.Test;



/*
    match config:
        * superTie;
        * numberOfSets;
        * goldenPoint;

    normal: super + 3
        * increment score from 0-0
        * check 40-0 + p1-> game
        * check 40-30 + p2 -> 40-40
        * check deuce + p1 -> game
        * check undo
        * check multiple undo
        * check set won
        * check goes into tie
        * check tie score
        * check tie finish
        * check 2 sets over
        * check 1-1 set goes into super
        * check super scores work
        * checks super finishes correctly
        * check score history

    normal without super:
        * check last set is normal
    
    unlimited
        * check it finishes after X sets
    
    advantages
        * checks deuce + p1 goes into advantage
        * checks A-40 + p2 goes into deuce again
        * checks A-40 + p1 wins game

*/


// Unit test to check if 2 + 2 == 4
(:test)
function myTest(logger as Logger) as Boolean {
  var x = 2 + 2; logger.debug("x = " + x);
  return (x == 4); // returning true indicates pass, false indicates failure
}