class padelMatch {

    static const AVAILABLE_POINTS = [0, 15, 30, 40];

    // TODO save previous sets score

    private var p1Sets;
    private var p2Sets;

    private var p1Games;
    private var p2Games;

    private var p1ScoreIdx;
    private var p2ScoreIdx;


    function initialize() {
        p1Sets = 0;
        p2Sets = 0;

        p1Games = 0;
        p2Games = 0;
        
        p1ScoreIdx = 0;
        p2ScoreIdx = 0;
    }

    // FIXME remove debug prints
    function printScore() {
        System.println("score: sets " + self.p1Sets + " - " + self.p2Sets);
        System.println("score: games " + self.p1Games + " - " + self.p2Games);
        System.println("score: " + AVAILABLE_POINTS[self.p1ScoreIdx] + " - " + AVAILABLE_POINTS[self.p2ScoreIdx]);
    }

    function incP1() {
        if (AVAILABLE_POINTS[self.p1ScoreIdx] == 40) {
            // player won game  
            self.p1Games++;

            if (self.p1Games == 6) {
                self.p1Sets++;

                self.p1Games = 0;
                self.p2Games = 0;
            }

            self.p1ScoreIdx = 0;
            self.p2ScoreIdx = 0;

            // TODO tie break
            // TODO super tie
            // TODO limit number of sets
        } else {
            // TODO add ADV case
            self.p1ScoreIdx++;
        }
    }


    function incP2() {
        if (AVAILABLE_POINTS[self.p2ScoreIdx] == 40) {
            // player won game  
            self.p2Games++;

            if (self.p2Games == 6) {
                self.p2Sets++;

                self.p1Games = 0;
                self.p2Games = 0;
            }

            self.p1ScoreIdx = 0;
            self.p2ScoreIdx = 0;

            // TODO tie break
            // TODO super tie
            // TODO limit number of sets
        } else {
            // TODO add ADV case
            self.p2ScoreIdx++;
        }
    }

    // TODO revert score

    function getP1Sets() {
        return self.p1Sets;
    }

    function getP1Games() {
        return self.p1Games;
    }

    function getP1Score() {
        return AVAILABLE_POINTS[self.p1ScoreIdx];
    }

    function getP2Sets() {
        return self.p2Sets;
    }

    function getP2Games() {
        return self.p2Games;
    }

    function getP2Score() {
        return AVAILABLE_POINTS[self.p2ScoreIdx];
    }

}